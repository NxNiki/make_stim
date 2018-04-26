function masktex = fun_mask(siz, center, radius, orientation, mask_type)
% generate a mask on a image with specific size. center = [pixel_x,
% pixel_y]; radius = [horizontal_length vertical_length]; orientation in
% range: -90 to 90. positive value clockwise, negative conterclockwise;
% mask_type = 'oval' or 'rect'
% by Niki 2015/5/29.

if nargin<1; siz = [512, 512]; end
if nargin<2; center = [100,40]; end
if nargin<3; radius = [0, 0]; end
if nargin<4; orientation = 45; end % in range 0:180
if nargin<5; mask_type = 'oval'; end % rect or oval

masktex = zeros(siz);
theta = orientation/180*pi;

% move coordinate origin to the center of the matrix
x0 = (1:siz(1)) - center(1);
y0 = (1:siz(2)) - center(2);

% generate mesh for x & y coordinates
[xmesh, ymesh] = meshgrid(x0,y0);
coor_trans = [cos(theta), sin(theta); -sin(theta), cos(theta)] * [xmesh(:)'; ymesh(:)'];

switch mask_type
    
    case 'oval'
        
        masktex(coor_trans(1,:).^2/radius(1)^2 + coor_trans(2,:).^2/radius(2)^2 < 1) = 1;
                
    case 'rect'
        
        masktex(abs(coor_trans(1,:))<radius(1) & abs(coor_trans(2,:))<radius(2)) = 1;        
end

if nargin<1; imshow(masktex); end



