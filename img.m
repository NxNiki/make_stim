classdef img
% the basic class to make stimulus. all other classes are derived from this
% one. Define basic properties of images, movies, and physical parameters
% so that image size can be converted into degree units. Define some basic
% methods (some of them will be overridden in subclasses).
% by Niki 2013/6/2.
% isolate some properties into class screen
% by Niki 2013/7/12.
    
    properties
        siz = [128, 128]; % width, height in pixels
        color_mode = 'gray'; % 'color (RGB)' or 'gray'
        
        full_screen = 1; 
        % 1: img will stretched to fill the screen, this will affect some
        % properties (e.g. orientation) of img; 
        % 0: img will not be stretched according to resolution of screen.
        spherical_correction = false;
        scr
        output_dir
        base_dir
    end
    
    properties (Constant = true, Hidden = true)
        max_tex = 255;
        min_tex = 0;
    end
    
    properties (Dependent = true, SetAccess = private, Hidden = true)
        width
        height
        color
        pix_per_rad
        width_height_ratio
    end
    
    
    methods
        
        % -------------------- construct method: --------------------------
        
        function img = img(siz, cm, scr)
            if nargin>=1 && ~isempty(siz); img.siz = siz; end
            if nargin>=2 && ~isempty(cm); img.color_mode = cm; end
            if nargin>=3 && ~isempty(scr)
                img.scr = scr;
            else
                import screen
                img.scr = screen;
            end
            path = strsplit(pwd,filesep);
            img.base_dir = sprintf(['%s', filesep], path{1:end-1});
            img.output_dir = [img.base_dir, 'output'];
        end
        
        % ----------------------- set methods: ----------------------------
        
        function self = set.siz(self,siz)
            if numel(siz)~=2
                error('size should be a numeric vector of 2 elements')
            end
            self.siz = int16(siz);
        end
        
        % ----------------------- get methods: ----------------------------
        
        function color = get.color(img)
            if strcmp(img.color_mode, 'gray')
                color.white = img.max_tex;
                color.black = img.min_tex;
                color.gray = (img.max_tex + img.min_tex)/2;
            else
                color.white = [1,1,1]*img.max_tex;
                color.black = [1,1,1]*img.min_tex;
                color.gray = [1,1,1]*(img.max_tex + img.min_tex)/2;
            end
        end        
        
        function out = get.width(self)
            out = self.siz(1);
        end
        
        function out = get.height(self)
            out = self.siz(2);
        end
        
        function out = get.pix_per_rad(self)
            out = self.scr.pix_per_rad;
        end
        
        function out = get.width_height_ratio(self)
            out = self.width/self.height;
        end
        
        % ------------------------ others: --------------------------------
        
        function varargout = coordinates(self, rotate, center)
            if nargin<2 || isempty(rotate); rotate = 0; end
            if nargin<3 || isempty(center); center = 'viewpoint'; end
            
            scr_res = self.scr.resolution;
            img_res = self.siz;
            
            if any(scr_res<img_res)
                error('size of image should not exceed resolution of screen, please reduce size of image to fit screen resolution')
            end
            
            view_ang = self.scr.view_angle_rad;
            
            x = linspace(view_ang(1),view_ang(3),self.siz(1));
            y = linspace(view_ang(2),view_ang(4),self.siz(2));
            
            if strcmp(center, 'viewpoint')
                shift = [0, 0];
            else
                if ischar(center)
                    switch center
                        case 'topleft'
                            center = [1, 1];
                        case 'topright'
                            center = [self.siz(1), 1];
                        case 'bottomleft'
                            center = [1, self.siz(2)];
                        case 'bottomright'
                            center = [self.siz(1), self.siz(2)];
                        otherwise
                            error('illegal value for center, only vectors with 2 elements or string: ''wiewpoint'', ''topleft'', ''bottomleft'', ''bottomright'' are allowed')
                    end
                elseif ~isnumeric(center)||numel(center)~=2
                    error('illegal value for center, only vectors with 2 elements or string: ''wiewpoint'', ''topleft'', ''bottomleft'', ''bottomright'' are allowed')
                end
                shift = [x(center(1)), y(center(2))];
            end
            
            [xmesh,ymesh] = meshgrid(x-shift(1), y-shift(2)); 
            [xmesh,ymesh] = rotate_coordinates(xmesh,ymesh,rotate);
            
            if self.spherical_correction
                % convert view distance to radian units:
                d = self.scr.view_dis_rad;
                
                r = sqrt(xmesh.^2 + ymesh.^2 + d.^2); 
                theta = atan(xmesh/d); 
                phi = asin(ymesh./r);                
                
                varargout = {theta, phi, r};
            else          
                varargout = {xmesh, ymesh};
            end
        end

        function out = add_mask(self, msk)
            if any(self.siz-msk.siz)
                error('img:add_mask: input image should have same size')
            elseif size(self.tex,3)==size(msk.tex,3)
                out = self.tex.*msk.logical_tex + msk.tex.*~msk.logical_tex; % add msk.tex enable customed intensity of unmasked region, rather than black.
            elseif size(msk.tex,3)==1
                out = bsxfun(@plus, bsxfun(@times, self.tex, msk.logical_tex), msk.tex.*~msk.logical_tex);
            end
        end
        
        function out = fuse(self1,self2,method)
            if nargin < 3
                method = 'blend';
            end
            if any(self1.siz-self2.siz)
                error('img:fuse:input object have different size')
            elseif size(self1.tex,3)==1&&size(self2.tex,3)==1
                out = imfuse(self1.tex,self2.tex,method);
            elseif self1.num_frames==self2.num_frames
                out = zeros(self1.siz(1),self1.siz(2),self1.num_frames);
                for iframe = 1:self1.num_frames
                    out(:,:,iframe) = imfuse(self1.tex(:,:,iframe),self2.tex(:,:,iframe),method);
                end
                
                % for loop will be terribly time consuming, so I replace
                % the code above with the below:
%                 tex1 = reshape(self1.tex,self1.siz(1),self1.siz(2)*self1.num_frames);
%                 tex2 = reshape(self2.tex,self1.siz(1),self1.siz(2)*self1.num_frames);
%                 out = reshape(imfuse(tex1,tex2,method),self1.siz(1),self1.siz(2),self1.num_frames);
            end
        end
        
        function superclassobj = deliver_properties(self,superclassobj)
            p1 = properties(self);
            p2 = properties(superclassobj);
            p = intersect(p1,p2);
            
            for i = 1:length(p);
                superclassobj.(p{i})=self.(p{i});
            end
        end
        
        function mk_output_dir(self)
            if ~exist(self.output_dir,'dir')
                fprintf('making output directory:\n %s\n', self.output_dir)
                mkdir(self.output_dir)
            end
        end
        
    end
    
end








