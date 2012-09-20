%% Prepare the hayes 6 million images data
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

hayes6MillTrainData = getHayes6MillData('train', CONFIG);
save([CONFIG.hayes6MillDataDir 'train.mat'], 'hayes6MillTrainData');
hayes6MillTestData = getHayes6MillData('test', CONFIG);
save([CONFIG.hayes6MillDataDir 'test.mat'], 'hayes6MillTestData');

