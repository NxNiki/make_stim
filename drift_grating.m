classdef drift_grating < stm_mv
    
    properties 
        temporal_frq = 2; % in Hz, cycles per second
        spatial_frq = 0.02 % cycles per degree
        direction = 0; % in range 0:360;
        start_phase = pi;
    end
    
    properties (Dependent = true, SetAccess = protected, Hidden = true)
        phase_list
        drift_omega
        stm_tex
        mv_name
    end
    
    methods
        function dg = drift_grating(sp, tf, dir)
            if nargin>=1 && ~isempty(sp); dg.start_phase = sp; end
            if nargin>=2 && ~isempty(tf); dg.temporal_frq = tf; end
            if nargin>=3 && ~isempty(tf); dg.direction = dir; end
        end
        
        function out = get.phase_list(self)
            out = linspace(0, self.drift_omega*self.stm_duration, self.num_frames) + self.start_phase;
        end
        
        function out = get.drift_omega(dg)
            out = 2*pi*dg.temporal_frq;
        end

        function out= get.stm_tex(self)
            grt = grating;
            grt = self.deliver_properties(grt);
            nfs = self.num_frames;
            out = nan(self.siz(2),self.siz(1),nfs);
            
            pha_l = self.phase_list;
            grt.orientation = self.direction-90;
            for f = 1 : self.num_frames
                grt.phase = pha_l(f);
                out(:,:,f) = grt.tex;
            end
        end

        function out = get.mv_name(self)
                out = sprintf('driftgrating_dur%0.3f_fps%0.3f_startphase%0.3f_tf%0.3f.mv',...
                    self.stm_duration,self.fps,self.phase(1),self.temporal_frq);
        end
    end
    
end
