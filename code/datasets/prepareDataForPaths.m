function data = prepareDataForPaths(imgRoot, imgPaths)
% Converts paths into data format used by the codebase.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

for i = 1 : length(imgPaths)
  item = [];
  item.filename = imgPaths{i};
  item.folder = '';
  
  imInfo = imfinfo([imgRoot imgPaths{i}]);
  item.imagesize.nrows = imInfo.Height;
  item.imagesize.ncols = imInfo.Width;
  
  data(i).annotation = item;
  
end
end
