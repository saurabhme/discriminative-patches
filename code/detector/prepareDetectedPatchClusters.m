function [allFeatures, allPatches, posCorrespInds, posCorrespImgs, ...
  assignedClustVote, assignedClustTrain, ...
  selectedClust] = prepareDetectedPatchClusters( ...
    topN, nVote, nTop, params, trainSetPos, selectedClusters)

topN = selectN(topN, nVote);

patsPerImg = cell(size(trainSetPos));
for i = 1 : length(topN)
  [unused, inds] = ismember(topN{i}.imgIds, trainSetPos);
  for j = 1 : length(inds)
    if inds(j) > 0
      topN{i}.meta(j).clust  = selectedClusters(i);
      topN{i}.meta(j).detScore  = topN{i}.scores(j);
      patsPerImg{inds(j)} = [patsPerImg{inds(j)} topN{i}.meta(j)];
    end
  end
end

[allFeatures, allPatches, posCorrespImgs] = ...
  calculateFeaturesFromPyramid(patsPerImg, params, trainSetPos);
[unused, posCorrespInds] = ismember(posCorrespImgs, trainSetPos);
[assignedClustVote, assignedClustTrain] = getAssignedClust(allPatches, ...
  nTop);
selectedClust = getSelectedClusts(assignedClustVote, selectedClusters);
fprintf('Done features\n');
end

function selectClust = getSelectedClusts(assignedClust, selectedClusters)
selectClust = [];
for i = 1 : length(selectedClusters)
  if sum(assignedClust==selectedClusters(i)) > 2
    selectClust = [selectClust; selectedClusters(i)];
  end
end
end

function [topN] = selectN(topN, N)
for i = 1 : length(topN)
  ids = topN{i}.imgIds;
  selInd = find(ids > 0);
  toSel = min(N, length(selInd));
  topN{i}.meta = topN{i}.meta(selInd(1:toSel));
  topN{i}.scores = topN{i}.scores(selInd(1:toSel));
  topN{i}.imgIds = topN{i}.imgIds(selInd(1:toSel));
end
end

function [assignedClustVote, assignedClustTrain] = getAssignedClust( ...
  allPatches, nTop)
assignedClustVote = [allPatches.clust];
assignedClustTrain = assignedClustVote;
clusts = unique(assignedClustVote);
for i = 1 : length(clusts)
  inds = find(assignedClustTrain == clusts(i));
  scores = [allPatches(inds).detScore];
  [unused, sortScore] = sort(scores, 'ascend');
  numToDiscard = max(0, length(inds) - nTop);
  selected = sortScore(1:numToDiscard);
  assignedClustTrain(inds(selected)) = 0;
end
end
