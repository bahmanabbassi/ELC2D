function F_Grid = FilterB(Grid, sigma2)
% FILTERB - Apply Gaussian filtering to a grid.
%
% This function applies a Gaussian filter to the input grid if the standard 
% deviation (sigma2) is greater than 0. If sigma2 is 0 or less, the input grid 
% is returned unchanged.
%
% Syntax:
%    F_Grid = FilterB(Grid, sigma2)
%
% Inputs:
%    Grid   - Input 2D matrix (grid) to be filtered.
%    sigma2 - Standard deviation for Gaussian filter. If sigma2 <= 0, no filtering is applied.
%
% Outputs:
%    F_Grid - Filtered grid. If sigma2 <= 0, F_Grid is the same as the input Grid.
%
% Example:
%    grid = peaks(100);
%    sigma = 2;
%    filtered_grid = FilterB(grid, sigma);
%
%    figure;
%    subplot(1,2,1);
%    imagesc(grid);
%    title('Original Grid');
%    colorbar;
%
%    subplot(1,2,2);
%    imagesc(filtered_grid);
%    title('Filtered Grid');
%    colorbar;

    % Check if sigma2 is greater than 0
    if sigma2 > 0
        % Apply Gaussian filter with standard deviation sigma2
        F_Grid = imgaussfilt(Grid, sigma2); 
    else
        % If sigma2 is 0 or less, return the original grid
        F_Grid = Grid;
    end

end
