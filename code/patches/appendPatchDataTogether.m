function [newFeat, newPats, newInds] = appendPatchDataTogether( ...
  features, patchesPerImg, totalProcessed)
% Author: saurabh.me@gmail.com (Saurabh Singh).
newFeat = zeros(totalProcessed, size(features{1}, 2));
newPats = getEmptyPascalStruct();
newInds = zeros(totalProcessed, 2);

if totalProcessed < 1
  return;
end
newPats(totalProcessed, 1).x1 = 0;
featInd = 1;
for i = 1 : length(features)
  if isempty(features{i})
    continue;
  end
  startInd = featInd;
  numFeats = size(features{i}, 1);
  endInd = startInd + numFeats - 1;
  newFeat(startInd:endInd, :) = features{i};
  features{i} = [];
  newPats(startInd:endInd) = patchesPerImg{i};
  patchesPerImg{i} = [];
  newInds(startInd:endInd, :) = [i*ones(numFeats, 1) ...
    transpose(1:numFeats)];
  featInd = endInd + 1;
end
end
