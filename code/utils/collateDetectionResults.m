function collateDetectionResults(dataDir, selectedClusters)
% load([procDir 'ALL_DATA.mat']);
% load([procDir 'CLUSTER_PROCESSING_INFO']);

% Find range of data
trainingData = loadAndCheck([dataDir 'trainingData'], 'trainingData');
posIds = trainingData.pos;
negIds = trainingData.neg;

% Save the results
allDetections.allPos = posIds;
allDetections.allNeg = negIds;
% allDetections.results = results;
allDetections.selectedClusters = selectedClusters;
% allDetections.ratios = ratios;
allDetections.posImgs = posIds;
allDetections.negImgs = negIds;
save([dataDir 'all_detections.mat'], 'allDetections');
end
