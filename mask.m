classdef mask < stm_img
    properties
        center = [100, 100] % center position of unmasked region
        radius = [4, 1]*20 % radius of unmasked region, in unit degree, radian or pixel
        radius_unit = 'pixel'; % degree, radian or pixel
        orientation = 0 % clockwise rotation in range -0:180, counter-clockwise rotation in range: 180:0.
        type = 'oval' % oval, rect, none
        background_intensity = 'gray' % gray, black, or value between 1 to 255;
    end
    
    properties (Dependent = true, SetAccess = protected, Hidden = true)
		tex
        bg_inten
        logical_tex
    end
    
    methods
        function msk = mask(siz, typ)
            if nargin>=1 && ~isempty(siz)
                msk.siz = siz;
                msk.center = round(siz/2);
                msk.radius = round(siz/2);
            end
            
            if nargin>=2 && ~isempty(typ); 
                msk.type = typ; 
            end
        end
        
        function self = set.center(self, ct)
            if any(ct<=0)
                error('center should be positive integers or round numbers')
            else
                self.center = int16(ct);
            end
        end
        
        function out = get.bg_inten(self)
            switch self.background_intensity
                case 'black'
                    out = 0;
                case 'gray'
                    out = (self.min_tex + self.max_tex)/2;
                otherwise
                    out = self.background_intensity;
            end                       
        end
        
        function out = get.logical_tex(self)
            out = logical(self.tex-self.bg_inten);
        end

		function out = get.tex(self)
            out = zeros(self.height, self.width) + self.bg_inten;
            center_pos = self.center;
            [x, y] = self.coordinates(self.orientation, center_pos);
            
            % convert radius unit to radian:
            switch self.radius_unit
                case 'degree'
                    r = self.radius/180*pi;
                case 'radian'
                    r = self.radius;
                case 'pixel'
                    r = self.radius/self.pix_per_rad;
                otherwise
                    error('radius_unit undefined, only ''degree'', ''radian'' or ''pixel'' are allowed')
            end
            
            switch self.type                
                case 'oval'                    
                    out(x.^2/r(1)^2 + y.^2/r(2)^2 < 1) = self.max_tex;                   
                case 'rect'                    
                    out(abs(x)<r(1) & abs(y)<r(2)) = self.max_tex;
                case 'none'
                    out(:,:) = self.max_tex;
            end
		end
    end
end
