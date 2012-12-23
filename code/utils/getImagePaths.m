function paths = getImagePaths(data, imgHome)
% Gets the image paths.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

if nargin < 2
  % If no image home is specified then don't prefix image home.
  imgHome = '';
end

paths = cell(size(data));
for i = 1 : length(data)
  thisImg = data(i).annotation;
  paths{i} = [imgHome thisImg.filename];
end
end
