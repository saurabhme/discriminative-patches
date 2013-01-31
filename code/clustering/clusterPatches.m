function [clusters, centers] = clusterPatches(numClusters, features, ...
  toCluster, numTries)
% Clusters the patches
%
% toCluster: indicator vector indicating what patches to cluster.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

if nargin < 4
  numTries = 1;
end

minSum = 0;
features = features(toCluster, :);
for i = 1 : numTries
  tic;
  [clIds, cents, err] = doYael(numClusters, features);
  toc;
  sumErr = sum(err);
  fprintf('Error sum: %f', sumErr);
  if minSum < eps || sumErr < minSum
    minSum = sumErr;
    clustIds = clIds;
    centers = cents;
    fprintf('    selected');
  end
  fprintf('\n');
end
clusters = zeros(size(toCluster));
clusters(toCluster) = clustIds;
end

function [clustIds, centers, sumErr] = doYael(numClusters, features)
[centers dists clustIds] = yael_kmeans(single(features'), numClusters);
centers = centers';
sumErr = sum(dists);
end
