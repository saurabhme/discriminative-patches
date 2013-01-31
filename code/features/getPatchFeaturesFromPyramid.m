function feats = getPatchFeaturesFromPyramid(patches, pyramid, params)
% Author: saurabh.me@gmail.com (Saurabh Singh).
[nrows, ncols, nzee] = getCanonicalPatchHOGSize(params);
numElement = nrows * ncols * nzee;
feats = zeros(length(patches), numElement);
for i = 1 : length(patches)
  pyramidInfo = patches(i).pyramid;
  pyraLevel = pyramidInfo(1);
  r = pyramidInfo(2);
  c = pyramidInfo(3);
  patFeat = pyramid.features{pyraLevel}(r:r+nrows-1, c:c+ncols-1, :);
  feats(i, :) = reshape(patFeat, 1, []);
end
end
