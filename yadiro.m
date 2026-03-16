function [nX, nY] = yadiro(X, Y, sc, ang, varargin)
% YADIRO - Perform dilation and rotation on grids of positions.
%
% This function applies a scaling (dilation) and rotation to two grids X and Y.
% The grids are typically created by the meshgrid function.
%
% Syntax:
%    [nX, nY] = yadiro(X, Y, sc, ang, ['freq'])
%
% Inputs:
%    X - REAL MATRIX: The matrix of 'x' (horizontal) positions.
%    Y - REAL MATRIX: The matrix of 'y' (vertical) positions.
%    sc - REAL SCALAR: The scale of dilation (must be positive).
%    ang - REAL SCALAR: The angle of rotation in radians.
%    'freq' - BOOLEAN (optional): If specified, inverses the dilation to correspond
%           to its frequency action.
%
% Outputs:
%    nX - REAL ARRAY: The dilated and rotated horizontal positions.
%    nY - REAL ARRAY: The dilated and rotated vertical positions.
%
% Example:
%    [x, y] = meshgrid(vect(-1, 1, 3), vect(-1, 1, 3));
%    [nx, ny] = yadiro(x, y, 2, pi/2);
%
% See also:
%    meshgrid
%

%% Checking input
if (nargin < 4)
    error('''yadiro'' requires at least 4 arguments.');
end

if (sc <= 0)
    error('''sc'' must be strictly positive.');
end

%% Computations
if (getopts(varargin, 'freq', [], 1))
    factor = sc;
else
    factor = 1 / sc;
end

if (ang == 0)
    nX = factor * X;
    nY = factor * Y;
else
    nX = factor * (cos(ang) .* X - sin(ang) .* Y);
    nY = factor * (sin(ang) .* X + cos(ang) .* Y);
end

end
