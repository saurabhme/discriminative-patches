function data = getPascalData(imgset, VOCopts)
% Prepare the pascal data in a format used by the code.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

ids = textread(sprintf(VOCopts.imgsetpath, imgset), '%s');
% numIds = textread(sprintf(VOCopts.imgsetpath, imgset), '%d');
data = [];
for i = 1 : length(ids);
  fprintf('parsing positives: %d/%d\n', i, length(ids));
  rec = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
  
  item = [];
  item.filename = rec.filename;
  item.folder = '';
  item.imagesize.nrows = rec.size.height;
  item.imagesize.ncols = rec.size.width;
  object = [];
  for j = 1 : length(rec.objects)
    object(j).name = rec.objects(j).class;
    object(j).id = j;
    object(j).crop = rec.objects(j).truncated;
    object(j).polygon.x = [ ...
      rec.objects(j).bndbox.xmin, ...
      rec.objects(j).bndbox.xmax, ...
      rec.objects(j).bndbox.xmax, ...
      rec.objects(j).bndbox.xmin, ...
    ];
    object(j).polygon.y = [ ...
      rec.objects(j).bndbox.ymin, ...
      rec.objects(j).bndbox.ymin, ...
      rec.objects(j).bndbox.ymax, ...
      rec.objects(j).bndbox.ymax, ...
    ];
    object(j).polygon.t = 1;
    object(j).polygon.key = 1;
    object(j).difficult = rec.objects(j).difficult;
  end
  item.object = object;
%   item.id = numIds(i);
  data(i).annotation = item;
end
end  
