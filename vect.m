function out = vect(deb, fin, N, typ, closeness)
% VECT - Compute vector with several shapes (linear, exponential, etc.)
%
% Syntax:
%    [out] = vect(deb, fin, N, typ, closeness)
%
% Description:
%    This function computes various types of N-point vectors with 
%    a beginning value 'deb' and an end value 'fin'. It extends 
%    the functionalities of 'linspace' and 'logspace' by adding 
%    additional options.
%
% Inputs:
%    deb - Starting value of the vector
%    fin - Ending value of the vector
%    N - Number of points in the vector
%    typ - Type of vector. Possible values:
%          'linear' - Linearly spaced (default)
%          'log' - Logarithmically spaced
%          'sqr' - Squared spaced
%    closeness - Type of interval to implement. Allowed values:
%          'close' - Linearly spaced with step = (fin - deb) / (N - 1)
%          'open' or 'ropen' - Linearly spaced with step = (fin - deb) / N
%              (right-open interval [deb, fin[)
%          'lopen' - Same as 'open' but for left-open interval ]deb, fin]
%          'rlopen' or 'lropen' - Open interval ]deb, fin[
%
% Outputs:
%    out - Output vector with specified characteristics
%
% Example:
%    % Linear spaced vector from 1 to 10 with 100 points
%    out = vect(1, 10, 100, 'linear', 'close');
%
%    % Logarithmic spaced vector from 1 to 1000 with 50 points
%    out = vect(1, 1000, 50, 'log', 'close');
%
%    % Squared spaced vector with right-open interval
%    out = vect(0, 100, 20, 'sqr', 'ropen');

if ~exist('typ', 'var')
  typ = 'linear';
end

% Allowing the override of typ by closeness
if any(strcmp(typ, {'close', 'open', 'lopen', 'ropen', 'rlopen', 'lropen'}))
  closeness = typ;
  typ = 'linear';
end

if ~exist('closeness', 'var')
  closeness = 'close';
end

if (fin == deb) || (N == 1)
  out = deb;
  return;
end

extr = [deb fin];

switch closeness
  case {'open', 'ropen'}
    out = vect(deb, fin, N + 1, typ);
    out = out(1:end - 1);
    return;

  case {'lopen'}
    out = vect(deb, fin, N + 1, typ);
    out = out(2:end);
    return;

  case {'rlopen', 'lropen'}
    out = vect(deb, fin, N + 1, typ);
    out = out(2:end) - (fin - deb) / (2 * N);
    return;

  case 'close'
    switch typ
      case 'linear'
        out = extr(1):(extr(2) - extr(1)) / (N - 1):extr(2);

      case 'log'
        if (extr(1) <= 0)
          disp('The first limit must be strictly positive');
          return;
        end
        out = exp(vect(log(extr(1)), log(extr(2)), N));

      case 'sqr'
        out = (vect(sqrt(extr(1)), sqrt(extr(2)), N)).^2;

      otherwise
        disp('USAGE: out = vect(deb, fin, N, typ, closeness)');
        error(['Unknown vector type ''' typ '''.']);
    end

  otherwise
    disp('USAGE: out = vect(deb, fin, N, typ, closeness)');
    error(['Unknown closeness ''' closeness '''.']);
end

end
