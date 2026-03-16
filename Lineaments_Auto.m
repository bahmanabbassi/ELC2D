function [fbeta_score, N_CWT] = Lineaments_Auto(CWT_Input_Features_Matrix, N_Scales, Scale_D, Sigma3, N_Angles, orderx, ordery, D_Reduct, Line_Res, SF_W, SF_Angles, curv, valu_auto)

% N_Scales
% Scale_D
% Sigma3
% D_Reduct
% SF_W



% LINEAMENTS_AUTO - Automatically detect and tune lineament detection algorithm hyperparameters with  Bayesian optimization.
%
% This function processes the input features using Continuous Wavelet Transform (CWT),
% dimensionality reduction, and fault detection techniques to detect lineaments and incorporation  Bayesian optiomization techniques to fine-tune the underlying parameters.
% It incorporates the F-beta score for the detected lineaments as a measure for optimization.
%
% Syntax:
%    [fbeta_score, N_CWT] = Lineaments_Auto(CWT_Input_Features_Matrix, N_Scales, Scale_D, Sigma3, N_Angles, orderx, ordery, D_Reduct, Line_Res, SF_W, SF_Angles, curv, valu_auto)
%
% Inputs:
%    CWT_Input_Features_Matrix - Input feature matrix.
%    N_Scales - Number of scales for CWT.
%    Scale_D - Scale difference.
%    Sigma3 - Sigma value for Gaussian filtering.
%    N_Angles - Number of angles for CWT.
%    orderx - Order of the derivative in x direction.
%    ordery - Order of the derivative in y direction.
%    D_Reduct - Dimensionality reduction parameter.
%    Line_Res - Resolution for lineaments.
%    SF_W - Step filter width.
%    SF_Angles - Step filter angles.
%    curv - Curvature parameter.
%    valu_auto - Automatic value flag.
%
% Outputs:
%    fbeta_score - F-beta score for the detected lineaments.
%    N_CWT - Number of CWT features.

% Declare global variables
global XI
global YI
global Y_Pix
global X_Pix
global N_Fs

% Determine the beta angle for the CWT based on the derivative orders
if orderx == ordery
    betad = 90;
else
    betad = 180;
end

% Calculate scales and angles for the CWT
Scales = 1:Scale_D:(N_Scales * Scale_D);
Angless = betad/(N_Angles) - betad/(N_Angles)  :betad/(N_Angles) : betad - betad/(N_Angles);
Angles = Angless * pi / 180;

% Determine the number of features
if ndims(CWT_Input_Features_Matrix) == 2
    N_Fs = 1;
elseif ndims(CWT_Input_Features_Matrix) == 3
    CWT_Input_Features_Matrix_Size = size(CWT_Input_Features_Matrix);
    N_Fs = CWT_Input_Features_Matrix_Size(3);
end

% Calculate the total number of CWT features
N_CWT = N_Scales * N_Angles * N_Fs;

% Initialize the feature matrix
Fe = zeros(size(CWT_Input_Features_Matrix, 1) * size(CWT_Input_Features_Matrix, 2), N_Scales * N_Angles, N_Fs);

% Perform CWT on the input features
if valu_auto == 0
    for kkk = 1: N_Fs 
        Feature = CWT_Input_Features_Matrix(:,:,kkk);
        tX = fft2(double(Feature)); % Precompute FFT
        cwtmor = cwt2d(tX, 'dergauss2d', Scales, Angles, orderx, ordery);
        cwtout = cwtmor.data; % X-Y-Scales-Angles
        cwtout_abs = abs(cwtout);
        
        for jj = 1:N_Scales
            for jjj = 1 : N_Angles
                WL = cwtout_abs(:,:,jj,jjj); 
                if Sigma3 > 0
                    WL2 = imgaussfilt(WL, Sigma3 * Scales(jj)); 
                else
                    WL2 = WL;
                end
                WLFs(:, (jj-1) * N_Angles + jjj) = cat(3, WL2(:));
            end
        end
        Fe(:,:,kkk) = WLFs;
    end
else
    for kkk = 1: N_Fs 
        Feature = CWT_Input_Features_Matrix(:,:,kkk);
        tX = fft2(double(Feature));

        for jj = 1 : N_Angles
            for jjj = 1 : N_Scales

                if jjj == N_Scales
                    orderx = 1;
                    ordery = 0;
                elseif jjj == N_Scales -1
                    orderx = 2;
                    ordery = 0;
                elseif jjj == N_Scales -2
                    orderx = 1;
                    ordery = 1;
                elseif jjj == N_Scales -3
                    orderx = 2;
                    ordery = 1;              
                elseif jjj == N_Scales -4
                    orderx = 2;
                    ordery = 2;
                end

                if orderx == ordery
                    betad = 90;
                else
                    betad = 180;
                end

                Angles = betad/(N_Angles) - betad/(N_Angles)  :betad/(N_Angles) : betad - betad/(N_Angles);
                cwtmor = cwt2d(tX, 'dergauss2d', jjj, Angles(jj), orderx, ordery);
                cwtout = cwtmor.data;
                WL = abs(cwtout);
                
                if Sigma3 > 0
                    WL2 = imgaussfilt(WL, Sigma3 * Scales(jjj)); 
                else
                    WL2 = WL;
                end
                WLFs(:, (jj-1) * N_Scales + jjj) = cat(3, WL2(:));
            end
        end
        Fe(:,:,kkk) = WLFs;
    end
