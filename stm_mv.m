classdef stm_mv < movie
    %STM_MV common methods for making movie stimuli class (drift_grating
    %and drift_mask.
    %   Detailed explanation goes here
    
    properties
        stm_duration = 3; % seconds
        pre_blank_duration = 0;
        pos_blank_duration = 0;
        blank_color = 'gray'; % string: gray, black, white
    end
    
    properties (Dependent = true, SetAccess = private, Hidden = true)
        num_frames
        pre_blank_frames
        pos_blank_frames
    end
    
    properties (Dependent = true, SetAccess = protected, Hidden = true)
        tex % tex includes pre and post iti.
    end
    
    properties (Dependent = true, SetAccess = protected, Hidden = true, Abstract = true)
        stm_tex % stm_tex only contain tex of stimulus, without pre- and post- iti.
    end
    
    methods
        function MV = stm_mv(stmdur, predur, posdur)
            if nargin >=1 && ~isempty(stmdur); MV.stm_duration = stmdur; end
            if nargin >=2 && ~isempty(predur); MV.pre_blank_duration = predur; end
            if nargin >=3 && ~isempty(posdur); MV.pos_blank_duration = posdur; end
        end
        
        function self = set.pos_blank_duration(self, pos_dur)
            if ~isscalar(pos_dur)
                error('only scalar input is allowed')
            end
            self.pos_blank_duration = pos_dur;
        end
        
        function out = get.num_frames(obj)
            out = round(obj.stm_duration * obj.fps);
        end
        
        function out = get.pre_blank_frames(self)
            out = round(self.fps * self.pre_blank_duration);
        end
        
        function out = get.pos_blank_frames(self)
            out = round(self.fps * self.pos_blank_duration);
        end
 
        function out = get.tex(self)
            c = self.color;
            color=c.(self.blank_color);
            
            single_blank_tex = ones(self.siz(2),self.siz(1))*color(1);
            pre_tex = repmat(single_blank_tex,[1,1,self.pre_blank_frames]);
            pos_tex = repmat(single_blank_tex,[1,1,self.pos_blank_frames]);

            out = cat(3, pre_tex, self.stm_tex, pos_tex);
        end
    end
    
end

