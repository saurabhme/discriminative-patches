classdef AutoClust < handle
  % Class representing auto clust on warp.
  %
  % Author: saurabh.me@gmail.com (Saurabh Singh).
  properties
    instanceId;
  end
  
  methods(Static)
    function names = getAllFirstTrainFileNames(selectedClusters, ...
        outputDir)
      names = cell(1, length(selectedClusters));
      outSuffix = 'det';
      for i = 1 : length(selectedClusters)
        clustId = selectedClusters(i);
        names{i} = [outputDir ...
          sprintf('%d_', clustId) outSuffix '.mat'];
      end
    end
  end
  
  methods
    function obj = AutoClust(instanceId)
      obj.instanceId = instanceId;
      
    end
    
    function firstTrainClusters(obj, assignedClust, selectedClusters , ...
      posFeatures, negFeatures, outputDir, svmFlags)
      % Start processing the clusters
      selectedClusters = selectedClusters( ...
        randperm(length(selectedClusters)));

      for i = 1 : length(selectedClusters)
        clustId = selectedClusters(i);
        fileName = [sprintf('%d', clustId) '_det.mat'];
        fprintf('Processing cluster %d\n', clustId);
        if isStillUnprocessed(fileName, outputDir)
          posInds = assignedClust == clustId;
          clustPosFeat = posFeatures(posInds, :);
          [model, result] = trainCluster(clustPosFeat, ...
            negFeatures, svmFlags);
          
          doneProcessing(fileName, outputDir);
          save([outputDir fileName], 'model', 'result');
        end
        fprintf('Done processing cluster %d\n', clustId);
      end
      disp('Done Processing Everything');
    end
  end
end
