function detectPresenceUsingDetectors(instanceId, procDir, outputDir, ...
  detectors, selectedClusters, detectionParams, mode)
% Author: saurabh.me@gmail.com (Saurabh Singh).
try

if ~exist('mode', 'var')
  mode = 'Train'; %'Test'; % 'Train'
end

if ~exist(outputDir, 'dir')
  mkdir(outputDir);
end
posOutputDir = [outputDir 'pos/'];
if ~exist(posOutputDir, 'dir')
  mkdir(posOutputDir);
end
negOutputDir = [outputDir 'neg/'];
if ~exist(negOutputDir, 'dir')
  mkdir(negOutputDir);
end

[posData, negData, allPosData, allNegData] = getDataToProcess(mode, ...
  procDir);

% Initialize the detection parameters.
if ~exist('detectionParams', 'var')
  detectionParams = getDetectionParams(detectors.params);
end

% Start processing the images
outSuffix = '_res';
posFiles = processImages(allPosData, posData, detectors, ...
  posOutputDir, outSuffix, detectors.params.homeImgs.pos, detectionParams);
negFiles = processImages(allNegData, negData, detectors, ...
  negOutputDir, outSuffix, detectors.params.homeImgs.neg, detectionParams);

saveDataInfo(posData, negData, outputDir)
disp('Done Processing Everything');
% Wait for others to get done.
while ~waitTillExists(posFiles)
end
while ~waitTillExists(negFiles)
end
collateData(instanceId, outputDir, selectedClusters);
catch exception
displayStackTrace(exception);
end
end

function collateData(instanceId, outputDir, selectedClusters)
flagFile = [outputDir 'all_detections.flag'];
if ~exist(flagFile, 'file') && instanceId == 1
  collateDetectionResults(outputDir, selectedClusters)
  createFlagFile(flagFile);
end
waitTillExists({flagFile});
end

function fileNames = processImages(data, imageIds, detectors, ...
  outputDir, outSuffix, imgHome, detectionParams)
randInds = randperm(length(imageIds));
fileNames = cell(size(imageIds));
for i = 1 : length(randInds)
  ind = randInds(i);
  imgId = imageIds(ind);
  fileId = sprintf('%d%s.mat', imgId, outSuffix);
  fileNames{ind} = [outputDir fileId];
  if isStillUnprocessed(fileId, outputDir)
    fprintf('Processing image %d\n', imgId);
    detResults = detectors.detectPresenceInImg(data(imgId), imgHome, ...
      true, detectionParams);
    
    save(fileNames{ind}, 'detResults');
    doneProcessing(fileId, outputDir);
    fprintf('Done processing image %d\n', imgId);
  end
end
end

function detectionParams = getDetectionParams(params)
detectionParams = struct( ...
  'selectTopN', false, ...
  'useDecisionThresh', true, ...
  'overlap', params.overlapThreshold, ...
  'fixedDecisionThresh', -1);

%'overlap', 1.1, ...
%'overlap', params.overlapThreshold, ...
end

function saveDataInfo(testSetPos, testSetNeg, outputDir)
fileNameBase = 'trainingData.mat';
if isStillUnprocessed(fileNameBase, outputDir)
  trainingData.pos = testSetPos;
  trainingData.neg = testSetNeg;
  save([outputDir fileNameBase], 'trainingData');
  doneProcessing(fileNameBase, outputDir);
end
end


