%% Train discriminative patches for pascal 2007 subset

categories = {'horse', 'motorbike', 'bus', 'train', 'sofa', 'diningtable'};

%% Prepare the data

dataFileName = [CONFIG.pascalDataDir 'PASCAL_DATA.mat'];
if ~exist(dataFileName, 'file')
  pascalTrainData = getPascalData('trainval', VOCopts);
  save(dataFileName, 'pascalTrainData', 'categories');
end

%% Do the training.

