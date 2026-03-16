function [Grid2, plt1, plt2] = Lineaments_All(Grid, numberoffeatures, sigma2)
% LINEAMENTS_ALL - Detect and visualize lineaments in a grid of features.
%
% This function processes multiple features in the input grid to detect lineaments.
% It applies Gaussian filtering to each feature, computes variances, and visualizes the results.
%
% Syntax:
%    [Grid2, plt1, plt2] = Lineaments_All(Grid, numberoffeatures, sigma2)
%
% Inputs:
%    Grid              - 3D matrix (height x width x numberoffeatures) of input features.
%    numberoffeatures  - Number of features to process.
%    sigma2            - Standard deviation for Gaussian filtering.
%
% Outputs:
%    Grid2             - Filtered grid.
%    plt1              - Number of subplot rows for visualization.
%    plt2              - Number of subplot columns for visualization.


    disp('-------------------------------------')
    pause(0.01);



    % Determine subplot layout
    plt1 = ceil(sqrt(numberoffeatures));
    plt2 = plt1;

    % Declare global variables
    global XI
    global YI
    global YI_Real_Ratio
    global xv
    global yv
    global grm
    global grm2
    global curv

    % Initialize variances array
    vari1 = zeros(1, numberoffeatures);

    % Process each feature in the grid
    for tttt6 = 1:numberoffeatures
        % Extract the current feature
        Grid0 = (Grid(:,:,tttt6));           
        % Apply Gaussian filtering
        Grid2 = FilterB(Grid0, sigma2);
        % Replace NaN values with 0
        Grid2(isnan(Grid2)) = 0;
        % Compute variance of the filtered feature
        vari1(tttt6) = 1 / var(double(Grid2(:)));
        % Standardize variances
        vari1_std = zscore(vari1);
    end

    % Create figure for lineaments visualization
    f5 = figure(5);
    f5.Name = 'All Lineaments';
    f5.WindowState = 'maximized';

    % Initialize vector for step filtering widths
    grm2_vector = zeros(1, numberoffeatures);

    % Initialize total number of faults
    Total_Faults = 0;

    % Process each feature again for visualization

    for tttt6 = 1:numberoffeatures
        % Extract and filter the current feature
        Grid0 = (Grid(:,:,tttt6));
        Grid2 = FilterB(Grid0, sigma2);
        Grid2(isnan(Grid2)) = 0;

        % Calculate step filtering width
        grm2 = round(grm + (curv * grm) * vari1_std(tttt6));
        if grm2 <= 1
            grm2 = 1;
        end
        grm2_vector(tttt6) = grm2;

        % Create subplot for the current feature
        subplot(plt1, plt2, tttt6), 
        plot(XI, YI)

        % Detect lineaments
        plotH = Lineaments0(Grid2);

       [plotH_, Number_Of_Faults ] = Lineaments0_(Grid2);

% Display the number of faults for this feature
    disp(['Number of Faults for Feature ', num2str(tttt6), ': ', num2str(Number_Of_Faults)])


Total_Faults = Total_Faults + Number_Of_Faults ;


        % Binarize and complement the detected lineaments
        plotH00 = (plotH_(:,:,1) + plotH_(:,:,2) + plotH_(:,:,3)) / 3;
        plotH00 = imbinarize(plotH00);
        plotH00 = imcomplement(plotH00);
        plotH0(:,:,tttt6) = plotH00;          

        % Display the detected lineaments
        image(plotH, 'XData', [min(XI(:)) max(XI(:))], 'YData', [min(YI(:)) max(YI(:))]);
        title(['Lineaments, # ', num2str(tttt6)])
        subtitle(['Step Filtering Width = ', num2str(grm2)])
        box on
        set(gca, 'TickDir', 'out', 'linewidth', 1, 'Layer', 'top');
        colormap jet;
        set(gca, 'YDir', 'normal')
        shading interp
        view(0, 90)
        grid off
        daspect([YI_Real_Ratio 1 1])
    end


    % Display vertical dots
    disp('.')
    pause(0.01);
    disp('.')
    pause(0.01);
    disp('.')
    pause(0.01);

    % Display the total number of faults
    disp(['Total Number of Detected Faults: ', num2str(Total_Faults)]);

    
    % Create figure for curvilinearity control
    f6 = figure(6);
    f6.Name = 'Curvilinearity Control';
    grm2_vector_s = size(grm2_vector); 
    grm2_vector_s = grm2_vector_s(1, 2);
    x_ax = 1:1:grm2_vector_s;
    bar(x_ax, grm2_vector, 'black')
    text(x_ax, grm2_vector, num2str(grm2_vector'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')

    title(['Average Step Filtering Width = ', num2str(mean(grm2_vector))])
    subtitle(['Starting Step Filtering Width = ', num2str(grm)])
    box on
    set(gca, 'TickDir', 'out', 'linewidth', 1, 'Layer', 'top');
    curtick = get(gca, 'xTick');
    xticks(unique(round(curtick)));
    xlabel('Features') 
    ylabel('Min D') 
    ylim([0, (max(grm2_vector) + 0.1 * max(grm2_vector))])
    colormap jet;
    set(gca, 'YDir', 'normal')
    shading interp
    view(0, 90)
    grid off

    % Initialize fused lineaments image
    plotH1 = zeros(size(plotH_));

    % Fuse all detected lineaments
    for n = 1:numberoffeatures
        plotH1 = imfuse(plotH1, plotH0(:,:,n), 'blend');
        plotH1 = imbinarize(plotH1);
    end

    % Store fused lineaments image as global variable
    global plotH1_rgb 
    plotH1_rgb = im2double(plotH1);

    % Create figure for stacked lineaments
    f7 = figure(7);
    f7.Name = 'All Lineaments Stacked';
    f7.WindowState = 'maximized';
    plot(XI, YI)

    % Display the fused lineaments image
    image(plotH1_rgb, 'XData', [min(XI(:)) max(XI(:))], 'YData', [min(YI(:)) max(YI(:))]);
    title('All Lineaments Stacked')
    box on
    set(gca, 'TickDir', 'out', 'linewidth', 1, 'Layer', 'top');
    colormap jet;
    set(gca, 'YDir', 'normal')
    shading interp
    view(0, 90)
    grid off
    set(gcf, 'GraphicsSmoothing', 'on')
    h.AlignVertexCenters = 'on';
    daspect([YI_Real_Ratio 1 1])
end
