function boxes = getBoxesForPedro(data, decisionScore)
% Author: saurabh.me@gmail.com (Saurabh Singh).
if ~exist('decisionScore', 'var')
  decisionScore = zeros(length(data), 1);
end
boxes = zeros(length(data), 5);
for k = 1 : length(data)
  boxes(k, 1:4) = [data(k).x1 data(k).y1 data(k).x2 data(k).y2];
  boxes(k, 5) = decisionScore(k);
end
end
