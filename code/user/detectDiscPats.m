%% Do detection of discriminative patches.
% Load up the models.
load([USR.modelDir 'pascal.mat'], 'detectors');

%% Load up the image.

imPaths = {'1.jpg'};
data = prepareDataForPaths(USR.imgDir, imPaths);
%%

I = imread([USR.imgDir imPaths{1}]);

%%
% Run the detectors.
detParams = getDefaultDetectionParams(detectors.params);
detParams.fixedDecisionThresh = -0.9;
res = detectors.detectPresenceInImg(data(1), USR.imgDir, true, detParams);

%% Display the detections

d = res.firstLevel.detections;
clf;
imshow(I);
for i = 1 : length(d)
  if isempty(d(i).metadata)
    continue;
  end
  displayPatchBox(d(i).metadata, d(i).decision);
end

