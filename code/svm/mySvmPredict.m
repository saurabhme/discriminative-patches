function [predictedLabels, accuracy, decision] = mySvmPredict(labels, ...
  features, model)
% Intelligently decide which model it is and do the prediction.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).
if iscell(model) || isfield(model, 'sv_coef')
  disp('Libsvm style model found.');
  if isstruct(model)
    model = {model};
  end
  [predictedLabels, accuracy, decision] = doSvmPredict(labels, ...
    features, model);
elseif isfield(model, 'type')
  switch(model.type)
    case 'composite'
      [predictedLabels, accuracy, decision] = doMyPredictComposite( ...
        labels, features, model);
    case 'minimal'
      [predictedLabels, accuracy, decision] = doMyPredictMinimal( ...
        labels, features, model);
    otherwise
      disp('WARNING: Still using old model');
      [predictedLabels, accuracy, decision] = doMyPredict(labels, ...
        features, model);
  end
else
%   disp('WARNING: Model type not found');
  if ~isfield(model, 'firstLabel')
    disp('WARNING: Still using old model');
    [predictedLabels, accuracy, decision] = doMyPredict(labels, ...
      features, model);
  else
    [predictedLabels, accuracy, decision] = doMyPredictMinimal(labels, ...
      features, model);
  end
end
end

function [predictedLabels, accuracy, decision] = doSvmPredict(labels, ...
  features, model)
[predictedLabels, accuracy, decision] = myLibSvmPredict(labels, ...
  features, model);
end

function [predictedLabels, accuracy, decision] = doMyPredict(labels, ...
  features, model)
% Do the work of svmpredict directly. svmpredict seems to be orders of
% magnitude slower. CAVEAT: This works only for linear kernels.
suppVec = model.SVs;
coeff = model.sv_coef;
coeff = repmat(coeff, 1, size(suppVec, 2));
b = repmat(model.rho, size(features, 1), 1);
w = sum(coeff .* suppVec);

[predictedLabels, accuracy, decision] = doPrediction(w, b, ...
  features, labels, model.Label(1));
end

function [predictedLabels, accuracy, decision] = doMyPredictMinimal( ...
  labels, features, model)
% Do the work of svmpredict directly. svmpredict seems to be orders of
% magnitude slower. CAVEAT: This works only for linear kernels.
b = repmat(model.rho, size(features, 1), 1);
w = model.w;
[predictedLabels, accuracy, decision] = doPrediction(w, b, ...
  features, labels, model.firstLabel);
end

function [predictedLabels, accuracy, decision] = doMyPredictComposite( ...
  labels, features, model)
% Do the work of svmpredict directly. svmpredict seems to be orders of
% magnitude slower. CAVEAT: This works only for linear kernels.

[predictedLabels, accuracy, decision] = doPredictionComposite( ...
  model.w, model.rho, ...
  features, labels, model.firstLabel);
end

function [predictedLabels, accuracy, decision] = doPrediction(w, b, ...
  features, labels, modelFirstLabel)
decision = features * w' - b;
decision = decision * modelFirstLabel;
predictedLabels = sign(decision);
predictedLabels(predictedLabels==0) = -1;
numCorrect = sum(predictedLabels == labels);
accuracy = numCorrect / length(labels);
accuracy = accuracy * 100;
% fprintf('Accuracy = %.2f%% (%d/%d)\n', accuracy, ...
%   numCorrect, length(labels));
end

function [predictedLabels, accuracy, decision] = doPredictionComposite( ...
  W, B, features, labels, modelFirstLabel)
numFeats = size(features, 1);
decision = features * W' - repmat(B', numFeats, 1);
decision = decision .* repmat(modelFirstLabel', numFeats, 1);
predictedLabels = sign(decision);
predictedLabels(predictedLabels==0) = -1;
numCorrect = sum(predictedLabels == labels);
accuracy = numCorrect ./ numFeats;
accuracy = accuracy * 100;
% fprintf('Accuracy = %.2f%% (%d/%d)\n', accuracy, ...
%   numCorrect, length(labels));
end
