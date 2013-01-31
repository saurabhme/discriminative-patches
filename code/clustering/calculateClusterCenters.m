function centers = calculateClusterCenters(clustIds, clustMem, features)
% Calculates the centers of the clusters
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

if length(clustMem) ~= size(features, 1)
  error('Refine Clusters: ClustMem is not the same length as features');
end
centers = zeros(length(clustIds), size(features, 2));
for i = 1 : length(clustIds)
  indexs = find(clustMem == clustIds(i));
  centers(i, :) = sum(features(indexs, :)) / length(indexs);
end
end