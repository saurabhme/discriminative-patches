function collateCrossValHardNegMiningResults(inputDir, startId, ...
  endId, detectors, iter, selectedClusters)
% Collate mining results
%
% Author: saurabh.me@gmail.com (Saurabh Singh)

inSuffix = '_hardneg';
totalDetections = 0;
cullingThreshold = -1.002;
imgIds = startId : endId;
numDetectors = detectors.getNumDetectors();
clustMetadata = cell(numDetectors, length(imgIds));
clustFeatures = cell(numDetectors, length(imgIds));
clustInds = zeros(numDetectors, 1);
disp('Reading negative data from all files.');
pbar = createProgressBar();
for i = 1 : length(imgIds)
  pbar(i, length(imgIds));
%   disp(i);
  fileName = [inputDir sprintf('%d', imgIds(i)) inSuffix '.mat'];
  detResults = loadAndCheck(fileName, 'detResults');
  detResFirstLev = detResults.firstLevel;
  
  for j = 1 : length(detResFirstLev.detections)
    if ~isempty(detResFirstLev.detections(j).metadata)
      clustInds(j) = clustInds(j) + 1;
      clustMetadata{j, clustInds(j)} = detResFirstLev.detections(j).metadata;
      clustFeatures{j, clustInds(j)} = detResFirstLev.detections(j).features;
      totalDetections = totalDetections + ...
        length(detResFirstLev.detections(j).metadata);
    end
  end
  clear detResults detResFirstLev;
end
fprintf('Total %d patches were mined\n', totalDetections);

savePerDetectorNegData(clustMetadata, clustFeatures, clustInds, ...
  selectedClusters, inputDir, ...
  cullingThreshold, iter, detectors);
end

function savePerDetectorNegData(metadata, features, indexes, ...
  selectedClusters, outDir, ...
  cullingThreshold, iter, detectors)
disp('Saving negative data for all the clusters.');
pbar = createProgressBar();
for i = 1 : length(selectedClusters)
  pbar(i, length(selectedClusters));
  clustId = selectedClusters(i);
  if iter == 1
    prevFileName = [outDir '../TRAINING_DATA.mat'];
  else
    prevFileName = [outDir sprintf('%d_NEG_MINED_%d.mat', iter-1, ...
      clustId)];
  end
  prevData = load(prevFileName, 'negFeatures', 'negativePatches');

  % Cull the negatives that have very low scores.
  selectedNegs = cullNegatives(prevData.negFeatures, detectors, ...
    cullingThreshold, i);
  prevData.negFeatures = prevData.negFeatures(selectedNegs, :);
  prevData.negativePatches = prevData.negativePatches(selectedNegs);
  
  fileName = [outDir sprintf('%d_NEG_MINED_%d.mat', iter, clustId)];
  negFeatures = [prevData.negFeatures; cell2mat(features(i, 1:indexes(i))')];
  negativePatches = [prevData.negativePatches; ...
    cell2mat(metadata(i, 1:indexes(i)))'];
%   saveAndCheck(fileName, negFeatures, negativePatches);
  save(fileName, 'negFeatures', 'negativePatches');
  clear prevData;
end
end

function selectedNegs = cullNegatives(negFeatures, detectors, ...
  cullingThreshold, detInd)
[unused, unused, decision] = mySvmPredict( ...
  ones(size(negFeatures, 1), size(detectors.firstLevModels.w, 1)) * -1, ...
  negFeatures, detectors.firstLevModels);
decision = decision(:, detInd);
numNegs = size(negFeatures, 1);
% maxSel1 = sum(decision >= cullingThreshold) * 2;
maxSel1 = sum(decision >= cullingThreshold);
maxSel2 = sum(decision >= -1) * 3;
% maxSel2 = sum(decision >= -1);
maxSel = min([maxSel1; maxSel2]);
maxSel(maxSel > numNegs) = numNegs;

[unused, sortedInds] = sort(decision, 'descend');
selectedNegs = false(size(negFeatures, 1), 1);
selectedNegs(sortedInds(1:maxSel)) = true;
end
