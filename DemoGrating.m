%% compare cartesian and spherical coordinates:
clear
close all
g = grating;
g.siz = [512,512]; % [width height]
g.spatial_frq = 0.04;
g.scr.view_elevation = 20; % in millimeter
g.scr.view_distance = 100;

subplot(221)
g.orientation = 0;
g.spherical_correction = 0;
g.show

subplot(222)
g.spherical_correction = 1;
g.show

subplot(224)
g.orientation = 45;
g.show

subplot(223)
g.spherical_correction = 0;
g.show
