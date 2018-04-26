function gratingtex = fun_grating(siz, orientation, cycles, phase, contrast)
% make gray scale images of gratings with varying orientation, spatial
% frequency (cycles), phase (useful for making muliple iamges of drifting 
% gratings, contrast (inf contrast will make a square grating) and size (a
% vector of the width and height of the image).
% this function is adapted from AlphaRotateDemo.m in Psychtoolbox 3.0
% by Niki 2015/5/29.

if nargin<1; siz = [512, 512]; end
if nargin<2; orientation = 30; end % in range 0:180
if nargin<3; cycles = 10; end % number of cycles in the image.
if nargin<4; phase = 1/2*pi; end % in range 0:2*pi
if nargin<5; contrast = 1; end % for sine gratings: in range 0:1, for square gratings, set contrast to inf

white = [1,1,1]*255;
black = [1,1,1]*0;
gray  = mean([white;black]);

[x,y]=meshgrid((0: siz(1)-1)/(siz(1)-1), (0: siz(2)-1)/(siz(2)-1));
angle=-orientation*pi/180; 
f=cycles*2*pi; 

a=sin(angle)*f;
b=cos(angle)*f;

inc=mean(white-gray)*contrast;

% Build grating textures:
m=sin(a*x+b*y+phase);
gratingtex=(mean(gray)+inc*m);

if nargin<1
    subplot(1,2,1)
    imshow(a*x+b*y+phase, [min(min(a*x+b*y+phase)), max(max(a*x+b*y+phase))])
    subplot(1,2,2)
    imshow(gratingtex, [0, 255])
end

