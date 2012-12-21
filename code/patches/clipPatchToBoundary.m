function patch = clipPatchToBoundary(patchIn)
% Clip a patch to the image boundary
%
% Author: saurabh.me@gmail.com (Saurabh Singh).
patch = patchIn;
rows = patch.size.nrows;
cols = patch.size.ncols;
doWarn = false;
if patch.x1 < 1
  patch.x1 = 1;
  doWarn = true;
end
if patch.y1 < 1
  patch.y1 = 1;
  doWarn = true;
end
if patch.x2 > cols
  patch.x2 = cols;
  doWarn = true;
end
if patch.y2 > rows
  patch.y2 = rows;
  doWarn = true;
end
if doWarn
%   fprintf('WARNING: A patch was clipped. P(%d,%d)(%d,%d):I(%d,%d)\n', ...
%     patchIn.x1, patchIn.y1, patchIn.x2, patchIn.y2, rows, cols);
end
end
