%% overlapping two grating: plaid stimulus
clear
close all
p = plaid;

p.grating1.siz = [256,256];
p.grating2.siz = [256,256];

p.grating1.orientation = 135;
p.grating2.orientation = -135;
p.show

%% drift plaid:
clear
close all
dp = drift_plaid;
dp.grating1.siz = [256, 256];
dp.grating2.siz = [256, 256];

dp.grating1.spatial_frq = 0.8;
dp.grating2.spatial_frq = 0.2;

% dp.direction = 180;
% dp.angle = 45;

dp.grating1.direction = 135;
dp.grating2.direction = -135;

dp.show