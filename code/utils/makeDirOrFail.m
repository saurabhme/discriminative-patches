function bool = makeDirOrFail(dirName)
% Adapted from a function borrowed from Santosh Divvala.
% Author: saurabh.me@gmail.com (Saurabh Singh).
[smesg, smess, smessid] = mkdir(dirName);
bool = ~strcmp(smessid,'MATLAB:MKDIR:DirectoryExists');
end
