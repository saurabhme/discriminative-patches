function displayStackTrace(e)
% Author: saurabh.me@gmail.com (Saurabh Singh)

fprintf('%s : %s\n', e.identifier, e.message);
fprintf('Error Stack\n');
stack = e.stack;
for i = 1 : length(stack)
  fprintf('%s > %s at %d\n', stack(i).file, stack(i).name, stack(i).line);
end
end