end

% Reshape the feature matrix for dimensionality reduction
for fss = 1:N_Fs
    Fs(:, ((fss-1)*(N_Scales*N_Angles)+1):fss*(N_Scales*N_Angles)) = Fe(:,:,fss);
end

Size_Fs = size(Fs);

for ss = 1:Size_Fs(2)
    Fs0(:,ss) = nDstrb1D(Fs(:,ss));
end

for ss = 1:N_CWT
    Fs_(:,:,ss) = griddata(XI(:), YI(:), Fs0(:,ss), XI, YI, 'nearest'); 
    global xv
    global yv
    in = inpolygon(XI, YI, xv, yv);
    Fs_ = in .* Fs_;
    Fs_(Fs_ == 0) = NaN; 
end

% Perform PCA on the CWT features
for vvv = 1:N_CWT
    Fs_2d_3 = Fs_(:,:,vvv); Fs_2d_3 = Fs_2d_3(:);
    Fs_2d_4(:, vvv) = Fs_2d_3(:);
end

CWT_Features_Columns = Fs_2d_4;

global XI_G
global YI_G

CWT_Features_Columns_PPP = [XI(:) YI(:) CWT_Features_Columns]; 
CWT_Features_Columns_PPP(any(isnan(CWT_Features_Columns_PPP), 2), :) = []; % Removing the NaNs

XI_G = CWT_Features_Columns_PPP(:, 1); 
YI_G = CWT_Features_Columns_PPP(:, 2);
CWT_Features_Columns = CWT_Features_Columns_PPP(:, 3:end);

