function [INew, scale] = convertToCanonicalSize(I, dim)
% Author: saurabh.me@gmail.com (Saurabh Singh).
[rows, cols, unused_dims] = size(I);
scale = getCanonicalScale(dim, rows, cols);
INew = imresize(I, scale);
end
