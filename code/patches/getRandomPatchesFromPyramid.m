function [posPatch, posFeats, corrImgs] = getRandomPatchesFromPyramid( ...
  pos, params, imgHome)
% Gets random patches from a set of images.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

posPatchesPerImg = cell(1, length(pos));
posFeatsPerImg = cell(1, length(pos));
totalPatches = 0;
pBar = createProgressBar();
for i = 1 : length(pos)
  pBar(i, length(pos));
  [pats, feats, unused] = sampleRandomPatches(pos(i), imgHome, params);
  posPatchesPerImg{i} = pats;
  posFeatsPerImg{i} = feats;
  totalPatches = totalPatches + length(pats);
end
fprintf('Appending all patches together ...\n');
[posFeats, posPatch, indexes] = appendPatchDataTogether(posFeatsPerImg, ...
  posPatchesPerImg, totalPatches);
corrImgs = indexes(:, 1);
fprintf('Total patches: %d\n', totalPatches);
end
