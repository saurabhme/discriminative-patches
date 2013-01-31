function splits = getTrainValSplitUnsupervised(trainAllPos, trainAllNeg)
posSplit = ceil(length(trainAllPos) / 2);
negSplit = ceil(length(trainAllNeg) / 2);

splits.trainSetPos = 1 : posSplit;
splits.trainSetNeg = 1 : negSplit;
splits.validSetPos = posSplit + 1 : length(trainAllPos);
splits.validSetNeg = negSplit + 1 : length(trainAllNeg);
splits.allPos = trainAllPos;
splits.allNeg = trainAllNeg;
end
