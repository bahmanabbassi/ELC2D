function [Asp, Slope] = getSlopeAndAspect(Data, x_cell_size, y_cell_size)
% GETSLOPEANDASPECT - Compute the slope and aspect of a surface using the ArcGIS method.
% The ArcGIS method for calculating slope and aspect involves using the elevation values of a grid (e.g., a digital elevation model) 
% to determine the steepness (slope) and direction (aspect) of the terrain. 
% This method uses a 3x3 moving window to compute the gradient in both the x (east-west) and y (north-south) directions. 
%
% This function calculates the slope and aspect of a given data grid (elevation data) 
% using the ArcGIS method. Slope is in the range [0, 90] degrees and aspect is in the range [0, 360] degrees.
%
% Syntax:
%    [Asp, Slope] = getSlopeAndAspect(Data, x_cell_size, y_cell_size)
%
% Inputs:
%    Data        - 2D matrix representing elevation data.
%    x_cell_size - Cell size in the x-direction (horizontal resolution).
%    y_cell_size - Cell size in the y-direction (vertical resolution).
%
% Outputs:
%    Asp   - 2D matrix representing the aspect of the surface.
%    Slope - 2D matrix representing the slope of the surface.
%
% Example:
%    elevationData = peaks(100);
%    [aspect, slope] = getSlopeAndAspect(elevationData, 30, 30);
%    imagesc(aspect);
%    title('Aspect');
%    colorbar;
%
%    figure;
%    imagesc(slope);
%    title('Slope');
%    colorbar;

% Get the size of the input data
lines = size(Data, 1);
cols = size(Data, 2);

% Initialize output matrices
Asp = zeros(lines, cols);
Slope = zeros(lines, cols);

% Iterate through each cell in the grid (excluding the borders)
for i1 = 2:lines-1
    for i2 = 2:cols-1
        % Extract the 3x3 neighborhood
        n = Data(i1-1:i1+1, i2-1:i2+1);
        a = n(1, 1);
        b = n(1, 2);
        c = n(1, 3);
        d = n(2, 1);
        f = n(2, 3);
        g = n(3, 1);
        h = n(3, 2);
        i = n(3, 3);
        
        % Calculate dz/dx and dz/dy using the central difference method
        dz_dx = ((c + 2*f + i) - (a + 2*d + g)) / (8 * x_cell_size);
        dz_dy = ((g + 2*h + i) - (a + 2*b + c)) / (8 * y_cell_size);
        
        % Calculate slope and aspect
        rise_run = sqrt(dz_dx^2 + dz_dy^2);
        slope_degrees = atan(rise_run) * 57.29578; % Convert radians to degrees
        aspect = atan2(dz_dy, -dz_dx) * 57.29578;  % Convert radians to degrees
        
        % Adjust aspect to be within [0, 360] degrees
        if aspect < 0
            cell = 90.0 - aspect;
        elseif aspect > 90.0
            cell = 360.0 - aspect + 90.0;
        else
            cell = 90.0 - aspect;
        end
        
        % Assign calculated values to the output matrices
        Asp(i1, i2) = cell;
        Slope(i1, i2) = slope_degrees;
    end
end

end
