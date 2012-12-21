function [features, indexes] = getFeaturesForLevel(level, prSize, pcSize)
% Author: saurabh.me@gmail.com (Saurabh Singh)
[rows, cols, dims] = size(level);
rLim = rows - prSize + 1;
cLim = cols - pcSize + 1;
featDim = prSize * pcSize * dims;
features = zeros(rLim * cLim, featDim);
indexes = zeros(rLim * cLim, 2);
featInd = 0;
for j = 1 : cLim
  for i = 1 : rLim
    feat = level(i:i+prSize-1, j:j+pcSize-1, :);
    featInd = featInd + 1;
    features(featInd, :) = reshape(feat, 1, featDim);
    indexes(featInd, :) = [i, j];
  end
end
end
