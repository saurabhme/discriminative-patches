function displayPatchBox(patches, scores, color, showScore)
% Author: saurabh.me@gmail.com (Saurabh Singh).
if nargin < 4
  showScore = true;
end
if isempty(scores)
  showScore = false;
  if isstruct(patches)
    scores = zeros(length(patches), 1);
  else
    scores = zeros(size(patches, 1), 1);
  end
end

if isstruct(patches)
  boxes = getBoxesForPedro(patches, scores);
else
  boxes = patches;
  if size(boxes, 2) < 5
    boxes = [boxes scores];
  end
end
if nargin < 3
  color = 'r';
end

% allColors = 'ymcrgbwk';
hold on;
for j = 1 : size(boxes, 1)
  selCol = color;
  rectangle('Position', [boxes(j, 1) boxes(j, 2) ...
    abs(boxes(j, 3)-boxes(j, 1)) abs(boxes(j, 4)-boxes(j, 2))], ...
    'EdgeColor', selCol, ...
    'LineWidth', 4);
  if showScore
    text(boxes(j, 1), boxes(j, 2) - 12, sprintf('%.3f', ...
      boxes(j, 5)), ...
      'BackgroundColor', selCol, ...
      'Color', 'k', ...
      'FontSize', 5);
  end
%   pause(0.1)
end
hold off;
end
