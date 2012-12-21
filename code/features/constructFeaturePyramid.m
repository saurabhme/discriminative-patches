function pyramid = constructFeaturePyramid(data, params, imgsHome, levels)
% levels: What level of pyramid to compute the features for.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

if nargin < 4
  levels = [];
end
imPaths = getImagePaths(data, imgsHome);
pyramid = constructFeaturePyramidForImg(imPaths{1}, params, levels);
end
