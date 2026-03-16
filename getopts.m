function [val, NewOptionList] = getopts(OptionList, OptionName, OptionDefaultValue, HasNoValue)
% GETOPTS - Return the value of the 'OptionName' variable inside the list 'OptionList'.
%
% This function searches for a specified option within a list of options
% and returns its value. It also returns a new list with the specified
% option removed.
%
% Syntax:
%    [val, NewOptionList] = getopts(OptionList, 'OptionName', OptionDefaultValue, HasNoValue)
%
% Inputs:
%    OptionList - Cell array containing options and their values.
%                 Syntax: {'OPT1', VAL1, 'OPT2', VAL2, ...}
%    OptionName - String specifying the option to seek inside OptionList.
%    OptionDefaultValue - Default value to return if the option is not found.
%                         Optional.
%    HasNoValue - Boolean flag (1 or 0). If set to 1, val is set to 1 if 
%                 OptionName is found, and 0 if not. Optional.
%
% Outputs:
%    val - Value of the specified option if found, otherwise returns OptionDefaultValue or [].
%    NewOptionList - Cell array with the specified option removed.
%
% Example:
%    [val, list] = getopts({'sigma', 1, 'rho', 2.3}, 'rho', 7)
%    val = getopts({'sigma', 1, 'radian'}, 'radian', [], 1)

% Ensure OptionList is a cell array
if ~iscell(OptionList)
  OptionList = {OptionList};
end

% Flatten OptionList if it is a multi-row cell array
if size(OptionList, 1) > 1
  OptionList = OptionList';
  OptionList = {OptionList{:}};
end

% Validate input arguments
if nargin < 2 || nargout > 2
  error('Argument Mismatch - Check Command Line');
end

% Set default value for HasNoValue if not provided
if ~exist('HasNoValue', 'var')
  HasNoValue = 0;
else
  HasNoValue = (HasNoValue ~= 0);
end

% Convert all strings in OptionList to lowercase
NumbOptions = length(OptionList);
for k = 1:NumbOptions
  if ischar(OptionList{k})
    OptionList{k} = lower(OptionList{k});
  end
end

% Convert OptionName to lowercase
OptionName = lower(OptionName);

% Search for OptionName in OptionList
for k = 1:NumbOptions
  if strcmp(OptionList{k}, OptionName)
    
    % Create NewOptionList without the found option
    if (k + 1 - HasNoValue) <= NumbOptions
      NewOptionList = {OptionList{1:(k-1)}, OptionList{(k+2-HasNoValue):NumbOptions}};
    elseif k > 1
      NewOptionList = {OptionList{1:(k-1)}};
    else
      NewOptionList = {};
    end
    
    % Set the value of the found option
    if HasNoValue
      val = 1;
    else
      if k < NumbOptions
        val = OptionList{k+1};
      else
        val = [];
      end
    end
    return;
  end
end

% If OptionName is not found, set the default value
if HasNoValue
  val = 0;
else
  if exist('OptionDefaultValue', 'var')
    val = OptionDefaultValue;
  else
    val = [];
  end
end

NewOptionList = OptionList;

end
