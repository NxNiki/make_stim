function [x2,y2] = rotate_coordinates(x,y,angle,direction)
if nargin<4
    direction = 'counterclockwise';
end

if strcmp(direction, 'counterclockwise')
    phi = angle/180*pi;
elseif strcmp(direction, 'clockwise')
    phi = -angle/180*pi;
end

x2 = y*sin(phi) + x*cos(phi);
y2 = y*cos(phi) - x*sin(phi);

end

