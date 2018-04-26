classdef dg_list < mv_list
    %DRIFT_GRATING_LIST generate multiple movies of drift_grating with
    %different parameters.
    %   each movie of is composed of multiple pieces of drift_grating with
    %   specific parameters (duration, direction, spatial frequency,
    %   temporal frequency). before and after each piece of drift grating, 
    %   there are gray scale movies with the duration of pre and post inter
    %   trial interval.
    
    properties
        auto_dir_list = 8; % evenly spaced n orientations
        direction_sgmv = false;
        spatial_frq_list = 2.^(0:4)*0.01;
        spatial_frq_sgmv = false;
        temporal_frq_list = 0.5*2.^(0:4);
        temporal_frq_sgmv = false;
    end
    
    properties (Constant = true)
        % parameter names should be identical to the properties of specific stimuli class
        para_name = {'stm_duration', 'direction', 'spatial_frq', 'temporal_frq'}
    end
    
    properties (Dependent = true, SetAccess = private)
        direction_list = [];
        num_dir
        num_sf
        num_tf
    end
        
    methods
        function dgl = drift_grating_list(drl, sfl, tfl)
            if nargin>=1 && ~isempty(drl); dgl.direction_list    = drl; end
            if nargin>=2 && ~isempty(sfl); dgl.spatial_frq_list  = sfl; end
            if nargin>=3 && ~isempty(tfl); dgl.temporal_frq_list = tfl; end
            
            dgl = dgl.refresh();
        end
        
        % ------------------------ set methods ----------------------------
        function self = set.auto_dir_list(self, nori)
            if mod(nori,1)==0 && nori<=24 && nori>0
                self.auto_dir_list = nori;
                self = self.refresh();
            else
                error('input number of orientations should be round number and ranges from 1 to 24')
            end
        end
        
        function self = set.direction_list(self, orl)
            self.direction_list = orl;
            self.auto_dir_list = [];
            self = self.refresh();
        end
        
        % ------------------------- get methods ---------------------------
        
        function out = get.num_dir(self)
            out = numel(self.direction_list);
        end
        
        function out = get.num_sf(self)
            out = numel(self.spatial_frq_list);
        end
        
        function out = get.num_tf(self)
            out = numel(self.temporal_frq_list);
        end
        
        function out = get.direction_list(self)
            nori = self.auto_dir_list;
            out = linspace(360/nori,360,nori);
        end
        
        function out = get_single_mv(self,mv_i)
            out = cell(1, self.num_stml);
            para = self.para_table(:,:,mv_i);
            dg = drift_grating;
            dg = self.deliver_properties(dg);
            dg.pre_blank_duration = self.pre_iti;
            positi = self.pos_iti{mv_i};
            for j = 1: self.num_stml
                fprintf('DG_LIST.GET_SINGLE_MV: making drift grating, stimulus: %d\n',j);
                for k = 1: self.num_para
                    fprintf('DG_LIST.GET_SINGLE_MV: setting parameter %s: %3.3f\n', self.para_name{k}, para(j,k));
                    dg.(self.para_name{k})=para(j,k);
                end
                dg.pos_blank_duration = positi(j);
                out{j} = dg.tex;
            end
        end
        
        function [list, num, issgmv] = summerize_para(self)
            list = {self.duration_list, self.direction_list, self.spatial_frq_list, self.temporal_frq_list};
            num  = cellfun(@numel, list);
            issgmv = [self.duration_sgmv, self.direction_sgmv, self.spatial_frq_sgmv, self.temporal_frq_sgmv];
        end

    end
    
    methods (Access = protected)
        
        function out = make_mv_name(self)
            % data in "{}" indicates the only one value of duration,
            % direction, sf or tf. data in "[]" indicates number of
            % variations of the parameter.
            fprintf('DG_LIST.MAKE_MV_NAME:start...\n')
            n_mv = self.num_mv;
            para_table = self.para_table;
            out = cell(n_mv,1);
            for i = 1:n_mv
                if self.duration_sgmv || self.num_dur==1 % num_dur is a property in class mv_list.
                    str_dur = sprintf('Dur{%1.3f}',para_table(1,1,i));
                else
                    str_dur = sprintf('Dur[%d]',self.num_dur);
                end
                
                if self.direction_sgmv || self.num_dir==1
                    str_dir = sprintf('Dir{%3.0f}', para_table(1,2,i));
                else
                    str_dir = sprintf('Dir[%d]', self.num_dir);
                end
                
                if self.spatial_frq_sgmv || self.num_sf==1
                    str_sf = sprintf('Sf{%1.3f}', para_table(1,3,i));
                else
                    str_sf = sprintf('Sf[%d]', self.num_sf);
                end
                
                if self.temporal_frq_sgmv || self.num_tf==1
                    str_tf = sprintf('Tf{%1.3f}', para_table(1,4,i));
                else
                    str_tf = sprintf('Tf[%d]', self.num_tf);
                end
                out(i) = {[str_dur, str_dir, str_sf, str_tf]};
            end
            fprintf('DG_LIST.MAKE_MV_NAME:done!\n')
        end
        
    end
    
end

