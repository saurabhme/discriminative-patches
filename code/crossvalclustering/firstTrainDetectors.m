function firstTrainDetectors(instanceId, selectedClusters, assignedClust, ...
  outputDir, posFeatures, negFeatures, negCorrespImgs, trainSetNeg, ...
  svmFlags)

  if ~exist(outputDir, 'dir')
    mkdir(outputDir);
  end

  [negToUse, unused] = ismember(negCorrespImgs, trainSetNeg);
  negFeatures = negFeatures(negToUse, :);
  fprintf('Done\n');

  % Start processing the clusters
  selectedClusters = selectedClusters(randperm(length(selectedClusters)));
  autoClust = AutoClust(10000);
  doneFirstTrain = false;
  while ~doneFirstTrain
    autoClust.firstTrainClusters(assignedClust, selectedClusters, ...
          posFeatures, negFeatures, outputDir, ...
          svmFlags);
     if instanceId == 1
       doneFirstTrain = waitTillExists( ...
         getAllFileNames(selectedClusters, outputDir));
     else
       doneFirstTrain = true;
     end
  end
end

function names = getAllFileNames(selectedClusters, outputDir)
names = cell(size(selectedClusters));
for i = 1 : length(selectedClusters)
  clustId = selectedClusters(i);
  names{i} = [outputDir sprintf('%d', clustId) '_det.mat'];
end
end
