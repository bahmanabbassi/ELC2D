function out = list_elem(rec,k,def)
% LIST_ELEM - Return the k-th element of a list if it exists, otherwise return a default value.
%
% This function retrieves the k-th element from the input list 'rec'. If the k-th element does not
% exist, it returns the specified default value 'def'.
%
% Syntax:
%    out = list_elem(rec,k,def)
%
% Inputs:
%    rec - List or cell array from which to retrieve the element.
%    k - Integer index specifying which element to retrieve.
%    def - Default value to return if the k-th element does not exist.
%
% Outputs:
%    out - The k-th element of the input list if it exists, otherwise the default value 'def'.
%
% Example:
%    rec = {'a', 'b', 'c'};
%    k = 2;
%    def = 'default';
%    result = list_elem(rec, k, def); % Returns 'b'
%

% Input validation
if (nargin < 2)
    error('Argument Mismatch - Check Command Line');
end

if ~exist('def', 'var')
    def = [];
end

if ~iscell(rec)
    rec = {rec};
end

if (~isnumeric(k)) || (rem(k,1) ~= 0) || (k <= 0)
    error('''k'' must be a strictly positive integer');
end

% Retrieve the k-th element or default value
if (k <= length(rec))
    out = rec{k};
else
    out = def;
end