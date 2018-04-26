classdef dm_list < mv_list & drift_mask
% unfinished... run script: /Users/Niki/Documents/MATLAB/vision_study/make_stim/DriftBar_step02.m to make the movie    
    
    %DRIFT_MASK_LIST generate multiple movies of drift mask with different
    %parameters.
    %   each movie of is composed of multiple pieces of drift mask with
    %   specific parameters (duration, orientation, start center, end
    %   center). before and after each piece of drift grating, there are
    %   gray scale movies with the duration of pre and post inter trial
    %   interval.
    
    properties
        auto_ori_list = 4; % evenly spaced n orientations
        orientation_sgmv = false;
        start_center_list = [];
        start_center_sgmv = false;
        end_center_list = 0.5*2.^(0:4);
        end_center_sgmv = false;
    end
    
    properties (Constant = true)
        % parameter names should be identical to the properties of specific stimuli class
        para_name = {'duration', 'orientation', 'start_center', 'end_center'}
    end
    
    properties (Dependent = true)
        num_stml
        num_mv
        stim_tex
    end
    
    properties (Dependent = true, SetAccess = private)
        start_orientation_list = [];
        num_ori
        num_sc
        num_ec
%         stim_tex
    end
    
    methods
    end
    
end

