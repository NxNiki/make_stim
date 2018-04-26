classdef grating < stm_img
    properties
        orientation = 0; % clockwise rotation in range 0:180, counter-clockwise rotation in range: -180:0.
        spatial_frq = 0.02;  % cycles per degree
        phase = 1/2*pi;  % in range 0:2*pi
        contrast = 1;  % for sine gratings: in range 0:1, for square gratings, set contrast to inf
    end
    
    properties (Dependent = true, SetAccess = private, Hidden = true)
        cycles
    end
    
    properties (Dependent = true, SetAccess = protected, Hidden = true)
        tex
    end

    methods
        
        % construct method:------------------------------------------------
        function grating = grating(ori, sf, phase, contrast)
            if nargin>1&&~isempty(ori); grating.orientation = ori; end
            if nargin>2&&~isempty(sf); grating.spatial_frq = sf; end
            if nargin>3&&~isempty(phase); grating.phase = phase; end
            if nargin>4&&~isempty(contrast); grating.contrast = contrast; end
        end
        
        % set methods:-----------------------------------------------------
        function self = set.orientation(self, input)
            if numel(input)~=1
                error('grating: only scalar orientation is allowed')
            else
                self.orientation = input;
            end
        end
        
        function self = set.spatial_frq(self, input)
            if numel(input)~=1
                error('grating: only scalar spatial frequency is allowed')
            else
                self.spatial_frq = input;
            end
        end
        
        function self = set.phase(self, input)
            if numel(input)~=1
                error('grating: only scalar phase is allowed')
            else
                self.phase = input;
            end
        end
        
        function self = set.contrast(self, input)
            if numel(input)~=1
                error('grating: only scalar contrast is allowed')
            else
                self.contrast = input;
            end
        end
        
        % get methods:-----------------------------------------------------
        function out = get.cycles(self)
            out = self.scr.view_angle(2) *180/pi * self.spatial_frq;
        end

		function out = get.tex(self)
            % Build grating textures:
            [~,y] = self.coordinates(self.orientation);
            
            f=self.spatial_frq*360;
            m=sin(f*y - self.phase);
            
            inc=mean(self.color.white-self.color.gray)*self.contrast;
            out=(mean(self.color.gray)+inc*m);
            
            out(out>self.max_tex)=self.max_tex;
            out(out<self.min_tex)=self.min_tex;
        end
        
    end
    
    methods (Access = protected) % protected methods can be overridden by subclass
        
%         function tex = fill_tex(grating)
%             tex = grating.gen_grating_tex;
%         end
        
    end
end
