function [results] = detectPresenceUsingEntDet(sample, ...
  detectors, params, imgHome, removeFeatures, detectionParams)

pyra = constructFeaturePyramid(sample, params, imgHome);

if ~iscell(detectors.firstLevel)
  detections = getDetectionsForEntDets(detectors.firstLevel, pyra, ...
    params.patchCanonicalSize, sample, imgHome, detectionParams);
else
  detections = getDetectionsForEntDetsLogReg(detectors.firstLevel, pyra, ...
    params.patchCanonicalSize, sample, imgHome, detectionParams);
end

results.firstLevel = constructResults(sample, detections, ...
  removeFeatures, imgHome);

% Now do second level detections.
if ~isempty(detectors.secondLevel)
  [secDets, secDetInds] = getSecondLevelDetectors(detections, ...
    detectors.secondLevel);
  detections = getDetectionsForEntDets(secDets, pyra, ...
    params.patchCanonicalSize, sample, imgHome, detectionParams);
  results.secondLevel = arrangeSecondLevDets(detections, secDetInds, ...
    length(detectors.firstLevel), removeFeatures, sample, imgHome);
else
  results.secondLevel = {};
end
end

function results = constructResults(sample, detections, removeFeatures, ...
  imgHome)
if removeFeatures
  detections = removeFeaturesFromDets(detections);
end
numDet = 0;
for j = 1 : length(detections)
  numDet = numDet + length(detections(j).metadata);
end

data = sample.annotation;
results = struct( ...
  'numDetections', numDet, ...
  'detections', detections, ...
  'imagePath', [imgHome data.folder '/' data.filename], ...
  'totalProcessed', detections(1).totalProcessed);
end

function [dets, inds] = getSecondLevelDetectors(detections, secondLevDets)
dets = [];
inds = [];
for i = 1 : length(detections)
  if ~isempty(detections(i).metadata)
    dets = [dets secondLevDets{i}];
    inds = [inds i * ones(1, length(secondLevDets{i}))];
  end
end
end

function results = arrangeSecondLevDets(detections, inds, ...
  numFirstLevDets, removeFeatures, sample, imgHome)
uinds = unique(inds);
results = cell(1, numFirstLevDets);
for i = uinds
  dets = detections(inds==i);
  results{i} = constructResults(sample, dets, removeFeatures, imgHome);
end
end

function dets = removeFeaturesFromDets(dets)
for i = 1 : length(dets)
  dets(i).features = [];
end
end