function [predictedLabels, accuracy, decision] = myLibSvmPredict(labels, ...
  features, models)
% Author: saurabh.me@gmail.com (Saurabh Singh).
models = reshape(models, 1, []);
predictedLabels = cell(size(models));
accuracy = zeros(size(models));
decision = cell(size(models));
for i = 1 : length(models)
  i
  [predictedLabels{i}, acc, decision{i}] = svmpredict(labels, ...
    features, models{i});
  accuracy(i) = acc(1);
  % Correct the decision values. SVMLIB maps +1 to the first label in the
  % training data and -1 to the other class. This reflects in the trained
  % model as model.Label(1) maps to +1 and model.Label(2) maps to -1. If
  % model.Label = [-1 1] then label '-1' will get +ve decision values and
  % label '+1' will get negative decision values.
  decision{i} = decision{i} * models{i}.Label(1);
end
predictedLabels = cell2mat(predictedLabels);
decision = cell2mat(decision);
end
