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

warpCrossValClusteringUnsupHayes(1, CONFIG, true);

%% Assimilate the results from different batches.

clustRoot = [CONFIG.processingDir 'pascalClusters/div2/train/'];
outDir = [clustRoot 'assimilated/'];
assimilateCrossValBatchResults(outDir, clustRoot, 4);
