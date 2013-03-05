function warpMaxPoolFeaturesUnSup(instanceId)
% Author: saurabh.me@gmail.com (Saurabh Singh).
try
  globals;
  procDir = [CONFIG.processingDir 'pascalProcessingUnSupAll/div2/'];
  outputDir = [procDir 'maxpoolingIter0/'];
  % Initialize instance some variables
  rand('twister', instanceId);
  pause(rand(1, 1) * 10);

  trainOutputDir = [outputDir 'train/'];
  if ~exist(trainOutputDir, 'dir')
    mkdir(trainOutputDir);
  end
  testOutputDir = [outputDir 'test/'];
  if ~exist(testOutputDir, 'dir')
    mkdir(testOutputDir);
  end

  % Load processing data
  fprintf('Loading pooling data ...  \n');
  inputFile = [procDir 'spatialpyramid/ALL_DATA.mat'];
  load(inputFile, 'allData');
%   load([procDir 'POOLING_DATA1.mat'], 'collatedDetector', 'detectionParams');
  load([procDir 'POOLING_DATA_ITER0.mat'], 'collatedDetector', ...
    'detectionParams');
  
  fprintf('Done\n');

  poolType = 'max';
  trainFileNamesPos = genPoolFeats(collatedDetector, allData.trainPosData, ...
    allData.posImgsHome, detectionParams, poolType, [trainOutputDir 'pos/']);
  testFileNamesPos = genPoolFeats(collatedDetector, allData.testPosData, ...
    allData.posImgsHome, detectionParams, poolType, [testOutputDir 'pos/']);
  
  trainFileNamesNeg = genPoolFeats(collatedDetector, allData.trainNegData, ...
    allData.negImgsHome, detectionParams, poolType, [trainOutputDir 'neg/']);
  testFileNamesNeg = genPoolFeats(collatedDetector, allData.testNegData, ...
    allData.negImgsHome, detectionParams, poolType, [testOutputDir 'neg/']);
    
  % Wait for others to get done.
%   waitTillExists(trainFileNamesPos);
%   waitTillExists(testFileNamesPos);
%   waitTillExists(trainFileNamesNeg);
%   waitTillExists(testFileNamesNeg);
  disp('Done pooling data, will now collate ...');
  
%   metadata = getPoolingMetadata(collatedDetector);
%   collateData(instanceId, trainFileNamesPos, metadata, [trainOutputDir 'pos/']);
%   collateData(instanceId, testFileNamesPos, metadata, [testOutputDir 'pos/']);
%   collateData(instanceId, trainFileNamesNeg, metadata, [trainOutputDir 'neg/']);
%   collateData(instanceId, testFileNamesNeg, metadata, [testOutputDir 'neg/']);
catch exception
  displayStackTrace(exception);
end
end

function collateData(instanceId, fileNames, meta, outputDir)
flagFile = [outputDir 'pooled_feats.flag'];
if ~fileExists(flagFile) && instanceId == 1
  pooledFeatures = cell(length(fileNames), 1);
  poolWeights = [];
  pooledLabels = cell(length(fileNames), 1);
  imgIds = cell(length(fileNames), 1);
  for i = 1 : length(fileNames)
    load(fileNames{i}, 'feature', 'weights');
    pooledFeatures{i} = feature;
    poolWeights = weights(1, :);
%     pooledLabels{i} = labels;
    imgIds{i} = ones(size(feature, 1), 1) * i;
  end
  pooledFeatures = cell2mat(pooledFeatures);
%   pooledLabels = cell2mat(pooledLabels);
  imgIds = cell2mat(imgIds);
%   save([outputDir 'pooled_feats.mat'], 'pooledFeatures', 'poolWeights', ...
%     'pooledLabels', 'imgIds');
  save([outputDir 'pooled_feats.mat'], 'pooledFeatures', 'poolWeights', ...
    'imgIds');
  createFlagFile(flagFile);
end
waitTillExists({flagFile});
end

function fileNames = genPoolFeats(collatedDetector, dtm, ...
  imgsHome, detectionParams, poolType, outputDir)

if ~exist(outputDir, 'dir')
  mkdir(outputDir);
end
fileNames = cell(size(dtm));
dim1 = sqrt(size(collatedDetector.firstLevModels.w, 2) / 31);
randInds = randperm(length(dtm));
for ids = 1 : length(randInds)
  i = randInds(ids);
  fileId = sprintf('%d.mat', i);
  fileNames{i} = [outputDir fileId];
  if isStillUnprocessed(fileId, outputDir)
    sample = dtm(i);
    pyra = constructFeaturePyramid(sample, collatedDetector.params, ...
      imgsHome);
    [unused, levels, indexes] = unentanglePyramid(pyra, ...
      collatedDetector.params.patchCanonicalSize);
    [unused, decs] = getDetectionsForEntDets( ...
      collatedDetector.firstLevModels, ...
      pyra, ...
      collatedDetector.params.patchCanonicalSize, sample, imgsHome, ...
      detectionParams);

    numSpaFeat = 5;
    numLevelToProcess = 10;
    feature = zeros(numLevelToProcess, size(decs, 2) * numSpaFeat);
    weights = zeros(numLevelToProcess, numSpaFeat);
        
    for fi = 1 : numLevelToProcess
      [rows, cols, unused] = size(pyra.features{fi});
      rows = rows - dim1 + 1;
      cols = cols - dim1 + 1;
      selInd = levels == fi;
      selDecs = decs(selInd, :);
      if strcmp(poolType, 'hist') || strcmp(poolType, 'sumhist')
        selDecs(selDecs >= -1) = 1;
        selDecs(selDecs < -1) = 0;
      end
      [feat, wts] = doFeaturePooling(selDecs, indexes(selInd, :), ...
        rows, cols, poolType, 2);
      feature(fi, :) = feat;
      weights(fi, :) = wts';
    end
    save(fileNames{i}, 'feature', 'weights');
    doneProcessing(fileId, outputDir);
    fprintf('Done processing image %d\n', i);
    clear feature weights labels;
  end
end
end

function meta = getPoolingMetadata(collatedDetector)
meta.spatialPyramidLevels = 2;
meta.totalFeatureLength = size( ...
  collatedDetector.firstLevModels.w, 1) * ...
  sum(2 .^ (2 * (0:meta.spatialPyramidLevels - 1)));
end

