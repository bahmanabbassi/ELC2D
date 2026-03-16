function puls = yapuls(npuls)
% yapuls - Generates a pulsation vector.
%
% This function returns a pulsation vector of specified length, which is
% the concatenation of two subvectors. The elements of these subvectors 
% are respectively in the ranges [0, π) and [-π, 0). This is useful for 
% computing wavelets directly in the Fourier domain.
%
% Syntax:
%    puls = yapuls(npuls)
%
% Inputs:
%    npuls - REAL SCALAR: Length of the pulsation vector.
%
% Outputs:
%    puls - REAL VECTOR: The generated pulsation vector.
%
% Example:
%    % Generate a pulsation vector of length 5
%    puls5 = yapuls(5)
%
%    % Generate a pulsation vector of length 6
%    puls6 = yapuls(6)
%

% Check if the correct number of arguments is provided
if nargin ~= 1
    error('Argument Mismatch - The function requires one input argument');
end

% Compute the pulsation vector
npuls_2 = floor((npuls - 1) / 2);
puls = 2 * pi / npuls * [0:npuls_2, (npuls_2 - npuls + 1):-1];

end
