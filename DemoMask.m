clear
close all

msk = mask;
msk.radius = [4,1]*10;
msk.center = [128,128];
msk.siz = [512,512];
msk.type = 'rect';
msk.radius_unit = 'pixel';
msk.spherical_correction = false;

subplot(221)
msk.orientation = 90;
msk.show

subplot(222)
msk.orientation = 0;
msk.show

subplot(223)
msk.siz = [512,256];
msk.show

subplot(224)
msk.spherical_correction = true;
msk.show