% RUN THIS SCRIPT TO SEE THE DEMOS OF MAKING MOVIES USING CLASS DEFINE IN
% CURRENT FOLDER
% by Niki 2015/6/1.

%% making movie list of drift grating:
clear
close all
clc
tic
% set up an object of drift grating list
s = dg_list; 
% set up some parameters:
s.siz = [70, 70];
s.ITI = 1;
s.repeat = 2;
s.duration_list = 1;
s.auto_dir_list = 2;
s.spatial_frq_list =  2.^(0:2)*0.01;
s.temporal_frq_list = 0.5*2.^(0:2);

out_dir_root = pwd;
ind = strfind(out_dir_root,filesep);
out_dir_root = out_dir_root(1:ind(end));
s.output_dir = [out_dir_root, 'Multi_SF_TF_', datestr(now,'dd-mmm-yyyyTHHMM')];

% combination of ori and tf:
% s.spatial_frq_sgmv = true;

% combination of ori and sf:
% s.temporal_frq_sgmv = true;

% combination of sf and tf:
% s.direction_sgmv = true;

s = s.refresh();
% s.show();

% save parameter into .mat files and texture into .mv files
s.save_para;
s.save;

toc

%% add mask on grating:
clear
close all
g = grating;
m = mask;
m.background_intensity = 'gray';
g.orientation = 135;
m.orientation = 45;
m.radius = [64,64];
m.center = [64,64];
image = g.add_mask(m);
imshow(image,[g.min_tex,g.max_tex])

%% add mask on drift grating:
clear
close all
dg = drift_grating;
dg.siz = [256, 256]; % Pixels, size of movie 
dg.duration = 5; % seconds
dg.direction = 45; % degree
dg.spatial_frq = 0.08; % cycles per degree (cpd)
dg.temporal_frq = 3; % Hz

m = mask;
m.siz = [256,256];
m.orientation = 45;
m.center = [128,128];
m.radius = [8,8]*8;

mv = dg.add_mask(m);
implay(mv/(dg.max_tex-dg.min_tex))

%% infuse 2 grating with mask:
clear
close all
g = grating;
g.siz = [128,128];
m = mask;
m.siz = [128,128];
m.center = [64,64];

image = g.fuse(m);
imshow(image,[g.min_tex,g.max_tex])









