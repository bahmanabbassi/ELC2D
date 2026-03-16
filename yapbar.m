function [oyapbar] = yapbar(oyapbar, mode, msg)
% yapbar - Creates a figure with a progress bar.
%
% This function initializes and updates a progress bar inside a figure. 
% It is useful for long computation programs to visually indicate progress.
%
% Syntax:
%    oyapbar = yapbar([], lim)
%    oyapbar = yapbar(oyapbar, iter)
%    oyapbar = yapbar(oyapbar, 'Close')
%
% Description:
%    Initializes or updates a progress bar inside a figure. The progress 
%    bar can be incremented, decremented, set to a specific value, or closed.
%
% Inputs:
%    oyapbar - STRUCT: Progress bar object returned by the initialization with oyapbar set to [].
%    lim - INTEGER: The limit of the progress bar.
%    iter - INTEGER | '++' | '--': The iterator. In its numerical form, it must be greater than 0 
%           and less than the original lim. '++' increments the progress, '--' decrements it.
%    'Close' - BOOLEAN: Closes the progress bar and sets oyapbar to [].
%    msg - STRING: Optional message to display alongside the progress bar (default: '').
%
% Outputs:
%    oyapbar - STRUCT: The progress bar object.
%
% Example:
%    % Initialization of the yapbar object (10 is the number of steps):
%    oyap = yapbar([], 10);
%
%    % Progression of the yapbar:
%    for k = 1:10
%        oyap = yapbar(oyap, '++');
%    end
%
%    % Closing of this yapbar:
%    oyap = yapbar(oyap, 'Close');

%% Initialization
is_visible = strcmp(getyawtbprefs('yapbarVisible'), 'on');
is_graphic = strcmp(getyawtbprefs('yapbarMode'), 'graphic');

if ~exist('msg', 'var')
    msg = '';
end

%% Check if the user wants a progress bar
if ~is_visible
    return;
end

%% Determine the calling application (caller)
if isunix && strcmp(version('-release'), '13')
    caller = dbstack;
    caller = caller(min(2, length(caller))).name;
    pos = yastrfind(caller, '/');
    caller = caller((pos(end) + 1):end);
    pos = yastrfind(caller, '.');
    caller = caller(1:pos(1) - 1);
    if strcmp(caller, 'yapbar')
        caller = '';
    end
else
    caller = '';
end     

%% If oyapbar is empty, create the progress bar
if isempty(oyapbar)
    oyapbar.iter = 0;
    
    if ~isnumeric(mode)
        error('You must provide a numerical value for the limit');
    end
    
    oyapbar.lim = mode;
    oyapbar.text = '  0.0%';
    
    if is_graphic 
        oyapbar.fig = figure;
        oyapbar.hrect = rectangle('position', [0 0 eps 1]);
        oyapbar.htbox = rectangle('position', [0.46 0.2 0.12 0.6]);  
        oyapbar.htext = text(0.48, 0.5, oyapbar.text);
      
        fig = oyapbar.fig;
        htbox = oyapbar.htbox;
        hrect = oyapbar.hrect;
      
        set(fig, 'MenuBar', 'none');

        %% Set the title with the calling function
        if isempty(caller)
            set(fig, 'Name', 'Progress Bar');
        else
            set(fig, 'Name', ['Progress Bar (' caller ')']);
        end
        
        set(fig, 'NumberTitle', 'off');
        
        set(gca, 'xlim', [0 1]); 
        set(gca, 'xtick', []);
        set(gca, 'ytick', []);
        set(gca, 'box', 'on');
        set(hrect, 'facecolor', 'blue'); 
        set(htbox, 'facecolor', 'white'); 
        set(fig, 'position', [200 404 301 32]);
      
        drawnow;
    else
        if isempty(caller)
            oyapbar.text = sprintf('[%s]', oyapbar.text);
        else
            oyapbar.text = sprintf('[%s:%s]', caller, oyapbar.text);
        end    
        fprintf('%s', oyapbar.text);
    end
    return;
end
  
%% If the yapbar figure has been deleted during the process which uses it
if is_graphic 
    if all(get(0, 'children') ~= oyapbar.fig)
        return;
    end
end

%% If this is the end, close the progress bar
if strcmpi(mode, 'close') && ~isempty(oyapbar)
    if is_graphic 
        delete(oyapbar.fig);
    else
        fprintf('\n');
    end
    oyapbar = [];
    return;
end

%% Testing all the possible increments
if strcmp(mode, '++')
    oyapbar.iter = oyapbar.iter + 1;
elseif strcmp(mode, '--')
    oyapbar.iter = oyapbar.iter - 1;
elseif isnumeric(mode)
    oyapbar.iter = mode;
elseif strcmp(mode, '==')
    %% No change: allow the display of a message 
else
    error(['The iterator must be either numeric, ''++'', or ''--''']);
end

%% Simplify the use of future variables
if is_graphic 
    fig = oyapbar.fig;
    hrect = oyapbar.hrect;
    htbox = oyapbar.htbox;
    htext = oyapbar.htext;
end

lim = oyapbar.lim;
iter = oyapbar.iter;

%% Drawing the change
if iter <= lim && iter >= 0
    new_text = sprintf('%3.1f%%', iter / lim * 100);
    if is_graphic
        set(hrect, 'position', [0 0 ((iter / lim) + eps) 1]);
        set(htext, 'string', new_text);
        htextpos = get(htext, 'extent');
        htboxpos = get(htbox, 'position');
        htboxpos(3) = htextpos(3) + 0.015;
        set(htbox, 'position', htboxpos);
        drawnow;
        if ~isempty(msg)
            disp(msg);
        end
    else
        if isempty(caller)
            new_text = ['[' repmat(' ', 1, 6 - length(new_text)) new_text '] ' msg];
        else
            new_text = ['[' caller ':' repmat(' ', 1, 6 - length(new_text)) new_text '] ' msg];
        end
        if ~strcmp(new_text, oyapbar.text)   
            prev_text_lgth = length(oyapbar.text);
            oyapbar.text = new_text;
            fprintf(repmat('\b', 1, prev_text_lgth));
            fprintf('%s', oyapbar.text);
        end
    end
end 
