classdef movie < img
    % MOVIE class methods inherited by stm_mv and mv_list:
    properties
        fps = 20; % frames per seconds
    end
    
    properties (Dependent = true, SetAccess = protected, Abstract = true)
        mv_name
    end

    methods
        function mv = movie( fps)
            if nargin>=1&&~isempty(fps); mv.fps = fps; end
        end

        function out = merge_tex(self,homogeniousobj)
            % merge tex in an array of movie objects.
            if nargin<2
                homogeniousobj = 0;
            end
            fprintf('movie: merge_tex, fps of all elements in the input object should be same')
            
            %this will work if elements in the input object vector are same subclass
            if homogeniousobj
                out = cat(3,self.tex);
            else
                % this will work if siz of all obj elements are same:
                tex_ary = cell(1,numel(self));
                for i = 1: numel(self)
                    tex_ary{i} = self(i).tex;
                end
                out = cat(3,tex_ary{:});
            end
        end
        
        function show(self,tex)
            if nargin<2
                tex = cat(3, self.tex);
            end
            
            if iscell(tex)
                for i = 1:numel(tex)
                    implay(tex{i}/(self.max_tex - self.min_tex), self.fps)
                end
            else
                implay(tex/(self.max_tex - self.min_tex), self.fps)
            end
        end

        function save_merge_tex(self, mv_name)
            if nargin<2
                mv_name = 'merge.mv';
            end
            merge_text = self.merge_tex;
            save_mv(merge_text, mv_name)
        end

        function save(self)
            self.save_tex;
        end

    end
        
    methods (Access = protected)
        
        function save_tex(self, start_ind)
            if nargin<2
                start_ind = 1;
            end
            % tex in each element will be saved in an individual mv file
            output_path = self.output_dir;
            tx = self.tex;
            fname = self.mv_name;
            
            name_ind = sprintf('%03d_',start_ind);
            save_mv(tx, [name_ind, fname], output_path);
        end
    end
    
    
end











