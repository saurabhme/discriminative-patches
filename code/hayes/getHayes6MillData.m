function data = getHayes6MillData(imgSet, config)
% Author: saurabh.me@gmail.com (Saurabh Singh).
NMAX = 6471706;
rand('twister', 1);
randOrder = randperm(NMAX);
maxPerSet = 6000;

imgIds = [];
switch(imgSet)
  case 'train'
    imgIds = randOrder(1:maxPerSet);
  case 'test'
    imgIds = randOrder(maxPerSet+1:2*maxPerSet);
  otherwise
    error('Unrecognized image set request: %s', imgSet);
end

data = struct('annotation', []);
data(length(imgIds)).annotation = [];

pBar = createProgressBar();
for i = 1 : length(imgIds)
  pBar(i, length(imgIds));
  fileName = james_name(imgIds(i));
  I = imread([config.hayes6MillImgHome fileName]);
  [rows, cols, chans] = size(I);
  item = [];
  item.filename = fileName;
  item.folder = '';
  item.imagesize.nrows = rows;
  item.imagesize.ncols = cols;
  item.hayesId = imgIds(i);
  data(i).annotation = item;
end
end
