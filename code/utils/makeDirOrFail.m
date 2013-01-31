function bool = makeDirOrFail(dirName)
%from santosh
[smesg, smess, smessid] = mkdir(dirName);
bool = ~strcmp(smessid,'MATLAB:MKDIR:DirectoryExists');
end