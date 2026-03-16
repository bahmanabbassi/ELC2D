function PlaceThresholdBars(plotNumber, lowThresh, highThresh)
% PLACETHRESHOLDBARS - Add threshold bars to a specified subplot.
%
% This function adds vertical bars at specified low and high threshold
% values on a histogram plot. The thresholds are indicated with black lines
% and labeled with their respective values.
%
% Syntax:
%    PlaceThresholdBars(plotNumber, lowThresh, highThresh)
%
% Inputs:
%    plotNumber - The index of the subplot where the thresholds will be added.
%    lowThresh - The lower threshold value.
%    highThresh - The higher threshold value.
%
% Description:
%    The function adds vertical lines at the specified threshold values on
%    the histogram plot identified by 'plotNumber'. The lines are labeled
%    with the threshold values for clarity.

try
    % Select the specified subplot
    subplot(1, 3, plotNumber);
    hold on;
    
    % Get the current y-axis range values
    yAxisRangeValues = ylim;
    
    % Draw vertical lines at the low and high threshold values
    line([lowThresh, lowThresh], yAxisRangeValues, 'Color', 'k', 'LineWidth', 2);
    line([highThresh, highThresh], yAxisRangeValues, 'Color', 'k', 'LineWidth', 2);
    
    % Define the font size for the threshold labels
    fontSizeThresh = 14;
    
    % Create annotation texts for the low and high thresholds
    annotationTextL = sprintf('%d', lowThresh);
    annotationTextH = sprintf('%d', highThresh);
    
    % Add text labels near the threshold lines on the plot
    text(double(lowThresh + 5), double(0.85 * yAxisRangeValues(2)), annotationTextL, ...
         'FontSize', fontSizeThresh, 'Color', [0 0 0], 'FontWeight', 'Bold');
    text(double(highThresh + 5), double(0.85 * yAxisRangeValues(2)), annotationTextH, ...
         'FontSize', fontSizeThresh, 'Color', [0 0 0], 'FontWeight', 'Bold');
    
    % Note: Arrows to show the range are not implemented in this code.
    % Attempted but not working with either gca or gcf.
    %  annotation(gca, 'arrow', [lowThresh/maxXValue(2) highThresh/maxXValue(2)],[0.7 0.7]);
catch ME
    % Handle errors by displaying an error dialog with traceback information
    callStackString = GetCallStack(ME);
    errorMessage = sprintf('Error in program %s.\nTraceback (most recent at top):\n%s\nError Message:\n%s', ...
                           mfilename, callStackString, ME.message);
    errordlg(errorMessage);
end

return; % from PlaceThresholdBars()
