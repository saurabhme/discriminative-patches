function [model, result] = trainTheClusterSvm(clustId, ...
    assignedClust, posFeatures, negFeatures, flags, fullModel)
% Trains a SVM for the cluster.
%
% A setting of c that could be used is '-s 0 -t 0 -c 1'
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

if nargin < 5
  fullModel = false;
end

if size(negFeatures, 1) == 0
  error('Negfeatures are empty.');
end

posInds = find(assignedClust == clustId);
posFeatures = posFeatures(posInds, :);
features = [posFeatures; negFeatures];
labels = [ones(length(posInds), 1); ones(size(negFeatures, 1), 1) * -1];

fprintf('Training SVM ...  ');
model = mySvmTrain(labels, features, flags, true);

[predictedLabels, accuracy, decision] = mySvmPredict(labels, ...
  features, model);
fprintf('Accuracy: %f %%\n', accuracy);
clear features;

result = struct('predictedLabels', predictedLabels, 'accuracy', ...
  accuracy, 'decision', decision);

% [posSVInds, negSVInds] = findSupportVectorIndices(model.info.model, ...
%   clustInfo.posFeatures, negFeatures);
% [posSVInds, negSVInds] = reorderSupportVectors(posSVInds, ...
%   clustInfo.posFeatures(posSVInds, :), ...
%   negSVInds, negFeatures(negSVInds, :), model);
% model.info.posSVInds = posSVInds;
% model.info.negSVInds = negSVInds;
model.info.flags = flags;
if ~fullModel
  model.info.model = [];
end

fprintf('Done\n');
end

function [posInds, negInds] = findSupportVectorIndices(fullModel, ...
  posFeatures, negFeatures)

sv = fullModel.SVs;
dists = pdist2(sv, negFeatures, 'euclidean');
[vals, inds] = min(dists, [], 2);
negInds = inds(vals == 0);

dists = pdist2(sv, posFeatures, 'euclidean');
[vals, inds] = min(dists, [], 2);
posInds = inds(vals == 0);
end

function [posRe, negRe] = reorderSupportVectors(posInds, posFeatures, ...
  negInds, negFeatures, model)

[unused, unused, decision] = mySvmPredict( ...
  ones(size(posFeatures, 1), 1), posFeatures, model);
[unused, inds] = sort(decision, 'descend');
posRe = posInds(inds);

[unused, unused, decision] = mySvmPredict( ...
  ones(size(negFeatures, 1), 1)*-1, negFeatures, model);
[unused, inds] = sort(decision, 'descend');
negRe = negInds(inds);
end
