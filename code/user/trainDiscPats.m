%% Train discriminative patches for pascal 2007 subset
% Prepare the data

dataFileName = [CONFIG.pascalDataDir 'PASCAL_DATA.mat'];
if ~exist(dataFileName, 'file')
  categories = {'horse', 'motorbike', 'bus', 'train', 'sofa', 'diningtable'};
  pascalTrainData = getPascalData('trainval', VOCopts);
  save(dataFileName, 'pascalTrainData', 'categories');
else
  load(dataFileName, 'pascalTrainData', 'categories');
end

%% Do the training.
% Note: The third arguments run the training in test mode. This ensures
% that the code finishes in < 10 mins and is just to ensure that it runs
% end to end. To do real run it should be 'false'.
% WARNING: This code is supposed to be run on a cluster with shared file
% system. Otherwise, it will take too long a time to complete the whole
% discovery procedure (> week).
warpCrossValClusteringUnsup(1, CONFIG, true);

%% Assimilate the results from different batches.

clustRoot = [CONFIG.processingDir 'pascalClusters/div2/train/'];
outDir = [clustRoot 'assimilated/'];
assimilateCrossValBatchResults(outDir, clustRoot, 4);
