function [posData, negData, allPosData, allNegData] = getDataToProcess( ...
  mode, processingDir)
% Author: saurabh.me@gmail.com (Saurabh Singh).
switch(mode)
  case 'Test'
    fprintf('Loading testing images data ...  \n');
    load([processingDir 'TESTING_DATA'], 'testAllPos', 'testAllNeg', ...
      'testSetPos', 'testSetNeg');
    disp('done');
    posData = testSetPos;
    negData = testSetNeg(1 : length(testSetPos));
    allPosData = testAllPos;
    allNegData = testAllNeg;
  case 'Train'
    fprintf('Loading training images data ...  \n');
    load([processingDir 'TRAINING_DATA'], 'trainAllPos', 'trainAllNeg', ...
      'trainSetPos', 'trainSetNeg', 'validSetPos', 'validSetNeg');
    disp('done');
    posData = [trainSetPos validSetPos];
    negData = [trainSetNeg(1:length(trainSetPos)) ...
      validSetNeg(1:length(validSetPos))];
    allPosData = trainAllPos;
    allNegData = trainAllNeg;
  otherwise
    error('Invalid mode %s', mode);
end
end
