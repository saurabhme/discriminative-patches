function [firstDets, secondDets, results] = loadDetectorModels( ...
  firstLevDir, secondLevDir, selectedClusters, suffix)
% Load the learned models. If secondLevDir is empty then only first level
% detectors will be returned.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

firstDets = cell(1, length(selectedClusters));
secondDets = {};
if ~isempty(secondLevDir)
  secondDets = cell(1, length(selectedClusters));
end
results = cell(1, length(selectedClusters));
for i = 1 : length(selectedClusters)
  clustId = selectedClusters(i);
  load([firstLevDir sprintf('%d%s.mat', clustId, suffix)], 'model', ...
    'result');
  firstDets{i} = model;
  results{i} = result;
  if ~isempty(secondLevDir)
    load([secondLevDir sprintf('%d_mix_det.mat', clustId)], 'detectors');
    secondDets{i} = detectors;
  end
end
end
