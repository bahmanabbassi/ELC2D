function out = yahelp(yafile, section)
% YAHELP - Display the help associated with a YAWTB file.
%
% This function displays a user-friendly help section of any YAWTB function.
%
% Syntax:
%    yahelp yafile
%    yahelp(yafile [, section])
%
% Inputs:
%    yafile - STRING: The name of the file.
%    section - SET OF STRING (optional): Specifies which part of the help must be displayed.
%              Type yahelp([]) to obtain a complete list of available sections.
%
% Example:
%    yahelp yashow
%    yahelp yashow syntax
%

%% Input manipulations

if ~exist('yafile', 'var')
    yafile = 'yahelp';
end

if ~exist('section', 'var')
    section = '';
else
    section = upper(section);
end

%% Elements to replace
actions = {
    '\manchap',              upper(yafile), ...
    '\mansecSyntax',         'SYNTAX', ...
    '\mansecDescription',    'DESCRIPTION', ...
    '\mansubsecInputData',   'INPUTS', ...
    '\mansubsecOutputData',  'OUTPUTS', ...
    '\mansecExample',        'EXAMPLE', ...
    '\mansecReference',      'REFERENCE', ...
    '\mansecSeeAlso',        'SEE ALSO', ...
    '\mansecLicense',        'LICENSE:', ...
    '\begin{description}',   '', ...
    '\end{description}',     '', ...
    '\item[',                '* [', ...
    '\begin{itemize}',       '', ...
    '\end{itemize}',         '', ...
    '\item',                 '- ', ...
    '\begin{code}',          '', ...
    '\end{code}',            '', ...
    '\url{"',                '"', ... 
    '\libfun{',              '''', ...
    '\libvar{',              '''', ...
    '\',                     '', ...
    '$',                     ''  };

%% Possible marks. Order is important.
marks = { 'USAGE', 'SYNTAX', 'DESCRIPTION', ...
          'INPUTS', 'OUTPUTS', 'CODE', 'EXAMPLE', ...
          'REFERENCE', 'SEE ALSO', 'LICENSE' };

if mod(length(actions), 2) ~= 0
    error('Check your actions of replacement');
end

%% Recording standard help
helpfun = help(yafile);

%% Additional pattern replacements for sections other than 'CODE' and 'EXAMPLE'
if ~strcmp(section, 'CODE') && ~strcmp(section, 'EXAMPLE')
    actions = [actions, ...
               '{"',    '"', ...
               '{',     '''', ...
               '"}',    '"', ...
               '}',     ''''];
end
  
%% Processing replacements
for k = 1:2:length(actions)
    helpfun = strrep(helpfun, actions{k}, actions{k+1});
end

%% Handle section extraction
if isempty(section)
    %% Removing License specification
    helpfun(strfind(helpfun, 'LICENSE'):end) = '';
else
    if ~any(strcmp(marks, section))
        error('This section is not valid');
    end
    
    %% Possible synonyms
    switch section
        case 'USAGE' 
            section = 'SYNTAX';
        case 'CODE'
            section = 'EXAMPLE';
    end
    
    first = strfind(helpfun, section);
    
    if isempty(first)
        if nargout == 1
            out = '';
        end
        return;
    end
    
    section_id = find(strcmp(marks, section));
    section_id = section_id(1);
    nb_sections = length(marks);
    
    last = [];
    k = 1;
    while isempty(last) && ((section_id + k) < nb_sections)
        next_section = marks{section_id + k};
        last  = strfind(helpfun, next_section);
        k = k + 1;
    end
    
    if isempty(last)
        helpfun = helpfun(first:end);
    else
        helpfun = helpfun(first:last-1);
    end
end

if nargout == 1
    out = helpfun;
else
    disp(helpfun);
end

end
