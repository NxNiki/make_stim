classdef screen
    % basic geometric properties of screen and view view_distance, angle.
    % by Niki 2013/7/12.
    
    properties
        diagonal_inch = 20 % diagonal length, in millimeters
        resolution = [1024, 768]; % [width, height], resolution of coverage on screen where images or movies are displayed:
        view_distance = 250; % in millimeters, distance between eye and screen.
        view_elevation = 50; % in millimeters, difference between the height of center point of screen and the height of mouse.
    end
    
    properties (Constant = true)
        mm_per_inch = 25.4
    end

    properties (Dependent = true, SetAccess = private)
        view_angle_rad  %[left, top, right, bottom] in radians
        view_angle_degree
        view_dis_rad % same unit as view angle. useful is spherical correction is true.
        siz_mm % size of screen in millimeters
        width_height_ratio
        pix_per_rad
        pix_per_degree
    end
    
    methods
        
        % construct method:------------------------------------------------
        function img = img(diagonal_inch, view_d)
            if nargin>=1&&~isempty(diagonal_inch); img.diagonal_inch = diagonal_inch; end
            if nargin>=2&&~isempty(view_d); img.view_distance = view_d; end
        end
                
        % get methods:-----------------------------------------------------
        function out = get.siz_mm(self)
            theta = atan(double(self.resolution(2))/double(self.resolution(1)));
            horizontal = self.diagonal_inch*cos(theta);
            vertical = self.diagonal_inch*sin(theta);
            out = [horizontal, vertical]*self.mm_per_inch;
        end
            
        function out = get.view_angle_rad(self)
            theta_h = atan(self.siz_mm(1)/2/self.view_distance);

            theta_v1 = atan((self.siz_mm(2)/2 + self.view_elevation)/self.view_distance);
            theta_v2 = atan((self.siz_mm(2)/2 - self.view_elevation)/self.view_distance);
            
            out = [-theta_h, theta_v1, theta_h, -theta_v2];
        end
        
        function out = get.view_angle_degree(self)
            out = self.view_angle_rad/pi*180;
        end
        
        function out = get.view_dis_rad(self)
            height_rad = self.view_angle_rad(3) - self.view_angle_rad(1);
            height_mm = self.siz_mm(2);
            out = self.view_distance/height_mm*height_rad;
        end

        function out = get.width_height_ratio(self)
            out = self.resolution(1)/self.resolution(2);
        end
        
        function out = get.pix_per_rad(self)
            view_agl = self.view_angle_rad;
            out = double(self.resolution(1)/(view_agl(3)-view_agl(1)));
        end
        
        function out = get.pix_per_degree(self)
            view_agl = self.view_angle_degree;
            out = double(self.resolution(1)/(view_agl(3)-view_agl(1)));
        end
        
    end

end













