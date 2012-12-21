function newDets = constructCompositeDetectors(models)
% Creates a composite detector.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

if isempty(models)
  newDets = getInitializedNewDets();
  return;
end

wt = zeros(length(models), ...
  size(models{1}.w, 2));
rh = zeros(length(models), 1);
fl = zeros(length(models), 1);
in = cell(length(models), 1);
th = zeros(length(models), 1);
for i = 1 : length(models)
  md = models{i};
  wt(i, :) = md.w;
  rh(i) = md.rho;
  fl(i) = md.firstLabel;
  in{i} = md.info;
  th(i) = md.threshold;
end

newDets.w = wt;
newDets.rho = rh;
newDets.firstLabel = fl;
newDets.info = in;
newDets.threshold = th;
newDets.type = 'composite';
end

function newDets = getInitializedNewDets()
newDets.w = [];
newDets.rho = [];
newDets.firstLabel = [];
newDets.info = {};
newDets.threshold = [];
newDets.type = 'composite';
end
