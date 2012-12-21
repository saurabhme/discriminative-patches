function pyramid = constructFeaturePyramidForImg(imPath, params, levels)
% levels: What level of pyramid to compute the features for.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

if nargin < 3
  levels = [];
end

I = im2double(imread(imPath));
pyramid = constructFeaturePyramidForRawImg(I, params, levels);
end
