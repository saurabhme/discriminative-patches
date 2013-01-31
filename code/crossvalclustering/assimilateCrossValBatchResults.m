function assimilateCrossValBatchResults(outDir, dataRoot, iterInd)
if ~exist(outDir, 'dir')
  mkdir(outDir);
end

detectors = assimilateDetectors(dataRoot, iterInd);
save([outDir 'detectors_MINED.mat'], 'detectors');
assimilateDetections(dataRoot, outDir, iterInd);
end

function detectors = assimilateDetectors(dataRoot, iterInd)
batchFlagRoot = [dataRoot '0/'];
initNum = 1000;
detSubDirs = cell(1, initNum);
numDets = 0;
for batchId = 1 : initNum
  batchFlagFile = [batchFlagRoot sprintf('batch_%d.flag', batchId)];
  if fileExists(batchFlagFile)
    detSubDirs{batchId} = sprintf('batch-%d/%d/', batchId, iterInd);
    numDets = numDets + 1;
  else
    break;
  end
end
detSubDirs = detSubDirs(1:numDets);
[detectors, unused, allParams] = collateAllDetectors(dataRoot, detSubDirs, ...
  'detectors_MINED.mat');
detectors.params = allParams{1};
end

function assimilateDetections(dataRoot, outDir, iterInd)
batchFlagRoot = [dataRoot '0/'];
initNum = 1000;
results = cell(1, initNum);
numDets = 0;
allDets = cell(1, initNum);
selClusters = cell(1, initNum);
for batchId = 1 : initNum
  batchFlagFile = [batchFlagRoot sprintf('batch_%d.flag', batchId)];
  if fileExists(batchFlagFile)
    detResDir = [dataRoot sprintf('batch-%d/%d/detectionResult/', batchId, ...
      iterInd)];
    results{batchId} = PresenceDetectionResults(detResDir);
    allDets{batchId} = load([detResDir 'all_detections.mat']);
%     selClusters{batchId} = load([dataRoot ...
%       sprintf('batch-%d/%d/FIG_PATCH_CLUSTERS_REF.mat', batchId, iterInd)], ...
%       'selectedClusters');
    
    selClusters{batchId}.selectedClusters = ...
      allDets{batchId}.allDetections.selectedClusters;
    numDets = numDets + 1;
  else
    break;
  end
end
results = results(1:numDets);
allDets = allDets(1:numDets);
selClusters = selClusters(1:numDets);
posImgs = results{1}.results.posImgs;
posFn = @(x, y) results{x}.getPosResult(y);
posOutDir = [outDir 'detectionResult/pos/'];
assimilateDetectionsForImgs(posFn, numDets, posImgs, posOutDir);
negImgs = results{1}.results.negImgs;
negFn = @(x, y) results{x}.getNegResult(y);
negOutDir = [outDir 'detectionResult/neg/'];
assimilateDetectionsForImgs(negFn, numDets, negImgs, negOutDir);
trainingData.pos = posImgs;
trainingData.neg = negImgs;
save([outDir 'detectionResult/trainingData.mat'], 'trainingData');

selectedClusters = [];
for i = 1 : length(selClusters)
  selectedClusters = [selectedClusters ...
    reshape(selClusters{i}.selectedClusters, 1, [])];
end
allDetections = allDets{1}.allDetections;
allDetections.selectedClusters = selectedClusters';
save([outDir 'detectionResult/all_detections.mat'], 'allDetections');
save([outDir 'SEL_CLUSTS.mat'], 'selectedClusters');
end

function assimilateDetectionsForImgs(imgFun, numBatches, imgSet, outDir)
if ~exist(outDir, 'dir')
  mkdir(outDir);
end

pBar = createProgressBar();
for i = 1 : length(imgSet)
  pBar(i, length(imgSet));
  imgId = imgSet(i);
  numDetections = 0;
  detections = [];
  for j = 1 : numBatches
    res = imgFun(j, imgId);
    numDetections = numDetections + res.firstLevel.numDetections;
    detections = [detections res.firstLevel.detections];
  end
  item.numDetections = numDetections;
  item.detections = detections;
  item.imagePath = res.firstLevel.imagePath;
  item.totalProcessed = res.firstLevel.totalProcessed;
  detResults.firstLevel = item;
  detResults.secondLevel = {};
  save(sprintf('%s/%d_res.mat', outDir, imgId), 'detResults');
end
end
