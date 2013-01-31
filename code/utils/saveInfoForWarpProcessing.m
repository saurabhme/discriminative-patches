function saveInfoForWarpProcessing(saveDir, assignedClust, ...
  centers, selectedClusters, posFeatures, positivePatches, trainSetPos, ...
  trainSetNeg, params, debug)
% CLUSTER_PROCESSING_INFO.mat: Contains information helpful in cluster
% processing. It contains ids for clusters chosen to be processed.
%
% ALL_DATA.mat: It effectively contains all the data that is generated as a
% result of various steps. This could be used by the cluster processing
% step.

if ~exist(saveDir, 'dir')
  mkdir(saveDir);
end

clusterInformation = struct('posFeatures', posFeatures, ...
  'assignedClusters', assignedClust, ...
  'clustersToProcess', selectedClusters, ...
  'centers', centers, 'debug', debug);
save([saveDir 'CLUSTER_PROCESSING_INFO'], 'clusterInformation');
save([saveDir 'ALL_DATA'], 'trainSetPos', 'trainSetNeg', ...
  'positivePatches', 'selectedClusters', 'params');
end