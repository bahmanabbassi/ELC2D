function out = cwt2d(fimg, wavname, scales, angles, varargin)
% CWT2D - Compute 2D continuous wavelet transforms.
%
% This function computes the 2D continuous wavelet transform (CWT) of an image.
%
% Syntax:
%    out = cwt2d(fimg, wavname, scales, angles, ...)
%
% Inputs:
%    fimg    - Fourier transform of the input image (matrix).
%    wavname - Name of the wavelet to use (string).
%    scales  - Array of scales for the transform.
%    angles  - Array of angles for the transform.
%    varargin - Additional optional parameters (key-value pairs):
%        'Norm'      - Normalization method ('l0', 'l1', 'l2'). Default is 'l2'.
%        'Export'    - If true, output is a matrix instead of a structure.
%        'Contrast'  - If true, apply contrast normalization.
%        'Pos'       - Position for computing CWT (interactive mode if 'inter').
%        'Exec'      - Command to execute on each result of the CWT.
%        'NoPBar'    - If true, disable the progress bar.
%
% Outputs:
%    out - Structure containing the CWT results or a matrix if 'Export' is true.
%
% Example:
%    [x, y] = meshgrid(-64:64);
%    img = max(abs(x), abs(y)) < 30;
%    fimg = fft2(img);
%    wimg = cwt2d(fimg, 'morlet', [2], [0]);
%    yashow(wimg);

% Validate input arguments
if nargin < 4
    error('Argument Mismatch - Check Command Line');
end

if ~ischar(wavname)
    error('wavname must be a string');
end

% Parse optional arguments
[export, varargin] = getopts(varargin, 'export', [], 1);
[NormChoice, varargin] = getopts(varargin, 'norm', 'l2');
[ctr, varargin] = getopts(varargin, 'contrast', [], 1);
[fixpos, varargin] = getopts(varargin, 'pos', []);
[exec, varargin] = getopts(varargin, 'exec', '');
[nopbar, varargin] = getopts(varargin, 'NoPBar', [], 1);

% Validate wavelet function
wavname = lower(wavname);
if exist([wavname '2d'], 'file')
    wavname = [wavname '2d'];
elseif ~exist(wavname, 'file')
    error('The specified wavelet does not exist');
end

% Initialize output structure
out = struct();
if ~export
    out.extra = varargin;
end

% Validate numeric inputs
if ~all(isnumeric(scales)) || ~all(isnumeric(angles))
    error('Scales and angles must be numeric');
end

% Choose normalization method
switch lower(NormChoice)
    case 'l2'
        norm = 1;
    case 'l1'
        norm = 0;
    case 'l0'
        norm = 2;
    otherwise
        norm = 1;
end

% Prepare contrast normalization if needed
if ctr
    ctrname = [wavname '_ctr'];
    if ~exist(ctrname, 'file')
        error('Contrast normalization not implemented for this wavelet');
    end
end

% Handle interactive position selection
defexec = '';
if ~isempty(fixpos)
    if strcmp(fixpos, 'inter')
        [fig, varargin] = getopts(varargin, 'fig', gcf);
        figure(fig);
        [xsel, ysel] = ginput(1);
        fixpos = [max(1, min(size(fimg, 2), round(xsel))), max(1, min(size(fimg, 1), round(ysel)))];
        defexec = '$cwt(ysel, xsel)';
        fprintf('CWT computed on (x:%i, y:%i)\n', xsel, ysel);
    elseif ~isnumeric(fixpos)
        error('Invalid position selection mode');
    end
    defexec = '$cwt(fixpos(2), fixpos(1))';
end

% Prepare exec mode if specified
is_exec = ~isempty(exec);
if is_exec
    exec = strrep(exec, '$cwt', 'tmp');
    exec = strrep(exec, '$last', '[out.data{end,end}]');
    exec = strrep(exec, '$rec', 'out.data');
    exec = strrep(exec, '$fimg', 'fimg');
    sep = find(exec == ';');
    if ~isempty(sep)
        init_exec = exec(1:sep);
        exec = exec(sep+1:end);
    else
        init_exec = '';
    end
end

% Extract wavelet parameters
wavopts = yawopts(varargin, wavname);

% Prepare frequency plane
[Hgth, Wdth] = size(fimg);
[kx, ky] = yapuls2(Wdth, Hgth);
dkxdky = abs((kx(1, 2) - kx(1, 1)) * (ky(2, 1) - ky(1, 1)));

nsc = length(scales);
nang = length(angles);

% Initialize output data structure
if is_exec
    out.data = {};
    if ~isempty(init_exec)
        eval(init_exec);
    end
else
    out.data = zeros(Hgth, Wdth, nsc, nang);
end

isloop = (nsc * nang > 1);
if isloop && ~nopbar
    oyap = yapbar([], nsc * nang);
end

for sc = 1:nsc
    for ang = 1:nang
        if isloop && ~nopbar
            oyap = yapbar(oyap, '++');
        end

        csc = scales(sc);
        cang = angles(ang);
        [nkx, nky] = yadiro(kx, ky, csc, cang, 'freq');
        mask = csc^norm * feval(wavname, nkx, nky, wavopts{:});

        if is_exec
            tmp = ifft2(fimg .* conj(mask));
            out.data{sc, ang} = eval(exec);
        else
            out.data(:, :, sc, ang) = ifft2(fimg .* conj(mask));
            out.wav_norm(sc, ang) = (sum(abs(mask(:)).^2) * dkxdky)^0.5 / (2 * pi);
        end

        if ctr && ~is_exec
            mask = csc^norm * feval(ctrname, nkx, nky, wavopts{:});
            lumin = real(ifft2(fimg .* conj(mask)));
            out.data(:, :, sc, ang) = (out.data(:, :, sc, ang) ~= 0) .* out.data(:, :, sc, ang) ./ lumin;
            out.wav_norm(sc, ang) = (sum(abs(mask(:)).^2) * dkxdky)^0.5 / (2 * pi);
        end
    end
end

if isloop && ~nopbar
    oyap = yapbar(oyap, 'close');
end

% Set the output
if export
    out = out.data;
else
    out.type = mfilename;
    out.wav = wavname;
    out.para = [wavopts{:}];
    out.sc = scales;
    out.ang = angles;
    out.pos = fixpos;
end

end
