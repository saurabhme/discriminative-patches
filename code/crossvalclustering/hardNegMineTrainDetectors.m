function hardNegMineTrainDetectors(instanceId, procDir, outputDir, ...
  detectors, trainingData)

  if ~exist(outputDir, 'dir')
    mkdir(outputDir);
  end

  % Select a maximum of 2000 images to mine.
  trainAllNeg = trainingData.trainAllNeg;
  trainSetNeg = trainingData.trainSetNeg;
  
  trainSetNeg = trainAllNeg(trainSetNeg);
  cutoff = min(length(trainSetNeg), 2000);
  % cutoff = min(length(trainSetNeg), 2);
  trainSetNeg = trainSetNeg(1 : cutoff);

  % Initialize the detection parameters.
  detectionParams = getDetectionParams(detectors.params);

  % Start processing the images
  outSuffix = '_hardneg';

  detectors = startMining(instanceId, trainSetNeg, outputDir, ...
    detectionParams, outSuffix, trainingData, ...
    detectors.params, detectors);
  disp('Done Processing Everything');

  fullDetFileName = [procDir 'detectors_MINED'];
  flagFileName = [fullDetFileName '.flag'];
  if instanceId == 1
    saveAndCheck(fullDetFileName, detectors);
    createFlagFile(flagFileName);
  end
  while ~waitTillExists({flagFileName})
  end
end

function detectors = startMining(instanceId, negs, outputDir, ...
  detectionParams, outSuffix, trainingData, params, detectors)
currentInd = 1;
maxElements = length(negs);
iter = 1;
startImgsPerIter = 5;
alpha = 0.7;
while currentInd <= maxElements
  imgsPerIter = floor(startImgsPerIter * 2^((iter - 1)*alpha));
  
  iterFlagFile = [outputDir sprintf('iteration_%d.flag', iter)];
  detFileName = sprintf('detectors_%d', iter);
  % Mine a:b images
  finInd = min(currentInd + imgsPerIter - 1, maxElements);
  if ~fileExists(iterFlagFile)
    disp('Doing Mining');
    tic;
    doMining(negs, currentInd, finInd, outSuffix, outputDir, ...
      params.homeImgs.neg, ...
      detectionParams, detectors, iter, instanceId);
    toc;
    disp('Done Mining');

    % collate the mining results
    disp('Collating mining results');
    tic;
    collateMiningResults(instanceId, currentInd, finInd, outputDir, ...
      detectors, iter, trainingData.selectedClusters);
    toc;
    disp('Done collating mining results');

    % Train detectors
    disp('Training detectors');
    tic;
    trainDetectors(trainingData, outputDir, iter, params.svmflags, instanceId)
    
    toc;
    disp('Done training models');

    % Construct the detectors.
    disp('Collating trained models');
    detectors = collateTrainedModels(outputDir, ...
      trainingData.selectedClusters, params, detFileName, iter, ...
      instanceId);
    disp('Done collating trained models');
    createFlagFile(iterFlagFile);
  end
  currentInd = finInd + 1;
  iter = iter + 1;
  detectors = loadAndCheck([outputDir detFileName '_det.mat'], ...
    'detectors');
end
end

function doMining(data, currInd, finInd, outSuffix, ...
  outputDir, imgHome, detectionParams, detectors, iter, instanceId)
% Skip if this iteration is done.
flagFileName = [outputDir sprintf('%d_NEG_MINED.flag', iter)];
if fileExists(flagFileName)
  return;
end

allInds = currInd : finInd;
randInds = allInds(randperm(length(allInds)));
miningSuccess = false;
while ~miningSuccess
  for i = 1 : length(randInds)
    imgId = randInds(i);
    fileName = sprintf('%d%s.mat', imgId, outSuffix);
    if isStillUnprocessed(fileName, outputDir)
      fprintf('Mining image %d\n', imgId);
      detResults = detectors.detectPresenceInImg(data(imgId), imgHome, ...
        false, detectionParams);
      save([outputDir fileName], ...
        'detResults');
      doneProcessing(fileName, outputDir);
      fprintf('Done mining image %d\n', imgId);
    end
  end
  if instanceId == 1
    names = getAllDetResultFileNames(currInd, finInd, outputDir, outSuffix);
    miningSuccess = waitTillExists(names);
  else
    miningSuccess = true;
  end
end
end

function collateMiningResults(instanceId, startInd, lastInd, outputDir, ...
  detectors, iter, selectedClusters)
