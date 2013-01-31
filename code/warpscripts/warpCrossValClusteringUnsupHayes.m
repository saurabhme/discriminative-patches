function warpCrossValClusteringUnsupHayes(instanceId, CONFIG, testRun)
try
  % Setup if running on a cluster.
  if nargin < 2
    setmeup;
  elseif nargin < 3
    testRun = false;
  end
  
  % Initialize the random number generator. This is to ensure different
  % jobs generate different sequences on cluster.
  rand('twister', instanceId);
  pause(rand(1,1) * 10);

  rootDir = [CONFIG.processingDir 'pascalClusters/'];
  if ~exist(rootDir, 'dir')
    mkdir(rootDir);
  end

  dataSet = 'pascal';
  pascalData = getDataSet(dataSet, 'train', CONFIG);

  categories = pascalData.categories;
  pascalSplits = getTrainValSplitForCategory(pascalData.data, categories);

  outDir = [rootDir 'div2/'];
  if ~exist(outDir, 'dir')
    mkdir(outDir);
  end
  imgsHome.pos = pascalData.imgsHome;
  % Here, for now, we will just use the images for other categories. Paper
  % used random flickr images which can't be released right now.
  imgsHome.neg = pascalData.imgsHome;
  processCategory(categories, pascalSplits.allPos, pascalSplits.allNeg, ...
    imgsHome, outDir, instanceId, testRun);
  
  disp('Done processing all categories');
catch exception
  displayStackTrace(exception);
end
end

function processCategory(category, posData, negData, homeImgs, outDir, ...
  instanceId, testRun)
params = getParamsForCategory(category);
params = params(1);
params.category = category;
params.homeImgs = homeImgs;

splitsFile = [outDir 'SPLITS.mat'];
splitsFlag = [outDir 'SPLITS.flag'];
if ~exist(splitsFile, 'file')
  if instanceId == 1
    splits = getTrainValSplitUnsupervised(posData, negData);
    save(splitsFile, 'splits');
    saveTrainingData(splits, outDir);
    createFlagFile(splitsFlag);
  end
end
while ~waitTillExists({splitsFlag})
end
load(splitsFile, 'splits');

trainOutDir = [outDir 'train/'];
if ~exist(trainOutDir, 'dir')
  mkdir(trainOutDir);
end

if ~testRun
  processImages(splits.allPos, splits.allNeg, splits.trainSetPos, ...
    splits.validSetPos, splits.trainSetNeg, splits.validSetNeg, ...
    trainOutDir, params, instanceId);
else
  % Run it on small number of images to test.
  processImages(splits.allPos, splits.allNeg, splits.trainSetPos(1:5), ...
    splits.validSetPos(1:5), splits.trainSetNeg(1:5), splits.validSetNeg(1:5), ...
    trainOutDir, params, instanceId);
end

% Now run for the other split. (Not used in the paper).
% trainOutDir = [outDir 'valid/'];
% if ~exist(trainOutDir, 'dir')
%   mkdir(trainOutDir);
% end
% processImages(splits.allPos, splits.allNeg, splits.validSetPos, ...
%   splits.trainSetPos, splits.validSetNeg, splits.trainSetNeg, ...
%   trainOutDir, params, instanceId);
end

function processImages(trainAllPos, trainAllNeg, trainSetPos, ...
  validSetPos, trainSetNeg, validSetNeg, outDir, params, ...
  instanceId)

rootDir = [outDir '0/'];
if ~exist(rootDir, 'dir')
  mkdir(rootDir);
end
targetFile = 'FIG_PATCH_CLUSTERS_REF';
flagFileName = [rootDir targetFile '.flag'];

% File names
posCalcFeaturesFile = [rootDir 'POS_CALC_FEATURES.mat'];
negCalcFeaturesFile = [rootDir 'NEG_CALC_FEATURES.mat'];
clustOrgFile = [rootDir 'FIG_PATCH_CLUSTERS_ORG.mat'];
refClustFile = [rootDir 'FIG_PATCH_CLUSTERS_REF.mat'];

