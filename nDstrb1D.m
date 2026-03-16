function ImD4 = nDstrb1D(ImD0)
% NDSTRB1D - Normalize and distribute 1D image data.
%
% This function normalizes the input image data by adjusting its mean and
% standard deviation, then applies a logarithmic transformation and histogram 
% equalization to enhance the distribution of the pixel values.
%
% Syntax:
%    ImD4 = nDstrb1D(ImD0)
%
% Inputs:
%    ImD0 - Input 1D image data as a matrix.
%
% Outputs:
%    ImD4 - Processed image data with enhanced distribution.
%
% Description:
%    The function iteratively adjusts the input image data's mean and standard
%    deviation, then applies a logarithmic transformation and histogram equalization.
%    The iteration stops when the standard deviation of the processed image data
%    falls within the desired range [0.25, 0.3].

% Calculate the standard deviation and mean of the input image data
ImD0_STD = std(ImD0(:));
ImD0_Mean = mean(ImD0(:));

% Iterate to adjust and enhance the image data
for i = 1:100
    % Normalize the image data by subtracting the mean and dividing by
    % a scaled standard deviation
    ImD1 = (ImD0 - ImD0_Mean) ./ (i * ImD0_STD);
    
    % Shift the normalized data to be non-negative and scale it
    ImD2 = -min(ImD1(:)) + ImD1 + (i * std(ImD1(:)));
    
    % Apply a logarithmic transformation to the data
    ImD3 = log10(ImD2);
    
    % Apply histogram equalization to enhance the distribution of pixel values
    ImD4 = histeq(ImD3) + realmin;
    
    % Calculate the standard deviation of the processed image data
    ImD4_STD = std(ImD4(:));
    
    % Check if the standard deviation falls within the desired range
    if (ImD4_STD > 0.25) && (ImD4_STD < 0.3)
        break
    end
end
