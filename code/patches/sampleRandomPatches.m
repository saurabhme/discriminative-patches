function [patches, patFeats, probabilities] = sampleRandomPatches(pos, ...
  imgHome, params)
% Author: saurabh.me@gmail.com (Saurabh Singh).
levelFactor = params.levelFactor;
data = pos;
pos = pos.annotation;

imPath = getImagePaths(data, imgHome);
imPath = imPath{1};
I = im2double(imread(imPath));

[IS, scale] = convertToCanonicalSize(I, params.imageCanonicalSize);
[rows, cols, unused] = size(IS);
IG = getGradientImage(IS);

pyramid = constructFeaturePyramidForImg(imPath, params);
[features, levels, indexes] = unentanglePyramid(pyramid, ...
  params.patchCanonicalSize);
selLevels = 1 : params.scaleIntervals/2 : length(pyramid.scales);
levelScales = pyramid.scales(selLevels);
numLevels = length(selLevels);
[prSize, pcSize, unused] = getCanonicalPatchHOGSize(params);

patches = [];
patFeats = [];
probabilities = [];
for i = 1 : numLevels
  levPatSize = floor(params.basePatchSize .* levelScales(i));
  numLevPat = floor((rows / (levPatSize(1) / levelFactor)) * ...
    (cols / (levPatSize(2) / levelFactor))*2);
  
  levelPatInds = find(levels == selLevels(i));
  if numLevPat <= 0
    continue;
  end
  
  IGS = IG;
  pDist = getProbDistribution(IGS, levPatSize);
  pDist1d = pDist(:);
  randNums = getRandForPdf(pDist1d, numLevPat);
  probs = pDist1d(randNums);
  [IY, IX] = ind2sub(size(IGS), randNums);
  IY = IY ./ (levelScales(i) * params.sBins);
  IX = IX ./ (levelScales(i) * params.sBins);
  IY = ceil(IY - prSize / 2);
  IX = ceil(IX - pcSize / 2);
  
  [nrows, ncols, unused] = size(pyramid.features{selLevels(i)});
  xyToSel = IY>0 & IY<=nrows-prSize+1 & IX>0 & IX<=ncols-pcSize+1;
  IY = IY(xyToSel);
  IX = IX(xyToSel);
  probs = probs(xyToSel);
  inds = sub2ind([nrows-prSize+1 ncols-pcSize+1], IY, IX);
  [inds, m, unused] = unique(inds);
  probs = probs(m);
  selectedPatInds = levelPatInds(inds);
  metadata = getMetadataForPositives(selectedPatInds, levels,...
    indexes, prSize, pcSize, pos, pyramid, imgHome);
  feats = features(selectedPatInds, :);
  if ~isempty(metadata)
    patInds = cleanUpOverlappingPatches(metadata, ...
      params.patchOverlapThreshold, probs);
    patches = [patches metadata(patInds)];
    patFeats = [patFeats; feats(patInds, :)];
    probabilities = [probabilities probs(patInds)'];
  end
  
end
end

function patInds = cleanUpOverlappingPatches(patches, thresh, probs)
[unused, probInds] = sort(probs, 'descend');
patInds = zeros(1, length(patches));
indCount = 0;
mask = zeros(patches(1).size.nrows, patches(1).size.ncols);
nr = patches(1).y2 - patches(1).y1 + 1;
nc = patches(1).x2 - patches(1).x1 + 1;
patchArea = nr * nc;
for i = 1 : length(probInds)
  p = patches(probInds(i));
  %p
  subMaskArea = sum(sum(mask(p.y1:p.y2, p.x1:p.x2)));
  if subMaskArea / patchArea > thresh
    continue;
  end
  mask(p.y1:p.y2, p.x1:p.x2) = 1;
  indCount = indCount + 1;
  patInds(indCount) = probInds(i);
end
patInds = patInds(1:indCount);
patInds = sort(patInds);
end

function [centers, vertExt] = getCategoryCenters(data, category)
objects = data.annotation.object;
objNames = {objects.name};
[ismem, unused] = ismember(objNames, {category});
primLoc = find(ismem);
centers = zeros(length(primLoc), 2);
vertExt = zeros(length(primLoc), 1);
for j = 1 : length(primLoc)
  vertExt(j) = getVerticalExtent(objects(primLoc(j)));
  [centers(j, 1), centers(j, 2)] = getCenter(objects(primLoc(j)), data);
end
end

function ext = getVerticalExtent(obj)
[x,y] = getLMpolygon(obj.polygon);
ext = max(y) - min(y) + 1;
end

function [cx cy] = getCenter(obj, data)
bb = getBoundingBox(obj, data.annotation);
cx = (bb(1) + bb(3)) / 2;
cy = (bb(2) + bb(4)) / 2;
end

function I1 = getGradientImage(I)
[GX, GY] = gradient(I);
I1 = sum(abs(GX), 3) + sum(abs(GY), 3);
I1 = I1.^2;
end

function dist = getProbDistribution(I, pSize)
h = fspecial('gaussian', pSize, min(pSize)/3);
I = imfilter(I, h);
dist = I ./ sum(sum(I));
end