if instanceId == 1
  if ~exist(posCalcFeaturesFile, 'file')
    fprintf('Generating random patches for positive images ... \n');
    [positivePatches, posFeatures, posCorrespInds] = ...
      getRandomPatchesFromPyramid(trainAllPos(trainSetPos), params, ...
      params.homeImgs.pos);
    posCorrespImgs = trainSetPos(posCorrespInds)';
    fprintf('Done\n');
    save(posCalcFeaturesFile, 'positivePatches', 'posFeatures', ...
      'posCorrespImgs', 'posCorrespInds');
  else
    load(posCalcFeaturesFile, 'positivePatches', 'posFeatures', ...
      'posCorrespImgs', 'posCorrespInds');
  end

  % Create some negative features
  numNegImgs = min(10, min(length(trainSetNeg), length(validSetNeg)));
  negImgsSet = [trainSetNeg(1 : numNegImgs) validSetNeg(1 : numNegImgs)]';
  if ~exist(negCalcFeaturesFile, 'file')
    fprintf('Generating random patches for negative images ... \n');
    [negativePatches, negFeatures, negCorrespInds] = ...
      getRandomPatchesFromPyramid(trainAllNeg(negImgsSet), params, ...
      params.homeImgs.neg);
    negCorrespImgs = negImgsSet(negCorrespInds);
    fprintf('Done\n');
    save(negCalcFeaturesFile, 'negativePatches', 'negFeatures', ...
      'negCorrespImgs', 'negCorrespInds');
  else
    load(negCalcFeaturesFile, 'negativePatches', 'negFeatures', ...
      'negCorrespImgs', 'negCorrespInds');
  end
  
  if ~exist(clustOrgFile, 'file')
    disp('Clustering ...');
    toCluster = true(1, size(posFeatures, 1));
    params.numPatchClusters = floor(sum(toCluster) / 4);
    [assignedClust, centers] = clusterPatches(params.numPatchClusters, ...
      posFeatures, toCluster);
    fprintf('Done clustering. Found %d clusters.\n', size(centers, 1));

    save(clustOrgFile, 'assignedClust', 'centers', ...
      'positivePatches', 'posFeatures', 'posCorrespImgs', 'posCorrespInds');
  else
    load(clustOrgFile, 'assignedClust', 'centers', ...
      'positivePatches', 'posFeatures', 'posCorrespImgs', 'posCorrespInds');
  end

  if ~exist(refClustFile, 'file')
    fprintf('Refining clusters ... \n');
    [goodClusters, refinedClusters, centers] = refineClustersOverlap( ...
      assignedClust, positivePatches, posFeatures, params, posCorrespInds);
    fprintf('Done refining clusters. %d clusters remaining.\n', ...
      length(goodClusters));
    selectedClusters = goodClusters;
    featsToProcess = refinedClusters > 0;
    assignedClust = refinedClusters(featsToProcess);
    positivePatches = positivePatches(featsToProcess);
    posFeatures = posFeatures(featsToProcess, :);
    posCorrespInds = posCorrespInds(featsToProcess);
    posCorrespImgs = posCorrespImgs(featsToProcess);
    save(refClustFile, 'assignedClust', ...
      'centers', 'params', 'selectedClusters', 'positivePatches', ...
      'posFeatures', 'posCorrespInds', 'posCorrespImgs');
  else
    load(refClustFile, 'assignedClust', ...
      'centers', 'params', 'selectedClusters', 'positivePatches', ...
      'posFeatures', 'posCorrespInds', 'posCorrespImgs');
  end
  
  debug.assignedClustVote = assignedClust;
  debug.assignedClustTrain = assignedClust;
  saveInfoForWarpProcessing(rootDir, assignedClust, ...
    centers, selectedClusters, posFeatures, positivePatches, ...
    trainSetPos, trainSetNeg, params, debug);
  createFlagFile(flagFileName);
  doneProcessing(targetFile, rootDir);
end

while ~waitTillExists({flagFileName})
end

load(refClustFile, 'assignedClust', 'centers', 'params', ...
  'posCorrespInds', 'posCorrespImgs');
posFeatures = loadAndCheck(refClustFile, 'posFeatures');
positivePatches = loadAndCheck(refClustFile, 'positivePatches');
negFeatures = loadAndCheck(negCalcFeaturesFile, 'negFeatures');
negativePatches = loadAndCheck(negCalcFeaturesFile, 'negativePatches');
negCorrespInds = loadAndCheck(negCalcFeaturesFile, 'negCorrespInds');
negCorrespImgs = loadAndCheck(negCalcFeaturesFile, 'negCorrespImgs');

% Prepare the training data.
trainingData = v2struct(trainAllPos, trainAllNeg, trainSetPos, trainSetNeg, ...
  validSetPos, validSetNeg, negFeatures, negativePatches, negCorrespInds, ...
  negCorrespImgs, posFeatures, positivePatches, posCorrespInds, ...
  posCorrespImgs, assignedClust, params);

