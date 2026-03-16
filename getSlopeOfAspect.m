function [Slope] = getSlopeOfAspect(Data, x_cell_size, y_cell_size)
% GETSLOPEOFASPECT - Compute the slope of the aspect of a surface using the ArcGIS method.
%
% This function calculates the slope of the aspect of a given data grid (elevation data for example)
% using the ArcGIS method. Slope is in the range [0, 90] degrees.
%
% Syntax:
%    [Slope] = getSlopeOfAspect(Data, x_cell_size, y_cell_size)
%
% Inputs:
%    Data        - 2D matrix representing elevation data.
%    x_cell_size - Cell size in the x-direction (horizontal resolution).
%    y_cell_size - Cell size in the y-direction (vertical resolution).
%
% Outputs:
%    Slope - 2D matrix representing the slope of the surface.
%
% Example:
%    elevationData = peaks(100);
%    slope = getSlopeOfAspect(elevationData, 30, 30);
%    imagesc(slope);
%    title('Slope');
%    colorbar;

% Get the size of the input data
[lines, cols] = size(Data);

% Initialize the output matrix
Slope = zeros(lines, cols);

% Iterate through each cell in the grid (excluding the borders)
for i1 = 2:lines-1
    for i2 = 2:cols-1
        % Extract the 3x3 neighborhood
        n = Data(i1-1:i1+1, i2-1:i2+1);
        a = n(1, 1); b = n(1, 2); c = n(1, 3);
        d = n(2, 1); f = n(2, 3);
        g = n(3, 1); h = n(3, 2); i = n(3, 3);
        
        % Calculate dz/dx and dz/dy using the ArcGIS method
        dz_dx = ((c + 2*f + i) - (a + 2*d + g)) / (8 * x_cell_size);
        dz_dy = ((g + 2*h + i) - (a + 2*b + c)) / (8 * y_cell_size);
        
        % Calculate the slope
        rise_run = sqrt(dz_dx^2 + dz_dy^2);
        slope_degrees = atan(rise_run) * (180 / pi); % Convert radians to degrees
        
        % Assign the calculated slope to the output matrix
        Slope(i1, i2) = slope_degrees;
    end
end

end
