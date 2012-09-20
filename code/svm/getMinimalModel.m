function minModel = getMinimalModel(model)
% precomputes the weight vectors.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).
suppVec = model.SVs;
coeff = model.sv_coef;
coeff = repmat(coeff, 1, size(suppVec, 2));
minModel.rho = model.rho;
minModel.w = sum(coeff .* suppVec);
minModel.firstLabel = model.Label(1);
if isfield(model, 'threshold')
  minModel.threshold = model.threshold;
end
if isfield(model, 'info')
  minModel.info = model.info;
end
end
