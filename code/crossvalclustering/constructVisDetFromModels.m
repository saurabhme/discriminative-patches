function detectors = constructVisDetFromModels(trainDir, ...
  selectedClusters, params, suffix)
% Construct initial set of detectors.
[firstLev, unused, unused] = loadDetectorModels(trainDir, [], ...
  selectedClusters, suffix);
detectors = VisualEntityDetectors(firstLev, params);
end
