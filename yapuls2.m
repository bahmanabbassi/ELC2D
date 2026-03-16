function [pulsx, pulsy] = yapuls2(npulsx, npulsy)
% yapuls2 - Generates 2D pulsation matrices.
%
% This function returns two pulsation matrices, pulsx and pulsy, 
% of specified sizes. Each row of pulsx or each column of pulsy 
% is the concatenation of two subvectors whose elements are 
% respectively in the ranges [0, π) and [-π, 0). This is useful 
% for computing 2D wavelets directly in the Fourier domain.
%
% Syntax:
%    [pulsx, pulsy] = yapuls2(npulsx, npulsy)
%    [pulsx, pulsy] = yapuls2(npuls)
%
% Inputs:
%    npulsx - REAL SCALAR: Length of the x-pulsation vector.
%    npulsy - REAL SCALAR: Length of the y-pulsation vector (optional).
%             Defaults to npulsx if not provided.
%    npuls  - REAL VECTOR: 2-length vector containing the values of 
%             npulsx and npulsy.
%
% Outputs:
%    pulsx  - REAL MATRIX: The x-pulsation matrix.
%    pulsy  - REAL MATRIX: The y-pulsation matrix.
%
% Example:
%    % Generate a 5x5 pulsation matrix
%    [pulsx, pulsy] = yapuls2(5)
%
%    % Generate a 5x4 pulsation matrix
%    [pulsx, pulsy] = yapuls2([5, 4])
%
%    % Generate a 5x4 pulsation matrix
%    [pulsx, pulsy] = yapuls2(5, 4)
%

% Check if npulsy is provided
if ~exist('npulsy', 'var')
    if length(npulsx) == 1
        npulsy = npulsx;
    elseif length(npulsx) == 2
        npulsy = npulsx(2);
        npulsx = npulsx(1);
    else
        error('npulsx must be a scalar or a 2-length vector');
    end
end

% Generate pulsation matrices
[pulsx, pulsy] = meshgrid(yapuls(npulsx), yapuls(npulsy));

end
