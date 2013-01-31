function val = loadAndCheck(fileName, varName)
% Loads the named variable from the named file. Retries a maximum of 20
% times with an interval of 10s sleep between each retry.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).
maxIter = 20;
pauseInterval = 10;
loaded = false;
for i = 1 : maxIter
  try
    load(fileName, varName);
    eval(sprintf('val=%s;', varName));
    loaded = true;
    break;
  catch exception
    sleepInterval = pauseInterval + pauseInterval * rand(1) * 2;
    fprintf('Load failed %s:%s will sleep %f secs\n', fileName, ...
      varName, sleepInterval);
    pause(sleepInterval);
  end
end
if ~loaded
  error('Could not load %s:%s after %d retries\n', fileName, varName, ...
    maxIter);
  if exist('exception', 'var')
    displayStackTrace(exception);
  end
end
end
