function [BW_object, plotSkel] = getFaultDetection(z, z_orig)
% GETFAULTDETECTION - Detect faults in the input image using hysteresis thresholding.
%
% This function detects faults in the input image z by applying hysteresis
% thresholding to create a binary map and visualizes the detected faults.
%
% Syntax:
%    [BW_object, plotSkel] = getFaultDetection(z, z_orig)
%
% Inputs:
%    z      - Input 2D matrix (image) to be analyzed.
%    z_orig - Original 2D matrix (image) for visualization.
%
% Outputs:
%    BW_object - Binary map of detected faults.
%    plotSkel  - RGB image with detected faults projected on the original data.
%
% Example:
%    [BW_object, plotSkel] = getFaultDetection(image, original_image);

% Initialize the image to be processed
rotI = z;
z = rotI;

% Apply hysteresis thresholding to create a binary map
BW = binarize(z);
BW_object = BW;

% Normalize original image for visualization
normal = max(max(z));
par = max(max(z_orig)) - min(min(z_orig));
plotH(:,:,1) = (z_orig - min(min(z_orig))) / par;
plotH(:,:,2) = (z_orig - min(min(z_orig))) / par;
plotH(:,:,3) = (z_orig - min(min(z_orig))) / par;

% Overlay detected faults on the original image
for i = 1:size(BW, 1)
    for j = 1:size(BW, 2)
        if BW(i, j) > 0
            plotH(i, j, 1) = abs(z(i, j)) / normal;
            plotH(i, j, 2) = 0;
            plotH(i, j, 3) = 1 - abs(z(i, j)) / normal;
        end
    end
end
plotSkel = plotH;

% Reset plotH for skeleton visualization
plotH(:,:,1) = ones(size(z_orig, 1), size(z_orig, 2));
plotH(:,:,2) = ones(size(z_orig, 1), size(z_orig, 2));
plotH(:,:,3) = ones(size(z_orig, 1), size(z_orig, 2));

for i = 1:size(BW, 1)
    for j = 1:size(BW, 2)
        if BW(i, j) > 0
            plotH(i, j, 1) = abs(z(i, j)) / normal;
            plotH(i, j, 2) = 0;
            plotH(i, j, 3) = 1 - abs(z(i, j)) / normal;
        end
    end
end

% Uncomment the following lines to display the images
% figure;
% imagesc(plotH);
% title('Detected skeleton');

end

% Helper function for hysteresis thresholding
function [B1] = binarize(z)
% BINARIZE - Apply hysteresis thresholding to create a binary map.
%
% This function applies hysteresis thresholding to the input image z,
% creating a binary map of detected features.
%
% Inputs:
%    z - Input 2D matrix (image) to be thresholded.
%
% Outputs:
%    B1 - Binary map of detected features.
%
% Algorithm steps:
% 1. Non-maxima suppression
% 2. Hysteresis thresholding

apo = 2;
B = zeros(size(z));

% Flatten and sort the image values
allD = reshape(z, 1, numel(z));
allD = sort(allD, 'descend');
Tr = allD(round(0.25 * numel(z)));

% Initial binarization based on threshold
for i = apo:size(z, 1)-apo
    for j = apo:size(z, 2)-apo
        temp = reshape(z(i-1:i+1, j-1:j+1), 1, 9);
        st = sort(temp, 'descend');
        if z(i, j) > Tr
            if (z(i, j) == st(4) || z(i, j) == st(3))
                B(i, j) = -1;
            elseif (z(i, j) >= st(2))
                B(i, j) = 1;
            end
        end
    end
end

% Calculate high and low thresholds
[Sx, Sy] = find(B == 1);
y = arrayfun(@(i) z(Sx(i), Sy(i)), 1:length(Sx));
T_high = mean(y);

[Sx, Sy] = find(B == -1);
y = arrayfun(@(i) z(Sx(i), Sy(i)), 1:length(Sx));
T_low = mean(y);

% Refine the binarization
B = -2 * ones(size(z));

for i = apo:size(z, 1)-apo
    for j = apo:size(z, 2)-apo
        temp = reshape(z(i-1:i+1, j-1:j+1), 1, 9);
        st = sort(temp, 'descend');
        if z(i, j) <= T_low
            B(i, j) = -2;
        elseif z(i, j) >= T_high && (z(i, j) >= st(2))
            B(i, j) = 1;
        elseif (z(i, j) < st(4))
            B(i, j) = -1;
        else
            B(i, j) = 0;
        end
    end
end


% Propagate high values
while true
    [Sx, Sy] = find(B == 0);
    change = 0;
    for i = 1:length(Sx)
        x = Sx(i);
        y = Sy(i);   
        if any(any(B(x-1:x+1, y-1:y+1) == 1))
            B(x, y) = 1;
            change = change + 1;
        end        
    end
    if change == 0
        break;
    end
end

% Set negative values to 0
B(B < 0) = 0;
B1 = B;

end
