function numLev = getNumPyramidLevels(rows, cols, intervals, basePatSize)
% Author: saurabh.me@gmail.com (Saurabh Singh).
lev1 = floor(intervals * log2(rows / basePatSize(1)));
lev2 = floor(intervals * log2(cols / basePatSize(2)));
numLev = min(lev1, lev2) + 1;
end
