classdef mv_list < movie
%MOVIE_LIST make movies composed of several type of stimulus, separated by
%gray screen with specified inter trial interval (ITI).
% by Niki 2015/7/15.
    
    properties
        jitter = true; % add a random interval on inter_trial_interval
        randomize = true; % 
        ITI = 2; % inter trial interval
        repeat = 3; % repetition of each movie
        ITI_split = 1/4; % split ITI into pre- and post-stimli
        jitter_range = 1 % in seconds
        duration_list = 3; % in seconds
        duration_sgmv = false % logical, if true, make single movie for each value in duration_list
                
        merge_stml = false;
        % if true, tex_list will be a cell array with each element contains
        % data matrix in 1x1 cell array for a single movie. if false,
        % elements of tex_list will be 1xN cell arrays, elements of each
        % corresponds to a stimuli. We use this if the movie is too large
        % and cause out of memory problem. According to experience, the
        % program runs faster if this property is set false.
    end
    
    properties (Dependent = true, SetAccess = private, Hidden = true)
        num_stml
        num_mv
        num_dur
        num_para
        onset
        pre_iti
        tex_list
        dur_list
    end
    
    properties (SetAccess = private)
        % parameter with randomness: we do not set them dependent to avoid
        % unwanted change each time they are called.
        pos_iti
        para_table
    end
    
    methods
        
        % ------------------ constructing method: -------------------------
        function ML = mv_list(jit, rnd, iti, rep, drl)
            if nargin>=1&&~isempty(jit); ML.jitter = jit;    end
            if nargin>=2&&~isempty(rnd); ML.randomize = rnd; end
            if nargin>=3&&~isempty(iti); ML.ITI = iti;       end
            if nargin>=4&&~isempty(rep); ML.repeat = rep;    end
            if nargin>=5&&~isempty(drl); ML.duration_list = drl; end
            
            disp('MV_LIST: pos_iti and para_table may vary each time the constructing method runs')
            disp('MV_LIST: the movies will not be identical when another object is created even with all parameters unchanged')            
            
            ML = ML.refresh();
        end
        
        % ---------------------- set methods: -----------------------------
        function self = set.jitter(self, jitter)
            self.jitter = checkvar(jitter,'logical');
            self = self.refresh(); % refresh properties with randomness, as they are not dependent properties
        end
        
        function self = set.randomize(self, rnd)
            self.randomize = checkvar(rnd,'logical');
            self = self.refresh();
        end
        
        function self = set.ITI(self, iti)
            self.ITI = checkvar(iti,'scalar',[0+eps,20]);
            self = self.refresh();
        end
        
        function self = set.repeat(self, rep)
            self.repeat = checkvar(rep, 'integer', [1, 100]);
            self = self.refresh();
        end
        
        function self = set.ITI_split(self, itis)
            self.ITI_split = checkvar(itis,'scalar',[0,1]);
            self = self.refresh();
        end
        
        function self = set.duration_list(self, drl)
            self.duration_list = checkvar(drl, [1/self.fps, 1000]); 
            self = self.refresh();
        end
        
        function self = set.duration_sgmv(self, tf)
            self.duation_sgmv = checkvar(tf, 'logical');
            self = self.refresh();
        end
        
        % ----------------------- get methods: ----------------------------
        function out = get.num_dur(self)
            out = numel(self.duration_list);
        end
        
        function out = get.num_stml(self)
            [~, num, issgmv] = self.summerize_para();
            out = prod(num(~issgmv)) * self.repeat;
        end
        
        function out = get.num_mv(self)
            [~, num, issgmv] = self.summerize_para();
            out = prod(num(issgmv));
        end
        
        function out = get.num_para(self)
            out = length(self.para_name);
        end
        
        function out = get.pre_iti(self)
            out = self.ITI*self.ITI_split;
        end
        
        function out = get.onset(self)
            out = cell(self.num_mv,1);
            preiti = self.pre_iti;
            postiti = self.pos_iti;
            for i = 1:self.num_mv
                dur = squeeze(self.para_table(:,1,i));
                psi = postiti{i};
                out{i} = cumsum(preiti + psi(:) + dur(:)) - (psi(:) + dur(:));
            end
        end
        
        %------------------------------------------------------------------
        function save_para(self)
            self.mk_output_dir % methods inherited from class img
            fname = self.mv_name;
            fprintf('MV_LIST.SAVE_PARA: saving parameters..............................\n')
            
            for i = 1: self.num_mv                
                P.onset = self.onset{i};
                P.name = self.para_name;
                P.value = self.para_table(:,:,i);
                P.pre_iti = self.pre_iti;
                P.pos_iti = self.pos_iti{i};
                    
                % this is time and space consuming when movie is large (but
                % of typical size in real experiments
                %P.mv_tex = self.tex{i}; 
                
                fprintf('MV_LIST.SAVE_PARA: movie: %d\n',i);
                disp(P)
                name_ind = sprintf('%03d_', i);
                
                % save([self.output_dir, filesep, name_ind, fname{i}, '.mat', '-v7.3'], 'P')
                save([self.output_dir, filesep, name_ind, fname{i}, '.mat'], 'P')
            end
            fprintf('MV_LIST.SAVE_PARA: saving parameters ------------------------done!\n')
        end
        
        function self = refresh(self)
            % recalculate parameters with randomness (pos_iti and
            % para_table), this function should be called once some
            % parameters are altered. we do not set these parameters as
            % dependent properties to avoid unwanted change each time they
            % are called.
            
            % refresh post iti:
            piti = cell(self.num_mv,1);
            for i = 1: self.num_mv
                piti{i} = self.ITI*(1-self.ITI_split) + rand(1,self.num_stml) * self.jitter_range * self.jitter;
            end
            self.pos_iti = piti;
            
            % refresh para table:
            [list, ~, issgmv] = self.summerize_para();
            p_tb = nan(self.num_stml, self.num_para, self.num_mv);
            
            % fill single movie parameters:
            if any(issgmv)
                para = repmat(permute(combination(list(issgmv)),[3,2,1]), self.num_stml,1);
                p_tb(:,issgmv,:) = para;
            end

            % fill non-single movie parameters:
            for i = 1:self.num_mv
                [~,~,para] = combination(list(~issgmv),self.repeat);
                p_tb(:,~issgmv,i) = para;
            end

            if self.randomize
                p_tb = Shuffle(p_tb,2);
            end
            self.para_table = p_tb;
        end
    end
    
    methods (Access = protected)

        function save_tex(self)
            fprintf('MV_LIST.SAVE_TEX...')
            self.mk_output_dir % methods inherited from class img
            fname = self.mv_name;
            
            for i = 1: self.num_mv
                tex = self.get_single_mv(i);
                name_ind = sprintf('%03d_', i);
                save_mv(tex, [name_ind, fname{i},'.mv'], self.output_dir);
            end
            fprintf('MV_LIST.SAVE_TEX-------------------------------done!')
        end
    end
    
    methods (Abstract = true)
        % methods implemented in dm_list and dg_list:
        [list, num, issgmv] = summerize_para(self)
        
        out = get_single_mv(self,i)
        
    end
        
end
        
