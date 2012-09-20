function model = mySvmTrain(labels, features, flags, fullModel)
% Train a svm and add extra attributes to the model
%
% Author: saurabh.me@gmail.com (Saurabh Singh).
orgModel = svmtrain(labels, features, flags);
if isLinearSvmRequested(flags)
  model = getMinimalModel(orgModel);
  model.info.numPositives = sum(labels==1);
  model.info.numNegatives = length(labels) - model.info.numPositives;
  model.info.nSV = orgModel.nSV;
  model.threshold = 0;
  if fullModel
    model.info.model = orgModel;
  end
else
  model = orgModel;
end
end
