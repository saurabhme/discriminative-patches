function splits = getTrainValSplitForCategory(data, category)
% Author: saurabh.me@gmail.com (Saurabh Singh).
fprintf('Making Selection... \n');

[pos neg] = makeSelection(data, category);
trainAllPos = data(pos);
trainAllNeg = data(neg);

%
% trainAllPos = trainAllPos(1:20);
% trainAllNeg = trainAllNeg(1:20);
%

posSplit = ceil(length(trainAllPos) / 2);
negSplit = ceil(length(trainAllNeg) / 2);

splits.trainSetPos = 1 : posSplit;
splits.trainSetNeg = 1 : negSplit;
splits.validSetPos = posSplit + 1 : length(trainAllPos);
splits.validSetNeg = negSplit + 1 : length(trainAllNeg);
splits.allPos = trainAllPos;
splits.allNeg = trainAllNeg;
end
