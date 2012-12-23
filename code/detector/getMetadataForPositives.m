function [metadata] = getMetadataForPositives(selected, level,...
  indexes, prSize, pcSize, data, pyramid, imgHome)
% Author: saurabh.me@gmail.com (Saurabh Singh).
metadata = struct('im', {}, 'x1', {}, 'x2', {}, 'y1', {}, 'y2', {}, ...
    'flip', {}, 'trunc', {}, 'size', {});
imPath = [imgHome data.folder '/' data.filename];
canoSc = pyramid.canonicalScale;

for i = 1 : length(selected)
  selInd = selected(i);
  levelPatch = getLevelPatch(prSize, pcSize, level(selInd), pyramid);
  levSc = pyramid.scales(level(selInd));
  x1 = indexes(selInd, 2);
  y1 = indexes(selInd, 1);
  xoffset = floor((x1 - 1) * pyramid.sbins * levSc / canoSc) + 1;
  yoffset = floor((y1 - 1) * pyramid.sbins * levSc / canoSc) + 1;
  thisPatch = levelPatch + [xoffset xoffset yoffset yoffset];
  
  metadata(i).x1 = thisPatch(1);
  metadata(i).x2 = thisPatch(2);
  metadata(i).y1 = thisPatch(3);
  metadata(i).y2 = thisPatch(4);
  metadata(i).im = imPath;
  metadata(i).size = data.imagesize;
  metadata(i).flip = false;
  metadata(i).trunc = false;
  % Pyramid information
  metadata(i).pyramid = [level(selInd) indexes(selInd, :)];
  metadata(i) = clipPatchToBoundary(metadata(i));
end
end

function levelPatch = getLevelPatch(prSize, pcSize, level, pyramid)
levSc = pyramid.scales(level);
canoSc = pyramid.canonicalScale;
% [x1 x2 y1 y2]
levelPatch = [ ...
  0, ...
  round((pcSize + 2) * pyramid.sbins * levSc / canoSc) - 1, ...
  0, ...
  round((prSize + 2) * pyramid.sbins * levSc / canoSc) - 1, ...
];
end
