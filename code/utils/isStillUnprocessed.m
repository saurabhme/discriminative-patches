function status = isStillUnprocessed(uniqueId, procDir)
% Used for lock mamangement
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

% If the unique id doesn't have an extension, assume that it is for a mat
% file.

if ischar(uniqueId)
  fileNameBase = uniqueId;
else
  fileNameBase = sprintf('%d', uniqueId);
end

if isempty(strfind(fileNameBase, '.'))
  fileNameBase = [fileNameBase '.mat'];
end

outFile = [procDir fileNameBase];
lockFile = [outFile '.lock'];

if ~fileExists(outFile) && ~exist(lockFile, 'dir')
%   pause(rand(1));
  
  if makeDirOrFail(lockFile)
    status = true;
  else
    status = false;
  end
else
  status = false;
end
end
