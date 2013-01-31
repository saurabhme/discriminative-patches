function doneProcessing(uniqueId, procDir)
% Do cleanup of locks.
%
% Author: saurabh.me@gmail.com (Saurabh Singh)

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
if exist(lockFile, 'dir')
  try
    rmdir(lockFile);
  catch
    fprintf('Encountered problem deleting lock file. Moving on [%s].', ...
      lockFile);
  end
end
end
