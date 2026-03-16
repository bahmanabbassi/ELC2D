function [plotH] = plotNewColorMap0(RDepth, Depth, Map, Labels, tname, Y_cord, X_cord)
% PLOTNEWCOLORMAP0 - Plot detected regions on a depth image, for each
% feature. 
%
% This function creates a new colormap plot to visualize the detected regions
% on a given depth image. The detected regions are highlighted based on their
% labels and are displayed with specific color coding.
%
% Syntax:
%    [plotH] = plotNewColorMap0(RDepth, Depth, Map, Labels, tname, Y_cord, X_cord)
%
% Inputs:
%    RDepth - Matrix of the reference depth data.
%    Depth - Matrix of the depth image data.
%    Map - Matrix containing the detected regions labeled by integers.
%    Labels - Array of labels corresponding to the detected regions to be highlighted.
%    tname - Title name for the plot.
%    Y_cord - Y coordinates for the plot.
%    X_cord - X coordinates for the plot.
%
% Outputs:
%    plotH - RGB image matrix with the detected regions highlighted.
%
% Description:
%    The function processes the depth image data to normalize and highlight
%    the detected regions specified by their labels. The regions are displayed
%    in an RGB format where the intensity is normalized and the regions are
%    colored differently from the background.

% Normalize the depth image for visualization
par = max(max((Depth))) - min(min(Depth));
plotH(:,:,1) = (Depth - min(min(Depth))) / par;
plotH(:,:,2) = (Depth - min(min(Depth))) / par;
plotH(:,:,3) = (Depth - min(min(Depth))) / par;

% Find the maximum value in the reference depth data for normalization
normal = max(max(RDepth));

% Loop through each pixel in the map
for i = 1:size(Map, 1)
    for j = 1:size(Map, 2)
        % Check if the current pixel belongs to one of the labeled regions
        if Map(i, j) > 0 && ~isempty(find(Map(i, j) == Labels, 1))
            % Highlight the detected regions
            plotH(i, j, 1) = abs(RDepth(i, j)) / normal;
            plotH(i, j, 3) = 0;
            plotH(i, j, 2) = 1 - abs(RDepth(i, j)) / normal;
        end
    end
end

% Declare global variables used in the plot
global XI
global YI
global xv
global yv

% Note: The actual plotting part might be done outside this function
end
