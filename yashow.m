function yashow(yastruct, varargin)
% yashow - Display the result of any transform defined in YAWTB.
%
% This function simplifies the use of Matlab visualization tools 
% for any YAWTB result coming from various transforms like cwt1d, 
% cwt2d, and cwtsph.
%
% Syntax:
%    yashow(yastruct [, 'Fig', fig] [, 'Mode', mode [, ModeParam]] [, 'CMap', cmap] ...
%           [, 'Square'] [, 'Equal'] [, 'HistEq'] [, 'Normalize'] ...
%           [, 'Contour' [, nlevel]] [, 'Contour' [, vlevel]] ...
%           [, 'Surf'] [, 'Spheric' [, 'Relief' [, 'Ratio', ratio]]] ...
%           [, 'maxi' [, T]] [, 'mini' [, T]])
%
% Inputs:
%    yastruct - STRUCT: the result of a particular YAWTB transform.
%
% Optional Inputs:
%    fig      - POSITIVE INTEGER: specifies the figure in which to display the input.
%    mode     - STRING: defines the display mode. Available modes are:
%               'abs'       : the absolute value.
%               'angle'     : the complex argument.
%               'essangle'  : the essential argument, thresholded by default at 1% of the modulus.
%               'real'      : the real part.
%               'imag'      : the imaginary part.
%    cmap     - STRING: defines the colormap to use in the display, e.g. 'jet' [default], 'hsv', 'gray'.
%    'Square' - BOOLEAN: specifies if yashow must display a matrix like a square.
%    'Equal'  - BOOLEAN: specifies if yashow must keep the square shape of the pixels (dx==dy).
%    'HistEq' - BOOLEAN: specifies if yashow must equalize histogram of the display matrix.
%    'Normalize' - BOOLEAN: specifies if the data must be normalized to [-1,1].
%    'Contour' - BOOLEAN: displays the contour of the matrix. Modifiers are:
%                nlevel - INTEGER: the number of levels to display.
%                vlevel - 1x2 VECTOR: a vector containing twice the curve level to display, e.g. [0 0] to show the curve level of zero height.
%    'Surf'   - BOOLEAN: displays the matrix as a 3D surface.
%    'maxi'   - BOOLEAN: specifies if crosses representing maxima must be added to the displayed image.
%    'mini'   - BOOLEAN: specifies if circles representing minima must be added to the displayed image.
%    T        - REAL: a threshold for the maxima or the minima. T belongs to the interval 0 <= T <= 1.
%    'Spheric' - BOOLEAN: (for matrix only!) specifies if the matrix must be mapped onto a sphere.
%                'Relief' - BOOLEAN: the mapping is done in relief. Suboptions:
%                ratio   - DOUBLE: set the ratio between the highest absolute value of the input matrix and the sphere radius.
%
% Example:
%    % Display the absolute value of a 2D wavelet transform
%    [x, y] = meshgrid(-64:64);
%    square = max(abs(x), abs(y)) < 20;
%    fsquare = fft2(square);
%    wsquare = cwt2d(fsquare, 'cauchy', 2, 0);
%    yashow(wsquare);
%
%    % Display the argument of the transform in 'gray' colormap with 40 levels
%    yashow(wsquare, 'Mode', 'angle', 'CMap', 'gray(40)');
%
% Notes:
%    - 'yastruct' must be a structure containing the result of a YAWTB transform.
%    - If 'yastruct' is a numeric or logical array, it will be converted to a structure.
%    - The function supports various display modes and options to customize the visualization.
%    - Ensure to use appropriate 'Mode' and 'CMap' options for better visualization of complex data.
%

%% Managing the input

if (nargin < 1)
  error('At least one input argument is required. Check the command line');
end

%% yashow can display simple N-D matrix
if (isnumeric(yastruct) || islogical(yastruct))
  ans = yastruct;
  clear yastruct;
  yastruct.data = ans;
  
  %% .. on a volume (<3 could be a color image)
  if (size(yastruct.data, 3) > 3)
    yastruct.type = 'volume';
    
  elseif (size(yastruct.data, 1) >= 2 && size(yastruct.data, 2) >= 2)
    %% .. on a sphere
    if getopts(varargin, 'spheric', [], 1)
      yastruct.type = 'spheric';
      
    elseif getopts(varargin, 'sphvf', [], 1)
      yastruct.type = 'sphvf';
      
    %% .. a time sequence
    elseif getopts(varargin, 'timeseq', [], 1)
      yastruct.type = 'timeseq';
      
    %% ... the standard way
    else                                
      yastruct.type = 'matrix';
    end    
  else
    yastruct.type = 'vector';
  end
else

  if (~isstruct(yastruct) || ~isfield(yastruct, 'type'))
    error('Unrecognized input type');
  end
  
  %% The display part
  
  %% Allow overloading of yashow if the showing method of the yawtb
  %% result is implemented in yashow_*.m
  
  if exist(['yashow_' yastruct.type]) == 2
    feval(['yashow_' yastruct.type], yastruct, varargin{:});
    return
    
  elseif (~any(strcmp(yastruct.type, YashowInnerTypes)))
    error(sprintf('yashow not implemented for the %s type', yastruct.type));
  end
end

%% Else, let's do the work by yashow!

%% Selecting the good figure
oldfig = gcf;
[fig, varargin] = getopts(varargin, 'fig', gcf);
figure(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Specific methods of 'matrix' and 'vector' %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch lower(yastruct.type)
 case 'volume'
  %% Determining if an 'x' or 'y' axis is given
  if (isfield(yastruct, 'x'))
    x_opts = {'x', yastruct.x};
  else
    x_opts = {};
  end
  
  if (isfield(yastruct, 'y'))
    y_opts = {'y', yastruct.y};
  else
    y_opts = {};
  end
  
  if (isfield(yastruct, 'z'))
    z_opts = {'z', yastruct.z};
  else
    z_opts = {};
  end
  
  yashow_volume(yastruct.data, x_opts{:}, y_opts{:}, z_opts{:}, varargin{:});
 
 case 'matrix'
  if (isfield(yastruct, 'x'))
    x_opts = {'x', yastruct.x};
  else
    x_opts = {};
  end
  
  if (isfield(yastruct, 'y'))
    y_opts = {'y', yastruct.y};
  else
    y_opts = {};
  end
  
  yashow_matrix(yastruct.data, x_opts{:}, y_opts{:}, varargin{:});
  
 case 'spheric'
  yashow_spheric(yastruct.data, varargin{:});
  
 case 'sphvf'
  yashow_sphvf(yastruct.data, varargin{:});
 
 case 'vector'
  %% Determining if an 'x' or 'y' axis is given
  [ox, varargin] = getopts(varargin, 'x', 1:length(yastruct.data));
  
  %% The final plotting
  plot(ox, yastruct.data(:), varargin{:});
  
 case 'timeseq'
  yashow_timeseq(yastruct.data, varargin{:});

 otherwise
  error(['The mode ''' mode ''' is undefined in yashow']);
end

end
