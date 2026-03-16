function plotH = Lineaments0(Grid)
% LINEAMENTS0 - Detect and visualize lineaments.
%
% This function processes a given grid to detect lineaments using various image
% processing techniques. The detected lineaments are visualized in the output as stacked binary images of all detected lineaments.
%
% Syntax:
%    plotH = Lineaments0(Grid)
%
% Inputs:
%    Grid - 2D matrix of input data.
%
% Outputs:
%    plotH - Visualization of the detected lineaments.

% Declare global variables used throughout the function
global YI
global XI
global sigma2
global xv
global yv
global grm
global X_Pix
global Y_Pix
global GSF_Angles
global grm2
global Line_Res

% Resize the grid to match the specified resolution
Grid = imresize(Grid, Line_Res / min(X_Pix, Y_Pix));

% Apply Gaussian filtering to the resized grid
data1 = FilterB(Grid, sigma2);
data1 = im2double(data1); % Convert filtered data to double precision
save('data1.mat', 'data1'); % Save the filtered data for later use

% Calculate parameters for Gaussian smoothing
SSA = (grm2 / 15.2) - mod((grm2 / 15.2), 2) + 1; % Determine SSA value
fsize = round(grm2 / 2); % Define filter size
H = fspecial('gaussian', fsize, round(grm2 / 2)); % Create Gaussian filter
blurreddata1 = imfilter(data1, H, 'symmetric'); % Apply Gaussian filter

% Compute slope and aspect of the blurred data
[Asp, Slope] = getSlopeAndAspect(blurreddata1, SSA, SSA);
[~, DSlope] = getSlopeAndAspect(Slope, SSA, SSA);
[DAspect] = getSlopeOfAspect(Asp, SSA, SSA);

% Further smooth the derived slope and aspect data
FDSlope = imfilter(DSlope, H, 'replicate');
FDAspect = imfilter(DAspect, H, 'replicate');

% Compute the fault enhancement image
I = (Slope.^2 .* FDSlope.^1 .* FDAspect.^1).^(1/4);

% Define parameters for step filtering
grammes = grm2; % Step filter width
Step_Filter_nAng = GSF_Angles; % Number of angles
Step_Filter_step = pi / Step_Filter_nAng; % Angle step size
Step_Filter_DTheta = 0:Step_Filter_step:pi - Step_Filter_step; % Array of angles
Step_Filter_Dbw = [2 4 6]; % Array of main wave widths

% Apply step filtering to the fault enhancement image
[Y] = step_Filtering(I, grammes, Step_Filter_DTheta, Step_Filter_Dbw, 1);

% Detect faults in the filtered image
[BW, plotSkel] = getFaultDetection(Y, data1);

% Detect strong faults
BWorig = BW; % Original binary image of faults
C = bwconncomp(BW); % Identify connected components
RS = regionprops(C, 'Area', 'Orientation', 'Centroid'); % Extract properties of regions
L = length(RS); % Number of regions
area = [RS(1:L).Area]; % Area of each region
Map = bwlabel(BW, 8); % Label connected components

% Extract pixel values for each region
RS_Y = regionprops(C, Y, 'PixelValues');

% Initialize feature matrix
feat = zeros(L, 2);

% Calculate features for each region
for i = 1:L
    vec = RS_Y(i).PixelValues;
    feat(i, 1) = sum(vec); % Sum of pixel values
end
feat(:, 2) = feat(:, 1); % Duplicate the feature values
sv = sort(feat(:, 1), 'descend'); % Sort the features in descending order

% Determine the number of faults to select
NUMBER_OF_Faults = round(0.85 * length(sv));
Thresh = sv(NUMBER_OF_Faults); % Threshold for selecting faults
Labels = find(feat(:, 1) >= Thresh); % Labels of selected faults

% Plot detected regions on depth
[plotH] = plotNewColorMap0(Y, Y, Map, Labels, 'Detected Lineaments', YI(:), XI(:));

end
