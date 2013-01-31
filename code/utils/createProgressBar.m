function pBar = createProgressBar()
% Author: saurabh.me@gmail.com (Saurabh Singh).
fprintf('\n');
pBar = @progressRenderer;
end

function progressRenderer(current, total)
percent = current / total * 100;
maxDots = 20;
numDots = floor(current / total * maxDots);
statusString = ['[' repmat('.', 1, numDots) ...
  repmat(' ', 1, maxDots - numDots) '] ' sprintf('%5.1f', percent) ' %%'];
backSlash = repmat('\b', 1, length(statusString)-1);
if current ~= 1
  fprintf(backSlash);
end
fprintf(statusString);
if current == total
  fprintf('\n');
end
end
