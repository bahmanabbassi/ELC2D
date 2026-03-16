function [plotH_, Number_Of_Faults ] = Lineaments0_(Grid)
% LINEAMENTS0_ - Detect and visualize lineaments.
%
% This function processes a given grid to detect lineaments using various image
% processing techniques. The detected lineaments are visualized in the output with their  assigned step filtering values.
%
% Syntax:
%    plotH_ = Lineaments0_(Grid)
%
% Inputs:
%    Grid - 2D matrix of input data.
%
% Outputs:
%    plotH_ - Visualization of the detected lineaments.

% Declare global variables
global YI
global XI
global sigma2
global xv
global yv
global grm
global X_Pix
global Y_Pix
global Line_Res
global grm2
global GSF_Angles

% Resize the grid based on the specified resolution
Grid = imresize(Grid, Line_Res / min(X_Pix, Y_Pix));

% Apply Gaussian filtering to the grid
data1 = FilterB(Grid, sigma2);
data1 = im2double(data1);
save('data1.mat', 'data1'); % Save the filtered data

% Calculate parameters for smoothing
SSA = (grm2 / 15.2) - mod((grm2 / 15.2), 2) + 1;
fsize = round(grm2 / 2);
H = fspecial('gaussian', fsize, round(grm2 / 2));
blurreddata1 = imfilter(data1, H, 'symmetric');

% Calculate slope and aspect of the blurred data
[Asp, Slope] = getSlopeAndAspect(blurreddata1, SSA, SSA);
[~, DSlope] = getSlopeAndAspect(Slope, SSA, SSA);
[DAspect] = getSlopeOfAspect(Asp, SSA, SSA);

% Further smoothing of the derived slopes and aspects
FDSlope = imfilter(DSlope, H, 'replicate');
FDAspect = imfilter(DAspect, H, 'replicate');

% Compute fault enhancement image
I = (Slope.^2 .* FDSlope.^1 .* FDAspect.^1).^(1/4);

% Parameters for step filtering
grammes = grm2; % Step filter width
Step_Filter_nAng = GSF_Angles;
Step_Filter_step = pi / Step_Filter_nAng; % Angle step
Step_Filter_DTheta = 0:Step_Filter_step:pi - Step_Filter_step;
Step_Filter_Dbw = [2 4 6]; % Vector of main wave widths

% Apply step filtering
[Y] = step_Filtering(I, grammes, Step_Filter_DTheta, Step_Filter_Dbw, 1);

% Detect all faults from the filtered image
[BW, plotSkel] = getFaultDetection(Y, data1);

% Detection of strong faults
BWorig = BW;
C = bwconncomp(BW);
RS = regionprops(C, 'Area', 'Orientation', 'Centroid');
L = length(RS);
area = [RS(1:L).Area];
Map = bwlabel(BW, 8);

% Extract pixel values for the detected regions
RS_Y = regionprops(C, Y, 'PixelValues');

% Initialize feature matrix
feat = zeros(L, 2);

% Calculate features for each region
for i = 1:L
    vec = RS_Y(i).PixelValues;
    feat(i, 1) = sum(vec);
end
feat(:, 2) = feat(:, 1);
sv = sort(feat(:, 1), 'descend');

% Parameter for selecting the number of faults
Number_Of_Faults  = round(0.85 * length(sv));
Thresh = sv(Number_Of_Faults );
% Number_OF_Detected_Faults = num2str(Number_Of_Faults )

% Labels for regions above the threshold
Labels = find(feat(:, 1) >= Thresh);

% Plot detected regions on depth
[plotH_] = plotNewColorMap0_(Y, zeros(size(data1)), Map, Labels, 'Detected Lineaments', YI(:), XI(:));

end