flagFileName = [outputDir sprintf('%d_NEG_MINED.flag', iter)];
if instanceId == 1 && ~fileExists(flagFileName)
  collateCrossValHardNegMiningResults(outputDir, startInd, lastInd, ...
    detectors, iter, selectedClusters);
  createFlagFile(flagFileName);
  removeUselessMiningData(startInd, lastInd, iter, outputDir);
end
while ~waitTillExists({flagFileName})
end
end

function removeUselessMiningData(startInd, lastInd, iter, outDir)
names = cell(1, lastInd - startInd + 1);
ind = 0;
for i = startInd : lastInd
  ind = ind + 1;
  names{ind} = [outDir sprintf('%d_hardneg.mat', i)];
end
% Delete all the hardneg files that were created in this iteration.
disp('Deleting useless hardneg files.');
delete(names{:});
% Delete all the collate files from the previous iteration as they will not
% be needed anymore.
if iter > 1
  fprintf('Deleting iter %d files.\n', iter - 1);
  delete([outDir sprintf('%d_NEG_MINED_*.mat', iter - 1)]);
end
end

function names = getAllDetResultFileNames(startInd, lastInd, outputDir, ...
  outSuffix)
names = cell(1, lastInd - startInd + 1);
ind = 0;
for i = startInd : lastInd
  ind = ind + 1;
  names{ind} = [outputDir sprintf('%d', i) outSuffix '.mat'];
end
end

function trainDetectors(trainingData, outputDir, iter, svmFlags, instanceId)
selectedClusters = trainingData.selectedClusters;
assignedClust = trainingData.assignedClust;
posFeatures = trainingData.posFeatures;

% Start processing the clusters
randInds = randperm(length(selectedClusters));
trainingSuccess = false;
while ~trainingSuccess
  for i = 1 : length(randInds)
    clustId = selectedClusters(randInds(i));
    fileName = sprintf('%d_%d_det.mat', clustId, iter);
    if isStillUnprocessed(fileName, outputDir)
      negDataFileName = [outputDir sprintf('%d_NEG_MINED_%d.mat', ...
        iter, clustId)];
      negFeatures = loadAndCheck(negDataFileName, 'negFeatures');
      fprintf('Training cluster %d\n', clustId);
      [model, result] = trainTheClusterSvm(clustId, ...
        assignedClust, posFeatures, negFeatures, svmFlags, false);
      clear negFeatures;
      save([outputDir fileName], 'model', 'result');
      clear model result;
      doneProcessing(fileName, outputDir);
      fprintf('Done training cluster %d\n', clustId);
    end
  end
  if instanceId == 1
    names = getAllModelFileNames(selectedClusters, outputDir, '_det', iter);
    trainingSuccess = waitTillExists(names);
  else
    trainingSuccess = true;
  end
end
disp('Done training detectors');
end

function detectors = collateTrainedModels(trainDir, selectedClusters, ...
  params, detFileName, iter, instanceId)
outSuffix = '_det';
names = getAllModelFileNames(selectedClusters, trainDir, outSuffix, iter);
flagFileName = [trainDir detFileName outSuffix '.flag'];
detSuffix = sprintf('_%d_det', iter);
fullDetFileName = [trainDir detFileName outSuffix];
if instanceId == 1 && ~fileExists(flagFileName)
  detectors = constructVisDetFromModels(trainDir, selectedClusters, params, ...
    detSuffix);
  saveAndCheck(fullDetFileName, detectors);
  
  createFlagFile(flagFileName);
  % Delete the files, as they are not needed anymore.
  disp('Deleting individual model files.');
  delete(names{:});
end
while ~waitTillExists({flagFileName})
end
detectors = loadAndCheck(fullDetFileName, 'detectors');
end

function names = getAllModelFileNames(clustIds, outputDir, outSuffix, iter)
names = cell(1, length(clustIds));
for i = 1 : length(clustIds)
  fileName = sprintf('%d_%d', clustIds(i), iter);
  names{i} = [outputDir sprintf('%s', fileName) outSuffix '.mat'];
end
end

function saveAndCheck(fileName, detectors)
maxIter = 20;
pauseInterval = 10;
done = false;
for i = 1 : maxIter
  save(fileName, 'detectors');
  for j = 1 : maxIter
    try
      load(fileName);
      done = true;
      break;
    catch exp
      % Try again.
      disp('Potential problem saving, will retry.');
      pause(pauseInterval + pauseInterval * rand(1));
    end
  end
  if done
    break;
  end
end
end

function detectionParams = getDetectionParams(params)
detectionParams = struct( ...
  'selectTopN', false, ...
  'useDecisionThresh', true, ...
  'overlap', params.overlapThreshold, ...
  'fixedDecisionThresh', -1.002);
end
