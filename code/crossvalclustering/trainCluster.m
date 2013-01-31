function [model, result] = trainCluster(posFeatures, ...
        negFeatures, svmFlags)
% Author: saurabh.me@gmail.com (Saurabh Singh).
  features = [posFeatures; negFeatures];
  labels = [ones(size(posFeatures, 1), 1); ...
    ones(size(negFeatures, 1), 1) * -1];

  fprintf('Training SVM ...  ');
  model = mySvmTrain(labels, features, svmFlags, false);
  [predictedLabels, accuracy, decision] = mySvmPredict(labels, ...
    features, model);

  result = struct('predictedLabels', predictedLabels, 'accuracy', ...
    accuracy, 'decision', decision);
  fprintf('Done\n');
end
