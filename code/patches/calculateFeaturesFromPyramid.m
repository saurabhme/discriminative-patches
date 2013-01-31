function [features, collatedPatches, indexes] = ...
  calculateFeaturesFromPyramid(patches, params, imgIds)
% indexes: Index of the image corresponding to the patch.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

allFeatures = cell(size(patches));
tic;
totalPatches = length(patches);
parfor i = 1 : length(patches)
  pPat = patches{i};
  if ~isempty(pPat)
    imPath = pPat(1).im;
    pyra = constructFeaturePyramidForImg(imPath, params);
    feats = getPatchFeaturesFromPyramid(pPat, pyra, params);
    allFeatures{i} = feats;
  end
  fprintf('Patch %d/%d\n', i, totalPatches);
end
toc;
posPatches = [];
allFeat = [];
indexes = [];
disp('Collecting all in one array.');
for i = 1 : length(allFeatures)
  if isempty(allFeatures{i})
    continue;
  end
  posPatches = [posPatches patches{i}];
  allFeat = [allFeat; allFeatures{i}];
  inds = ones(size(allFeatures{i}, 1), 1) * imgIds(i);
  indexes = [indexes; inds];
  allFeatures{i} = [];
  patches{i} = [];
end
disp('Done');
collatedPatches = posPatches;
features = allFeat;
end
