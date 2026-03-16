function [out] = yamax(mat, varargin)
% yamax - Determines the regional maxima of a real matrix.
%
% This function identifies the local maxima of the input real matrix
% with a specified pixel connection (4 or 8 neighbors).
%
% Syntax:
%    [out] = yamax(mat ['connect', connexion] [,'pos'] [,'thresh', T] ['dir', angle])
%
% Inputs:
%    mat - REAL MATRIX: The input matrix.
%    connexion - INTEGER: The connection to use (4 or 8 neighbors).
%    'pos' - BOOLEAN: Returns the list of row and column positions of the maxima.
%    'strict' - BOOLEAN: Returns only strict maxima, strictly greater than their neighbors.
%    T - REAL: A threshold between 0 and 1 for maxima detection. Only maxima greater than 
%              minmat + T*(maxmat - minmat) are conserved.
%    angle - REAL|REAL MATRIX: Determines the maxima of the matrix in the specified direction. 
%                              This angle can be a scalar or a matrix, with each element in 
%                              the interval [-pi/2, pi/2].
%
% Outputs:
%    out - If 'pos' is not specified, out is a binary matrix with 1s at maxima and 0s elsewhere.
%          If 'pos' is specified, out is a struct array with fields:
%          out.i - Row positions of the maxima.
%          out.j - Column positions of the maxima.
%          out.lin - Linear positions of the maxima such that mat(out.lin) gives all maxima of mat.
%
% Example:
%    % The center of a Gaussian
%    [x, y] = meshgrid(vect(-1, 1, 5));
%    g = exp(-x.^2 - y.^2);
%    yamax(g)
%
%    % Maxima of this Gaussian in the directions of 0 and pi/4 radians
%    yamax(g, 'dir', 0)
%    yamax(g, 'dir', pi/4)
%

%% Checking if we want a directional maximum detection
[angle, varargin] = getopts(varargin, 'dir', []);
isdir = ~isempty(angle);

if ~isnumeric(angle)
    error('''ang'' must be numeric in the directional mode');
end

%% Determining the desired connection
[connection, varargin] = getopts(varargin, 'connect', 4);
if connection ~= 4 && connection ~= 8
    error('This connection is not supported (4 or 8 only).');
end

%% See if we are interested in strict maximum
[isstrict, varargin] = getopts(varargin, 'strict', [], 1);

zeroh = zeros(1, size(mat, 2));
zerov = zeros(size(mat, 1), 1);

dmat_r = mat - [mat(:, 2:end), zerov];
dmat_l = mat - [zerov, mat(:, 1:end-1)];
dmat_u = mat - [zeroh; mat(1:end-1, :)];
dmat_d = mat - [mat(2:end, :); zeroh];

if isdir
    zeroh_1 = zeros(1, size(mat, 2) - 1);
    zerov_1 = zeros(size(mat, 1) - 1, 1);
    
    dmat_ur = mat - [zeroh; [mat(1:end-1, 2:end), zerov_1]];
    dmat_ul = mat - [zeroh; [zerov_1, mat(1:end-1, 1:end-1)]];
    dmat_dr = mat - [[mat(2:end, 2:end), zerov_1]; zeroh];
    dmat_dl = mat - [[zerov_1, mat(2:end, 1:end-1)]; zeroh];
    
    %% Quantify angle
    angle_step = pi / 8;
    Qangle = zeros(size(angle));
    Qangle = Qangle + ((angle < (-pi + angle_step)) | (angle > (pi - angle_step)));
    
    for k = -3:3
        Qangle = Qangle + ((angle >= ((k-1) * pi / 4 + angle_step)) & (angle < (k * pi / 4 + angle_step))) * (k + 5);
    end
    
    if isstrict
        out = (((Qangle == 1) | (Qangle == 5)) & (dmat_r > 0) & (dmat_l > 0)) | ...
              (((Qangle == 2) | (Qangle == 6)) & (dmat_dr > 0) & (dmat_ul > 0)) | ...
              (((Qangle == 3) | (Qangle == 7)) & (dmat_d > 0) & (dmat_u > 0)) | ...
              (((Qangle == 4) | (Qangle == 8)) & (dmat_dl > 0) & (dmat_ur > 0));
    else
        out = (((Qangle == 1) | (Qangle == 5)) & (dmat_r >= 0) & (dmat_l >= 0)) | ...
              (((Qangle == 2) | (Qangle == 6)) & (dmat_dr >= 0) & (dmat_ul >= 0)) | ...
              (((Qangle == 3) | (Qangle == 7)) & (dmat_d >= 0) & (dmat_u >= 0)) | ...
              (((Qangle == 4) | (Qangle == 8)) & (dmat_dl >= 0) & (dmat_ur >= 0));
    end
    
else
    if isstrict
        out = (dmat_r > 0) & (dmat_l > 0) & (dmat_u > 0) & (dmat_d > 0);
    else
        out = (dmat_r >= 0) & (dmat_l >= 0) & (dmat_u >= 0) & (dmat_d >= 0);
    end
    
    if connection == 8
        zeroh_1 = zeros(1, size(mat, 2) - 1);
        zerov_1 = zeros(size(mat, 1) - 1, 1);
        
        dmat_ur = mat - [zeroh; [mat(1:end-1, 2:end), zerov_1]];
        dmat_ul = mat - [zeroh; [zerov_1, mat(1:end-1, 1:end-1)]];
        dmat_dr = mat - [[mat(2:end, 2:end), zerov_1]; zeroh];
        dmat_dl = mat - [[zerov_1, mat(2:end, 1:end-1)]; zeroh];
        
        if isstrict
            out = out & (dmat_ur > 0) & (dmat_ul > 0) & (dmat_dr > 0) & (dmat_dl > 0);
        else
            out = out & (dmat_ur >= 0) & (dmat_ul >= 0) & (dmat_dr >= 0) & (dmat_dl >= 0);
        end
    end
end
  
%% Applying the threshold
[T, varargin] = getopts(varargin, 'thresh', 0);
if T
    min_mat = min(mat(:));
    max_mat = max(mat(:));
    out = out & (mat >= (min_mat + T * (max_mat - min_mat)));
end

%% Recording the location
if getopts(varargin, 'pos', [], 1)
    [posi, posj] = find(out);
    out.cache = out;
    out.i = posi;
    out.j = posj;
    out.lin = posi + (posj - 1) * size(mat, 1);
end

end
