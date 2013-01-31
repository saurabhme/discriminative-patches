function topN = getTopNDetsPerCluster(detectionResults, ...
  overlap, posIds, N)
% Generate the top N detections.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

numClusters = detectionResults.getNumClusters();
scores = cell(numClusters, 1);
imgIds = cell(numClusters, 1);
meta = cell(numClusters, 1);
maxCacheSize = max(N, 200);
maxToShow = N;

idsToUse = sort(posIds);
pBar = createProgressBar();
for j = 1 : length(idsToUse)
  pBar(j, length(idsToUse));
  id = idsToUse(j);
  res = detectionResults.getPosResult(id);
  for clusti = 1 : numClusters
    [thisScores, imgMeta] = getResultData(res, ...
      clusti, overlap);
    if ~isempty(imgMeta)
%       keyboard;

      if sum([imgMeta.x1] > [imgMeta.x2]) > 0
        keyboard;
      end
    end
    scores{clusti} = [scores{clusti} thisScores'];
    imgIds{clusti} = [imgIds{clusti} ones(1, length(thisScores)) * id];
    meta{clusti} = [meta{clusti} imgMeta];
    if length(scores{clusti}) > maxCacheSize
      [meta{clusti}, scores{clusti}, imgIds{clusti}] = pickTopN( ...
        scores{clusti}, imgIds{clusti}, meta{clusti}, maxToShow, ...
        overlap);
    end
  end
end

% Collate the data.
topN = cell(1, numClusters);
for i = 1 : numClusters
  [topN{i}.meta, topN{i}.scores, topN{i}.imgIds] = pickTopN(scores{i}, ...
    imgIds{i}, meta{i}, maxToShow, overlap);
end
end

function [meta, scores, imgIds] = pickTopN(scores, imgIds, meta, ...
  numToPick, maxOverlap)
  [unused, ordered] = cleanUpOverlapping(meta, scores, ...
    imgIds, maxOverlap);
  toSelect = min(length(ordered), numToPick);
  selected = ordered(1:toSelect);
  meta = meta(selected);
  scores = scores(selected);
  imgIds = imgIds(selected);
end

function [scores, meta] = getResultData(result, clusti, overlap)
  scores = [];
  meta = [];
  
  thisScores = result.firstLevel.detections(clusti).decision;
  if isempty(thisScores)
    return;
  end
  imgMeta = result.firstLevel.detections(clusti).metadata;
  % Do NMS for image.
  picks = doNmsForImg(imgMeta, thisScores, overlap);
  
  scores = thisScores(picks);
  meta = imgMeta(picks);
end
