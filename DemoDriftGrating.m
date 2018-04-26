%% demo of drifting grating
clear; clc
close all
dg = drift_grating;
dirlist = 90;
% see default movie:
%dg.show

% or change values of properties to make your customer movie:
dg.scr.resolution = [1024, 768];
dg.siz = [1024, 768]; % Pixels, size of movie 
dg.fps = 60;
dg.stm_duration = 1/3; % seconds
dg.spatial_frq = 0.02; % cycles per degree (cpd)
dg.temporal_frq = 2; % Hz
dg.scr.view_elevation = 0;

dg.pre_blank_duration = 0;
dg.pos_blank_duration = 0;

tex_cell = cell(1,length(dirlist));
for i = 1:length(dirlist)
dg.direction = dirlist(i); % in degree (you can also define dg.orientation, but it is not recommended)
% display the movie:
% dg.show
% data of movie is stored in property: tex:
tex_cell{i} = dg.tex;
end
tex = cat(3,tex_cell{:});
save DriftGrating tex dg
% dg.save_tex
