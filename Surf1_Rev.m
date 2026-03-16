% SURF1_REV - Process and visualize multiple 2D surfaces with filtering
% (for reversed color scale display).
%
% This function takes 2D grids of data, applies a specified filter to each,
% and then visualizes the filtered ones as surfaces in a subplot grid.
%
% Syntax:
%    [Grid2, plt1, plt2] = Surf1_Rev(Grid, numberoffeatures, sigma2)
%
% Inputs:
%    Grid - 3D matrix of input data (each slice is a 2D grid to be processed).
%    numberoffeatures - Number of 2D slices to process and visualize.
%    sigma2 - Standard deviation for Gaussian filtering.
%
% Outputs:
%    Grid2 - 3D matrix of filtered data.
%    plt1 - Number of rows in the subplot grid.
%    plt2 - Number of columns in the subplot grid.

function [Grid2, plt1, plt2] = Surf1_Rev(Grid, numberoffeatures, sigma2)

    % Determine the dimensions of the subplot grid
    plt1 = ceil(numberoffeatures^0.5);
    plt2 = plt1;
    
    % Declare global variables for coordinates and visualization parameters
    global XI
    global YI
    global YI_Real_Ratio
    global xv
    global yv
    
    % Create a binary mask based on the polygon defined by xv and yv
    in = inpolygon(XI, YI, xv, yv);

    % Initialize Grid2 to store the filtered slices
    Grid2 = zeros(size(Grid));

    % Loop through each feature slice in the grid
    for tttt6 = 1:numberoffeatures
        % Extract and complement the current slice
        Grid0 = imcomplement(Grid(:, :, tttt6));
        
        % Apply Gaussian filtering to the current slice
        Grid2(:, :, tttt6) = FilterB(Grid0, sigma2);
        
        % Create a subplot for the current slice
        subplot(plt1, plt2, tttt6);
        
        % Plot the filtered slice as a surface
        surf(XI, YI, Grid2(:, :, tttt6));
        
        % Set title and axis properties
        title(['# ', num2str(tttt6)]);
        box on;
        set(gca, 'TickDir', 'out', 'linewidth', 1, 'Layer', 'top');
        colormap jet;
        axis equal;
        shading interp;
        view(0, 90);
        grid off;
        daspect([YI_Real_Ratio 1 1]);
    end
end