selectedClustersAll = loadAndCheck(refClustFile, 'selectedClusters');
processingBatchSize = 500;
% processingBatchSize = 10;
currInd = 1;
targetInd = length(selectedClustersAll);
batchInd = 1;
while currInd <= targetInd
  endInd = currInd + processingBatchSize - 1;
  if endInd > targetInd
    endInd = targetInd;
  end
  
  fprintf('Processing batch %d : %d\n', currInd, endInd);
  % Batch flag file
  batchFlagFile = sprintf('%sbatch_%d.flag', rootDir, batchInd);
  if ~fileExists(batchFlagFile)
    selectedClusters = selectedClustersAll(currInd:endInd);
    [batchDir, thisIterDir] = initializeBatchDir(outDir, batchInd, ...
      refClustFile, negCalcFeaturesFile, posCalcFeaturesFile, ...
      selectedClusters, instanceId);
    
    debug.assignedClustVote = assignedClust;
    debug.assignedClustTrain = assignedClust;
    
    trainingData.selectedClusters = selectedClusters;
    trainingData.debug = debug;
    
    doTheIterations(instanceId, thisIterDir, trainingData, batchDir);
    
    if instanceId == 1
      createFlagFile(batchFlagFile);
    end
    while ~waitTillExists({batchFlagFile})
    end

  else
    fprintf('Found batch file [%s], skipping batch.\n', batchFlagFile);
  end
  
  batchInd = batchInd + 1;
  currInd = endInd + 1;
end
end

function [batchDir, batchIter0] = initializeBatchDir(rootDir, batchId, ...
  refClustFile, negCalcFeaturesFile, posCalcFeaturesFile, selectedClusters, ...
  instanceId)
batchDir = sprintf('%sbatch-%d/', rootDir, batchId);
batchIter0 = [batchDir '0/'];
if instanceId == 1
  fprintf('Initializing [%s]\n', batchIter0);
  mkdir(batchIter0);
%   dataDir = [rootDir '0/'];
%   status = unix(['cp ' posCalcFeaturesFile ' ' batchIter0]);
%   status = unix(['cp ' negCalcFeaturesFile ' ' batchIter0]);
%   status = unix(['cp ' refClustFile ' ' batchIter0]);
%   [prefix, fileName, fileExt] = fileparts(refClustFile);
%   save([batchIter0 fileName fileExt ], 'selectedClusters', '-append');
end
end

function doTheIterations(instanceId, thisIterDir, trainingData, outDir)
% Actually do the iterations.

storeIterationData(instanceId, thisIterDir, trainingData);
for i = 0 : 2 : 4
  iterFlagFile = [thisIterDir 'prev_iter_complete.flag'];
  nextIterDir = [outDir sprintf('%d/', i + 1)];
  mkdir(nextIterDir);
  if ~exist(iterFlagFile, 'file')
    iterDataFileName = getIterationDataFileName(thisIterDir);
    iterTrainingData = load(iterDataFileName);
    fprintf('Starting iteration %s\n', thisIterDir);
    iterateTraining(instanceId, thisIterDir, nextIterDir, iterTrainingData);
  end
  
  % Quit if iterations complete.
  if i == 4
    break;
  end
  
  thisIterDir = nextIterDir;
  nextIterDir = [outDir sprintf('%d/', i + 2)];
  mkdir(nextIterDir);
  iterFlagFile = [thisIterDir 'prev_iter_complete.flag'];
  % Just flip the information.
  if ~exist(iterFlagFile, 'file')
    iterDataFileName = getIterationDataFileName(thisIterDir);
    iterTrainingData = load(iterDataFileName);
    fprintf('Starting iteration %s\n', thisIterDir);
    iterateTraining(instanceId, thisIterDir, nextIterDir, iterTrainingData);
  end
  thisIterDir = nextIterDir;
end
end

function trainingData = swapTrainValSets(trainingData)
tmp = trainingData.trainSetPos;
trainingData.trainSetPos = trainingData.validSetPos;
trainingData.validSetPos = tmp;

tmp = trainingData.trainSetNeg;
trainingData.trainSetNeg = trainingData.validSetNeg;
trainingData.validSetNeg = tmp;
end

function storeIterationData(instanceId, iterDir, trainingData)
flagFile = [iterDir 'TRAINING_DATA.flag'];
if instanceId == 1 && ~exist(flagFile, 'file')
  save(getIterationDataFileName(iterDir), '-struct', 'trainingData');
  createFlagFile(flagFile);
end
while ~waitTillExists({flagFile})
end
end

function fileName = getIterationDataFileName(iterDir)
  fileName = [iterDir 'TRAINING_DATA.mat'];
end

