clear
close all

output_dir = '/Users/Niki/Documents/MATLAB/Niki/stim_maker/drift_mask';
num_repetition = 12;
fps = 60;

dm = drift_mask;
%dm.show

dm.fps = 60;
dm.scr.view_distance = 25;
dm.spherical_correction = false;
% change values of properties:
dm.siz = [256, 256];
dm.stm_duration = 18.7; % seconds
dm.radius = [20, 2]*10; % default unit: pixel
dm.omega = 0; % rotation speed of mask in radian.
dm.pre_blank_duration = 0;
dm.pos_blank_duration = 0;

% dm.type = 'oval';
dm.type = 'rect';

% parameters will change in each loop:
file_name = {...
    'left_right',...
    'right_left',...
    'top_bottom',...
    'bottom_top',...
    };
    
center = {...
    [1,128; 256,128],...%left right
    [256,128; 1,128],...% right left
    [128,1; 128,256],...% top bottom
    [128,256; 128,1],...% bottom top
    };

orientation = [90, 90, 0, 0];

for i = 1:length(center)
    
    dm.center = center{i};
    dm.orientation = orientation(i); % in range 0:360
    
    % dm.show
    % dm.save
    
    tex = dm.tex;
    all_tex = cell(1,num_repetition);
    all_tex(:) = {tex};
%     implay(cat(3,all_tex{:}))
    save_mv(all_tex,sprintf(['%03d_',file_name{i}, '.mv'], i), output_dir)
%     save([output_dir, filesep, sprintf(['%03d_',file_name{i}, '.mat'],i)], 'tex', 'fps')
    save([output_dir, filesep, sprintf(['%03d_',file_name{i}, 'v7.mat'],i)], 'tex', 'fps','-v7')
  
end