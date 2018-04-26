classdef drift_mask < stm_mv
    properties
        center = [1, 1; 128, 128]; % a n by 2 matrix defining the trajectory of center of mask. n cannot excced number of frames of the movie
        orientation = 0;
        omega = pi; % speed of rotation: positive: clockwise, negative: counter-clockwise.
        radius % n by 2 matrix: 1st row: start radius, last row: end radius. n cannot excced number of frames of the movie
        type = 'oval';
    end
    
    properties (Dependent = true, SetAccess = private)
        velocity % radians/seconds, this propertiy is not useful in making the texture, just for information.
        center_list
        orientation_list
        radius_list
        mv_name
    end
    
    properties (Dependent = true, SetAccess = protected)
        stm_tex
    end
    
    methods
        function dm = drift_mask(ori, center, omg)
            if nargin >=1 && ~isempty(ori)
                dm.orientation = ori;
            end
            
            if nargin >=2 && ~isempty(center)
                dm.center = center; 
            end
            
            if nargin >=3 && ~isempty(omg)
                dm.omega = omg;
                if length(ori)>1
                    dm.stm_duration = ori(end)-ori(1)/dm.omega;
                end
            end
        end
        
        % ------------------------- get methods ---------------------------
        function out = get.velocity(self)
            [x, y] = self.coordinates;
            stc = self.center(1:end-1,:);
            edc = self.center(2:end,:);
            dis = [x(1,stc(:,1)) - x(1,edc(:,1)), y(stc(:,2),1) - y(edc(:,2),1)];
            out = dis/self.stm_duration;
        end
        
        function out = get.orientation_list(self)
            out = linspace(0, self.omega*self.stm_duration, self.num_frames)/pi*180 + self.orientation(1);
        end
        
        function out = get.center_list(self)
            x = self.center(:,1);
            y = self.center(:,2);
            
            out = nan(self.num_frames,2);
            
            out(:,1) = self.fill_para_list(x);
            out(:,2) = self.fill_para_list(y);
        end
        
        function out = get.radius_list(self)
            x = self.radius(:,1);
            y = self.radius(:,2);
            
            out = nan(self.num_frames,2);       
            
            out(:,1) = self.fill_para_list(x);
            out(:,2) = self.fill_para_list(y);
        end
        
        function out = get.stm_tex(self)
            msk = mask;
            msk = self.deliver_properties(msk);
            nfs = self.num_frames;
            out = nan(cat(2, self.siz(:)', nfs));
            
            ct_l = self.center_list;
            or_l = self.orientation_list;
            rd_l = self.radius_list;
            
            for f = 1 : nfs
                msk.center = ct_l(f,:);
                msk.orientation = or_l(f);
                msk.radius = rd_l(f,:);
                out(:,:,f) = msk.tex;
            end  
        end
        
        function out = get.mv_name(self)
            out = sprintf('driftmask_dur%0.3f_fps%0.3f_startcentr%0.3f_%0.3f_startori%0.3f_vlc_%0.3f_%0.3f_omega%0.3f.mv',...
                    self.stm_duration,self.fps,self.center(1,:),self.orientation(1),self.velocity,self.omega);
        end
        
        function out = fill_para_list(self, para)
            % fill parameters to the length of frames of total movie. para is a vector of discrete parameters
            step_length = diff(para);
            total_length = sum(step_length);
            nfs = self.num_frames;
            
            out = nan(nfs,1);
            if isempty(step_length)||all(step_length)==0
                out(:) = para(1);
            else
                step_frames = round(nfs .* step_length./ total_length);
                start_frame = 1;
                for i_step = 1:length(step_length)
                    end_frame = start_frame + step_frames(i_step) - 1;
                    out(start_frame:end_frame) = linspace(para(i_step),para(i_step+1),step_frames(i_step));
                    start_frame = end_frame + 1;
                end
            end
        end
    end

end
        