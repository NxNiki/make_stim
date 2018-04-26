classdef stm_img < img
    %STM_IMG common methods for mask and grating
    %   Detailed explanation goes here
    
    properties (Dependent = true, Abstract = true, SetAccess = protected)
        tex
    end
    
    methods
        function SI = stm_img()
        end
        
        function show(self) % this method will be overload in movie ans its subclasses
            for i = 1: length(self)
                imshow(self(i).tex, [mean(self(i).min_tex), mean(self(i).max_tex)])
                %imshow(self(i).tex, [])
            end
        end
    end
    
end

