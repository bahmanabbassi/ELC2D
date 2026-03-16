% STEP_FILTERING - Perform step filtering on the input image using Gabor filters.
%
% This function applies Gabor filters at different scales and orientations to detect lineaments
% in the input image. The maximum response across all filters is taken as the final result.
%
% Syntax:
%    [Y] = step_Filtering(I, grammes, DTheta, DPaxos, typeOfFilter)
%
% Inputs:
%    I - Input image.
%    grammes - Size of the filter.
%    DTheta - Vector of angles for filter orientations.
%    DPaxos - Vector of filter widths.
%    typeOfFilter - Type of filter to use (1 for regular, otherwise smooth).
%
% Outputs:
%    Y - Filtered image.

function [Y] = step_Filtering(I, grammes, DTheta, DPaxos, typeOfFilter)

    gabors = length(DTheta);   % Number of Gabor filter orientations
    gabors2 = length(DPaxos);  % Number of Gabor filter widths

    % Apply Gabor filters
    for j = 1:gabors2
        bw = DPaxos(j);  % Filter width
        
        for i = 1:gabors
            theta = DTheta(i);  % Filter orientation
            if typeOfFilter == 1
                gb = mask_fn(grammes, bw, theta, 0);
            else
                gb = mask_fn_smooth(grammes, bw, theta, 0);
            end
            gb = gb / sqrt(sum(sum(gb.^2)));  % Normalize filter energy

            G = conv2(I, gb, 'same');  % Convolve filter with image
            if i == 1 && j == 1
                Y = G;
            else
                Y = max(Y, G);
            end
        end
    end

    % Zero out the edges of the image
    del = 8;
    Y(1:del, :) = 0;
    Y(:, 1:del) = 0;
    Y(size(I, 1)-[0:del-1], :) = 0;
    Y(:, size(I, 2)-[0:del-1]) = 0;

end

% MASK_FN - Generate a Gabor filter.
%
% This function creates a Gabor filter with specified size, width, and orientation.
%
% Syntax:
%    gb = mask_fn(grammes, bw, theta, toPlot)
%
% Inputs:
%    grammes - Size of the filter.
%    bw - Filter width.
%    theta - Filter orientation.
%    toPlot - Flag to indicate whether to plot the filter (1 for yes, 0 for no).
%
% Outputs:
%    gb - Generated Gabor filter.

function gb = mask_fn(grammes, bw, theta, toPlot)

    sz = grammes;
    if mod(sz, 2) == 0, sz = sz + 1; end

    [x, y] = meshgrid(-fix(sz/2):1:fix(sz/2), fix(sz/2):-1:fix(-sz/2));

    % Rotation
    x_theta = x * cos(theta) + y * sin(theta);
    y_theta = -x * sin(theta) + y * cos(theta);

    % Create Gabor filter
    for i = 1:length(x)
        for j = 1:length(y)
            d = abs(x_theta(i, j));
            u = x_theta(i, j);
            v = y_theta(i, j);
            gb(i, j) = 0;
            if d < bw
                gb(i, j) = 1;
            elseif d <= 3 * bw
                gb(i, j) = -1;
            end
        end
    end

    [n1, n2] = find(gb == -1);
    [p1, p2] = find(gb == 1);

    nv_n1 = -length(p1) / length(n1);

    for i = 1:length(n1)
        gb(n1(i), n2(i)) = nv_n1;
    end

    gb = gb / sum(sum(gb.^2));

    if toPlot == 1
        mean(mean(gb));
    end

end

% MASK_FN_SMOOTH - Generate a smooth Gabor filter.
%
% This function creates a smooth Gabor filter with specified size, width, and orientation.
%
% Syntax:
%    gb = mask_fn_smooth(grammes, bw, theta, toPlot)
%
% Inputs:
%    grammes - Size of the filter.
%    bw - Filter width.
%    theta - Filter orientation.
%    toPlot - Flag to indicate whether to plot the filter (1 for yes, 0 for no).
%
% Outputs:
%    gb - Generated smooth Gabor filter.

function gb = mask_fn_smooth(grammes, bw, theta, toPlot)

    sz = grammes;
    if mod(sz, 2) == 0, sz = sz + 1; end

    [x, y] = meshgrid(-fix(sz/2):1:fix(sz/2), fix(sz/2):-1:fix(-sz/2));

    % Rotation
    x_theta = x * cos(theta) + y * sin(theta);
    y_theta = -x * sin(theta) + y * cos(theta);

    % Create smooth Gabor filter
    for i = 1:length(x)
        for j = 1:length(y)
            d = abs(x_theta(i, j));
            u = x_theta(i, j);
            v = y_theta(i, j);
            gb(i, j) = 0;
            if d < bw
                gb(i, j) = 1 - ((d / bw)^2);
            elseif d <= 3 * bw
                gb(i, j) = 0.5 * (-1 + (((d / bw) - 2)^2));
            end
        end
    end

    [u1, v1] = find(gb > 0);
    [u2, v2] = find(gb < 0);

    m1 = 0;
    N1 = length(u1);
    for i = 1:length(u1)
        m1 = m1 + gb(u1(i), v1(i));
    end
    m1 = m1 / N1;

    m2 = 0;
    N2 = length(u2);
    for i = 1:length(u2)
        m2 = m2 + gb(u2(i), v2(i));
    end
    m2 = m2 / N2;

    c = -m1 * N1 / (m2 * N2);

    for i = 1:length(u2)
        gb(u2(i), v2(i)) = c * gb(u2(i), v2(i));
    end

    gb = gb / sum(sum(gb.^2));

    if toPlot == 1
        mean(mean(gb));
    end

end
