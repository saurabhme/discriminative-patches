function pyramid = constructFeaturePyramidForRawImg(I, params, levels)
% levels: What level of pyramid to compute the features for.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

canonicalSize = params.imageCanonicalSize;
sBins = params.sBins;

[IS, canoScale] = convertToCanonicalSize(I, canonicalSize);
[rows, cols, chans] = size(IS);
if chans < 3
  I = repmat(I, [1 1 3]);
  disp('WARNING: Image has < 3 channels, replicating channels');
end

numLevels  = getNumPyramidLevels(rows, cols, params.scaleIntervals, ...
  params.basePatchSize);
scales = getLevelScales(numLevels, params.scaleIntervals);
if nargin < 3 || isempty(levels)
  levels = 1 : numLevels;
end

pyramidLevs = cell(1, numLevels);
for i = 1 : length(levels)
  lev = levels(i);
  I1 = imresize(I, canoScale / scales(lev));
  [nrows, ncols, unused_dims] = size(I1);
  rowRem = rem(nrows, sBins);
  colRem = rem(ncols, sBins);
  if rowRem > 0 || colRem > 0
    I1 = I1(1:nrows-rowRem, 1:ncols-colRem, :);
  end
  feat = features(I1, sBins);
  pyramidLevs{lev} = feat(:, :, 1:31);
end
canoSize.nrows = rows;
canoSize.ncols = cols;
pyramid = struct('features', {pyramidLevs}, 'scales', scales, ...
  'canonicalScale', canoScale, 'sbins', sBins, 'canonicalSize', canoSize);
end
