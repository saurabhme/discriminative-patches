function data = getDataSet(name, mode, CONFIG)
% Gets the appropriate data set.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).
switch(name)
  case 'pascal'
    data.imgsHome = CONFIG.pascalImgHome;
   if strcmp(mode, 'train')
      load([CONFIG.pascalDataDir 'PASCAL_DATA.mat'], 'pascalTrainData', ...
        'categories');
      data.data = pascalTrainData;
      data.categories = categories;
    else
      error('Mode %s not supported, {test, train}', mode);
    end
  otherwise
    error('Unrecognized dataset %s', name);
end
end
