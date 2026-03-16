function [Zpca, U, mu, eigVecs] = PCA(Z,r)
% PCA - Perform Principal Component Analysis on the input data matrix Z.
%
% Syntax:  [Zpca, U, mu, eigVecs] = PCA(Z, r)
%
% Inputs:
%    Z - Data matrix where each row is an observation and each column is a variable.
%    r - Number of principal components to retain.
%
% Outputs:
%    Zpca - Principal component scores.
%    U - Left singular vectors (truncated).
%    mu - Mean of each variable.
%    eigVecs - Scaled eigenvectors (if requested).

% Center data by subtracting the mean of each column (variable) from the data
[Zc, mu] = centerRows(Z);

% Alternatively, standardize the data (optional, commented out)
% [Zc, mu] = zscore(Z);

% Compute the Singular Value Decomposition (SVD) of the centered data
% 'econ' option ensures economy-sized decomposition

[U, S, V] = svd(Zc, 'econ');

% Retain only the first r components
U = U(:, 1:r);
S = S(1:r, 1:r);
V = V(:, 1:r);

% Compute the principal components scores
Zpca = S * V';

% If the number of output arguments is 4 or more, compute the scaled eigenvectors
if nargout >= 4
    % Scale eigenvectors by the singular values and normalize by the square root of the number of variables
    eigVecs = bsxfun(@times, U, diag(S)' / sqrt(size(Z, 2)));
end

end

% Helper function to center the data
function [Zc, mu] = centerRows(Z)
    % Compute the mean of each column (variable)
    mu = mean(Z, 1);
    % Subtract the mean from each row (observation) to center the data
    Zc = bsxfun(@minus, Z, mu);
end
