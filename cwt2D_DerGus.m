function [Fe_All, Fe] = cwt2D_DerGus(CWT_Input_Features_Matrix, Scales, Angles, orderx, ordery, Sigma3, valu_auto)
% CWT2D_DERGUS - Compute 2D Continuous Wavelet Transform with derivative of Gaussian wavelets.
%
% Syntax:
%    [Fe_All, Fe] = cwt2D_DerGus(CWT_Input_Features_Matrix, Scales, Angles, orderx, ordery, Sigma3, valu_auto)
%
% Inputs:
%    CWT_Input_Features_Matrix - Input matrix of features.
%    Scales - Array of scales for the wavelet transform.
%    Angles - Array of angles for the wavelet transform.
%    orderx - Order of derivative in x direction.
%    ordery - Order of derivative in y direction.
%    Sigma3 - Standard deviation for Gaussian smoothing.
%    valu_auto - Flag for automatic mode (0 or 1).
%
% Outputs:
%    Fe_All - Feature matrix for all scales and angles.
%    Fe - Feature matrix for each feature.
%
% Example:
%    [Fe_All, Fe] = cwt2D_DerGus(features, scales, angles, 1, 0, 1.5, 0);

global XI YI
global N_Scales N_Angles
global N_Fs

% Clear temporary variables
clear Feature cwtmor cwtout cwtout_abs WL WL2 WLFs Fe Fe_All WLFs_allscales WLFs_allangles

% Mode: valu_auto == 0 (Default mode)
if valu_auto == 0
    for kkk = 1:N_Fs
        Feature = CWT_Input_Features_Matrix(:,:,kkk);
        tX = fft2(double(Feature)); % Precompute FFT
        cwtmor = cwt2d(tX, 'dergauss2d', Scales, Angles, orderx, ordery);
        cwtout = cwtmor.data; % CWT output
        cwtout_abs = abs(cwtout);

        for jj = 1:N_Scales
            for jjj = 1:N_Angles
                WL = cwtout_abs(:,:,jj,jjj);
                if Sigma3 > 0
                    WL2 = imgaussfilt(WL, Sigma3 * Scales(jj)); % Apply Gaussian smoothing
                else
                    WL2 = WL;
                end
                WLFs(:,(jj-1) * N_Angles + jjj) = cat(3,WL2(:));
            end
        end
        Fe(:,:,kkk) = WLFs;
    end
else % Mode: valu_auto == 1 (Automatic mode)
    for kkk = 1:N_Fs
        Feature = CWT_Input_Features_Matrix(:,:,kkk);
        tX = fft2(double(Feature)); % Precompute FFT

        for jj = 1:N_Angles
            for jjj = 1:N_Scales
                % Set derivative orders based on scale
                switch jjj
                    case N_Scales
                        orderx = 1; ordery = 0;
                    case N_Scales - 1
                        orderx = 2; ordery = 0;
                    case N_Scales - 2
                        orderx = 1; ordery = 1;
                    case N_Scales - 3
                        orderx = 2; ordery = 1;
                    case N_Scales - 4
                        orderx = 2; ordery = 2;
                end

                % Determine angle increments
                if orderx == ordery
                    betad = 90;
                else
                    betad = 180;
                end
                Angles = linspace(betad/N_Angles - betad/N_Angles, betad - betad/N_Angles, N_Angles);

                cwtmor = cwt2d(tX, 'dergauss2d', jjj, Angles(jj), orderx, ordery);
                cwtout = cwtmor.data; % CWT output
                WL = abs(cwtout);

                if Sigma3 > 0
                    WL2 = imgaussfilt(WL, Sigma3 * Scales(jjj)); % Apply Gaussian smoothing
                else
                    WL2 = WL;
                end
                WLFs(:,(jj-1) * N_Scales + jjj) = cat(3,WL2(:));
            end
        end
        Fe(:,:,kkk) = WLFs;
    end
end

% Visualization of wavelets
f2 = figure(2);
f2.Name  = 'Mother Wavelet in Position Domain';
movegui(f2, [50, 540]);
yashow_cwt2d(cwtmor, 'filter', 'pos');
grid on;

f3 = figure(3);
f3.Name  = 'Mother Wavelet in Frequency Domain';
movegui(f3, [650, 540]);
yashow_cwt2d(cwtmor, 'filter');

f4 = figure(4);
f4.Name  = 'Mother Wavelet in Frequency Domain (3D View)';
movegui(f4, [1250, 540]);
yashow_cwt2d(cwtmor, 'filter', 'surf');

% Detailed Feature Extraction
if valu_auto == 0
    for kkk = 1:N_Fs
        Feature = CWT_Input_Features_Matrix(:,:,kkk);
        tX = fft2(double(Feature)); % Precompute FFT
        cwtmor = cwt2d(tX, 'dergauss2d', Scales, Angles, orderx, ordery);
        cwtout = cwtmor.data; % CWT output
        cwtout_abs = abs(cwtout);

        for jj = 1:N_Angles
            for jjj = 1:N_Scales
                WL = cwtout_abs(:,:,jjj,jj);
                if Sigma3 > 0
                    WL2 = imgaussfilt(WL, Sigma3 * jjj); % Apply Gaussian smoothing
                else
                    WL2 = WL;
                end
                WLFs_allscales(:,:,jjj) = WL2;
            end
            WLFs_allangles(:,:,:,jj) = WLFs_allscales;
        end
        Fe_All(:,:,:,:,kkk) = WLFs_allangles;
    end
else
    for kkk = 1:N_Fs
        Feature = CWT_Input_Features_Matrix(:,:,kkk);
        tX = fft2(double(Feature)); % Precompute FFT

        for jj = 1:N_Angles
            for jjj = 1:N_Scales
                % Set derivative orders based on scale
                switch jjj
                    case N_Scales
                        orderx = 1; ordery = 0;
                    case N_Scales - 1
                        orderx = 2; ordery = 0;
                    case N_Scales - 2
                        orderx = 1; ordery = 1;
                    case N_Scales - 3
                        orderx = 2; ordery = 1;
                    case N_Scales - 4
                        orderx = 2; ordery = 2;
                end

                % Determine angle increments
                if orderx == ordery
                    betad = 90;
                else
                    betad = 180;
                end
                Angles = linspace(betad/N_Angles - betad/N_Angles, betad - betad/N_Angles, N_Angles);

                cwtmor = cwt2d(tX, 'dergauss2d', jjj, Angles(jj), orderx, ordery);
                cwtout = cwtmor.data; % CWT output
                WL = abs(cwtout);

                if Sigma3 > 0
                    WL2 = imgaussfilt(WL, Sigma3 * jjj); % Apply Gaussian smoothing
                else
                    WL2 = WL;
                end
                WLFs_allscales(:,:,jjj) = WL2;
            end
            WLFs_allangles(:,:,:,jj) = WLFs_allscales;
        end
        Fe_All(:,:,:,:,kkk) = WLFs_allangles;
    end
end
