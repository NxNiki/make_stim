classdef plaid < stm_img
    properties
        grating1
        grating2
    end
    
    properties (Dependent = true, SetAccess = protected, Hidden = true)
        tex
    end
    methods
        function out = plaid(g1,g2)
            if nargin>=1&&isa(g1,'object');
                out.grating1 = g1;
            else
                out.grating1 = grating;
                out.grating1.orientation = 0;
            end
            
            if nargin>=2&&isa(g2,'object');
                out.grating2 = g2;
            else
                out.grating2 = grating;
                out.grating2.orientation = 90;
            end
            
        end
        
%         function set.siz(self, siz)
%             self.grating1.siz = siz;
%             self.grating2.siz = siz;
%         end
        
        function out = get.tex(self)
            out = self.grating1.fuse(self.grating2);
        end
    end
end
