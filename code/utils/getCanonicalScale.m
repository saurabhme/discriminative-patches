function [scale, nr, nc] = getCanonicalScale(canonicalSize, rows, cols)
% Author: saurabh.me@gmail.com (Saurabh Singh).
if rows < cols
  scale = canonicalSize / rows;
  nr = rows * scale;
  nc = cols * scale;
else
  scale = canonicalSize / cols;
  nr = rows * scale;
  nc = cols * scale;
end
end
