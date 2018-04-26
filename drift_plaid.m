classdef drift_plaid < movie
    
    properties
        direction = 180;
        angle = 45;
        grating1
        grating2
    end
    
    properties (Dependent = true, SetAccess = private) 
        direction1
        direction2
    end
    
    properties (Dependent = true, SetAccess = protected, Hidden = true)
        tex
    end
    
    methods
        function self = drift_plaid(dir,ang)
            if nargin>=1&&~isempty(dir); self.direction = dir; end
            if nargin>=1&&~isempty(ang); self.angle = ang; end
            self = make_grating(self);
        end
        
        function out = get.direction1(self)
            out = self.direction - self.angle/2;
        end
        
        function out = get.direction2(self)
            out = self.direction + self.angle/2;
        end
        
        function self = make_grating(self)
            %import drift_grating
            dg = drift_grating;         
            
            dg.direction = self.direction1;
            self.grating1 = dg;
            dg.direction = self.direction2;
            self.grating2 = dg;
        end

        function out = get.tex(self)            
            % this looks better but exetremely time consuming:
            %out = self.grating1.fuse(self.grating2);
            % faster way:
            out = (self.grating1.tex + self.grating2.tex)/2;            
        end
    end
end