function iterateTraining(instanceId, thisIterDir, nextIterDir, trainingData)
params = trainingData.params;
initDetectorFile = [thisIterDir 'INIT_DETECTOR_VOTE.mat'];
if ~exist(initDetectorFile, 'file')
  firstTrainDir = [thisIterDir 'firstTrainDir/'];
  fprintf('Running first training script.\n');
  firstTrainDetectors(instanceId, trainingData.selectedClusters, ...
    trainingData.assignedClust, ...
    firstTrainDir, trainingData.posFeatures, trainingData.negFeatures, ...
    trainingData.negCorrespImgs, trainingData.trainSetNeg, ...
    params.svmflags)
  
  if instanceId == 1
    detectors = constructVisDetFromModels(firstTrainDir, ...
      trainingData.selectedClusters, params, '_det');
    save(initDetectorFile, 'detectors');
  end
end
while ~waitTillExists({initDetectorFile})
end
detectors = loadAndCheck(initDetectorFile, 'detectors');

detectorFile = [thisIterDir 'detectors_MINED.mat'];
if ~exist(detectorFile, 'file')
  hardNegOut = [thisIterDir 'hardNegMineDir/'];
  fprintf('Starting hard mining.\n');
  hardNegMineTrainDetectors(instanceId, thisIterDir, hardNegOut, ...
    detectors, trainingData);
end
while ~waitTillExists({detectorFile})
end
detectors = loadAndCheck(detectorFile, 'detectors');

detectionOut = [thisIterDir 'detectionResult/'];
detectionFile = [detectionOut 'all_detections.mat'];
if ~exist(detectionFile, 'file')
  mkdir(detectionOut);
  detectPresenceUsingDetectors(instanceId, thisIterDir, detectionOut, ...
    detectors, trainingData.selectedClusters);
end
while ~waitTillExists({detectionFile})
end

flagFile = [thisIterDir 'prev_iter_complete.flag'];
if instanceId == 1 && ~exist(flagFile, 'file')
  fprintf('Finalizing iteration: %s\n', thisIterDir);
  load(detectionFile, 'allDetections');
  detectionResult = PresenceDetectionResults(detectionOut);
  
  % Ignore negs as we don't include them.
%   negInds = validSetNeg(1 : length(posInds));
  numTopN = 20;
  maxOverlap = 0.1;
  trainTopN = getTopNDetsPerCluster(detectionResult, maxOverlap, ...
    trainingData.trainSetPos, numTopN);
  save([thisIterDir 'TRAIN_TOP_N'] , 'trainTopN');
  topN = getTopNDetsPerCluster(detectionResult, maxOverlap, ...
    trainingData.validSetPos, numTopN);
  save([thisIterDir 'TOP_N'] , 'topN');

  [posFeatures, positivePatches, ...
    posCorrespInds, posCorrespImgs, assignedClustVote, ...
    assignedClustTrain, selectedClusters] = ...
    prepareDetectedPatchClusters(topN, ...
      10, 5, params, trainingData.validSetPos, trainingData.selectedClusters);
  posCorrespImgs = trainingData.validSetPos(posCorrespInds);
  assignedClust = assignedClustTrain;
  centers = calculateClusterCenters(selectedClusters, assignedClust, ...
    posFeatures);
  
  % Prepare the data for the next iterations.
  debug.assignedClustVote = assignedClustVote;
  debug.assignedClustTrain = assignedClustTrain;

  resTrainingData = swapTrainValSets(trainingData);
  resTrainingData.posFeatures = posFeatures;
  resTrainingData.positivePatches = positivePatches;
  resTrainingData.posCorrespInds = posCorrespInds;
  resTrainingData.posCorrespImgs = posCorrespImgs;
  resTrainingData.assignedClust = assignedClust;
  resTrainingData.selectedClusters = selectedClusters;
  resTrainingData.centers = centers;
  resTrainingData.debug = debug;
  
  storeIterationData(instanceId, nextIterDir, resTrainingData)
  createFlagFile(flagFile);
end
while ~waitTillExists({flagFile})
end
end

function saveTrainingData(splits, outDir)
trainAllPos = splits.allPos;
trainAllNeg = splits.allNeg;
trainSetPos = splits.trainSetPos;
trainSetNeg = splits.trainSetNeg;
validSetPos = splits.validSetPos;
validSetNeg = splits.validSetNeg;
save([outDir 'TRAINING_DATA'], 'trainAllPos', 'trainAllNeg', ...
  'trainSetPos', 'trainSetNeg', 'validSetPos', 'validSetNeg');
end
