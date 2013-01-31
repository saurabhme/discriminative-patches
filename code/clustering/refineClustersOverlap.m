function [finGoodClusters, refinedClusters, centers, goodClusterScores] = ...
  refineClustersOverlap( ...
    assignedClust, positivePatches, features, params, correspImgs)
% Refine clusters by
% 1) Removing matches from the same image: Do this intelligently by
% iteratively removing patches
% 
% TODO: Remove outliers from the clusters.
% Author: saurabh.me@gmail.com (Saurabh Singh).

maxOverlap = 0.1;
selectedClusters = selectClustAboveThresh(params, assignedClust);
goodClusters = false(size(selectedClusters));
clusterScores = zeros(size(selectedClusters));
newClusters = false(size(assignedClust));
for i = 1 : length(selectedClusters)
  inds = find(assignedClust==selectedClusters(i));
  relevantPatches = positivePatches(inds);
  relevantFeatures = features(inds, :);
  
  orgImgs = correspImgs(inds);
  scores = getDistanceFromCenterBasedScores(relevantFeatures);
  clusterScores(i) = mean(scores);
  %%%%
  [cleanedUp, ordered] = cleanUpOverlapping(relevantPatches, ...
    scores, orgImgs, maxOverlap);
  if sum(cleanedUp) < params.minClusterSize
    continue;
  end
  selectedPats = ordered;
  if length(selectedPats) > params.maxClusterSize
    selectedPats = selectedPats(1:params.maxClusterSize);
  end
  goodClusters(i) = true;
  newClusters(inds(selectedPats)) = true;
end
finGoodClusters = selectedClusters(goodClusters);
goodClusterScores = clusterScores(goodClusters);
refinedClusters = assignedClust;
refinedClusters(newClusters == false) = 0;
centers = calculateCenters(finGoodClusters, refinedClusters, features);
end

function scores = getDistanceFromCenterBasedScores(feats)
clustCenter = mean(feats);
dists = pdist2(feats, clustCenter, 'euclidean');
scores = exp(-dists ./ norm(dists));
end

function selectedClusters = selectClustAboveThresh(params, assignedClust)
clustIds = unique(assignedClust);
freq = hist(assignedClust, double(clustIds));
set1 = clustIds(freq >= params.minClusterSize);
% set2 = find(clustMembership <= PARAMS.maxClusterSize);
set2 = clustIds(clustIds > 0);
selectedClusters = intersect(set1, set2);
end

function centers = calculateCenters(clustIds, clustMem, features)
if length(clustMem) ~= size(features, 1)
  error('Refine Clusters: ClustMem is not the same length as features');
end
centers = zeros(length(clustIds), size(features, 2));
for i = 1 : length(clustIds)
  indexs = find(clustMem == clustIds(i));
  centers(i, :) = sum(features(indexs, :)) / length(indexs);
end
end
