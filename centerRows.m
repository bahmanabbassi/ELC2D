function [Zc, mu] = centerRows(Z)
% Center the rows of the input data matrix.
%
% Inputs:
%    Z - A (d x n) matrix containing n samples of a d-dimensional random vector.
%
% Outputs:
%    Zc - The centered version of Z.
%    mu - The (d x 1) sample mean of Z.
%
% Description:
%    This function returns the centered (zero mean) version of the input data matrix.
%    Centering is performed by subtracting the mean of each row from the corresponding row elements.
%
% Example:
%    Z = [1 2 3; 4 5 6; 7 8 9];
%    [Zc, mu] = centerRows(Z);
%    % Zc is the centered version of Z, and mu is the mean of each row of Z.

% Compute the mean of each row
mu = mean(Z, 2);

% Subtract the mean from each row to center the data
Zc = bsxfun(@minus, Z, mu);

end
