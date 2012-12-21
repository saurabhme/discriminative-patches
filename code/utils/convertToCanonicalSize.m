function [INew, scale] = convertToCanonicalSize(I, dim)
[rows, cols, unused_dims] = size(I);
scale = getCanonicalScale(dim, rows, cols);
INew = imresize(I, scale);
end