% Perform S-PCA (Spectral-PCA)
CWT_Features_Columns_Size = size(CWT_Features_Columns);
if D_Reduct <= CWT_Features_Columns_Size(2)
    [S_PCA_pp0, U, mu] = PCA(CWT_Features_Columns', D_Reduct);
end

S_PCA_pp00 = S_PCA_pp0';

for ss = 1:D_Reduct
    S_PCA_pp(:, ss) = nDstrb1D(S_PCA_pp00(:, ss));
end

siu = size(XI);
S_PCA_pp_Grid = zeros(siu(1), siu(2), D_Reduct); 

for ss = 1:D_Reduct
    S_PCA_pp_Grid(:,:,ss) = griddata(XI_G(:), YI_G(:), S_PCA_pp(:,ss), XI, YI, 'nearest');  
    global xv
    global yv
    in = inpolygon(XI, YI, xv, yv);
    S_PCA_pp_Grid = in .* S_PCA_pp_Grid;
    S_PCA_pp_Grid(S_PCA_pp_Grid == 0) = NaN;    
end

Spectral_PCA_Features_Matrix = S_PCA_pp_Grid;

% Extract lineaments using the PCA features
All_Inputs = Spectral_PCA_Features_Matrix;

originalArrayNoNaNPages = All_Inputs;
nanPageIndices = all(all(isnan(originalArrayNoNaNPages), 1), 2);
originalArrayNoNaNPages(:,:,nanPageIndices) = [];

originalArrayNoNaNPages_Size = size(originalArrayNoNaNPages);

if ndims(originalArrayNoNaNPages) == 2
    Number_of_Features_used_for_Lineaments_Detection = 1;
elseif ndims(originalArrayNoNaNPages) == 3
    Number_of_Features_used_for_Lineaments_Detection = originalArrayNoNaNPages_Size(3);
end

global grm
grm = SF_W; 
global GSF_Angles
GSF_Angles = SF_Angles;

global sigma2
Grid = originalArrayNoNaNPages;
numberoffeatures = Number_of_Features_used_for_Lineaments_Detection;

for ttt6 = 1:numberoffeatures
    Grid0_ = (Grid(:,:,ttt6));           
    Grid2_ = FilterB(Grid0_, sigma2); Grid2_(isnan(Grid2_)) = 0;
    vari1(ttt6) = 1 / var(double(Grid2_(:)));
    vari1_std = zscore(vari1);
end

for tttt6 = 1:numberoffeatures
    Grid0 = Grid(:,:,tttt6);
    Grid2 = FilterB(Grid0, sigma2); Grid2(isnan(Grid2)) = 0;
    grm2 = round(grm + (curv * grm) * vari1_std(tttt6));

    if grm2 <= 1
        grm2 = 1;
    end

    Griddddd = imresize(Grid2, Line_Res / min(X_Pix, Y_Pix));
    data1 = FilterB(Griddddd, sigma2);
    data1 = im2double(data1);
    save('data1.mat', 'data1')

    SSA = (grm2 / 15.2) - mod((grm2 / 15.2), 2) + 1;
    fsize = round(grm2 / 2);
    H = fspecial('gaussian', fsize, round(grm2 / 2));
    blurreddata1 = imfilter(data1, H, 'symmetric');
    [Asp, Slope] = getSlopeAndAspect(blurreddata1, SSA, SSA);
    [~, DSlope] = getSlopeAndAspect(Slope, SSA, SSA);
    [DAspect] = getSlopeOfAspect(Asp, SSA, SSA);

    FDSlope = imfilter(DSlope, H, 'replicate');
    FDAspect = imfilter(DAspect, H, 'replicate');

    I = (Slope.^2 .* FDSlope.^1 .* FDAspect.^1).^(1/4);

    grammes = grm2; 
    Step_Filter_nAng = GSF_Angles;
    Step_Filter_step = pi / Step_Filter_nAng; 
    Step_Filter_DTheta = 0:Step_Filter_step:pi - Step_Filter_step;
    Step_Filter_Dbw = [2 4 6]; 

    [Y] = step_Filtering(I, grammes, Step_Filter_DTheta, Step_Filter_Dbw, 1);

    [BW, plotSkel] = getFaultDetection(Y, data1);

    BWorig = BW;

    C = bwconncomp(BW);
    RS = regionprops(C, 'Area', 'Orientation', 'Centroid');
    L = length(RS);
    area = [RS(1:L).Area];
    Map = bwlabel(BW, 8);

    RS_Y = regionprops(C, Y, 'PixelValues');

    feat = zeros(L, 2);

    for i = 1:L
        vec = RS_Y(i).PixelValues;
        feat(i, 1) = sum(vec);
    end
    feat(:, 2) = feat(:, 1);
    sv = sort(feat(:, 1), 'descend');

    Number_OF_Faults = round(0.85 * length(sv));
    Thresh = sv(Number_OF_Faults);

    Number_OF_Faults = num2str(Number_OF_Faults);

    Labels = find(feat(:, 1) >= Thresh);

    [plotH_] = plotNewColorMap0_(Y, zeros(size(data1)), Map, Labels, 'Detected Lineaments', YI(:), XI(:));

    plotH00 = (plotH_(:,:,1) + plotH_(:,:,2) + plotH_(:,:,3)) / 3;
    plotH00 = imbinarize(plotH00);
    plotH00 = imcomplement(plotH00);
    plotH0(:,:,tttt6) = plotH00;
end

plotH1 = zeros(size(plotH_));

for n = 1:numberoffeatures
    plotH1 = imfuse(plotH1, plotH0(:,:,n), 'blend');
    plotH1 = imbinarize(plotH1);
end

plotH1_rgb = im2double(plotH1);

global All_Trg_Matrix
All_Trg_Matrix2 = FilterB(All_Trg_Matrix, sigma2);
All_Trg_Matrix2 = imbinarize(All_Trg_Matrix2); 
All_Trg_Matrix2 = im2double(All_Trg_Matrix2);

global X_Pix
global Y_Pix

plotH_rgb_size = size(plotH1_rgb);
All_Trg_Matrix2 = imresize(All_Trg_Matrix2, [plotH_rgb_size(1) plotH_rgb_size(2)]);

data1 = FilterB(All_Trg_Matrix2, sigma2);
data1 = imbinarize(data1); 
data1 = im2double(data1);
data1 = cat(3, data1, data1, data1);
plotH1_rgb2 = imcomplement(plotH1_rgb); 

real_faults = (data1(:,:,1) + data1(:,:,2) + data1(:,:,3)) / 3;
detected_faults = (plotH1_rgb2(:,:,1) + plotH1_rgb2(:,:,2) + plotH1_rgb2(:,:,3)) / 3;

radius = 1;

radius1 = 10;
radius2 = radius1 + radius;
beta = 0.2;

se1 = strel('rectangle', [radius1 radius1]);
se2 = strel('rectangle', [radius2 radius2]);
real_faults_neighborhood1 = imdilate(real_faults, se1);
real_faults_neighborhood2 = imdilate(real_faults, se2);

detected_faults_neighborhood = detected_faults;

real_faults_neighborhood1 = real_faults_neighborhood1(:);
real_faults_neighborhood2 = real_faults_neighborhood2(:);

detected_faults_neighborhood = detected_faults_neighborhood(:);

tp = sum(real_faults_neighborhood1 & detected_faults_neighborhood);
fp1 = sum(~real_faults_neighborhood1 & detected_faults_neighborhood);
fp2 = sum(~real_faults_neighborhood2 & detected_faults_neighborhood);
fp = fp1 - fp2;
fn = sum(real_faults_neighborhood1 & ~detected_faults_neighborhood);

precision = tp / (tp + fp);
recall = tp / (tp + fn);
fbeta_score = (1 + beta^2) * ((precision * recall) / ((beta^2 * precision) + recall));

end