function [pooled, wts] = doFeaturePooling(responses, indexes, rows, ...
  cols, poolType, poolingLevels)
% Does feature pooling for the responses for a given level of image
% pyramid.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

requiredRowCols = 2^(poolingLevels - 1);
if rows < requiredRowCols || cols < requiredRowCols
  disp('For %d levels, there should be a minimum of %d rows and cols', ...
    poolingLevels, requiredRowCols);
  keyboard;
end

switch(poolType)
  case 'max'
    poolFn = @max;
  case 'avg'
    poolFn = @mean;
  case 'hist'
    % In case of sum pooling, level wise weights will be multiplied.
    poolFn = @sum;
  case 'sumhist'
    poolFn = @sum;
  otherwise
    error('Unrecognized pooling option "%s"', poolType);
end

[spaceRanges, wts] = getSpatialRangesForPooling(rows, cols, poolingLevels);
1 ./ wts;
pooled = doPooling(responses, indexes, spaceRanges, wts, poolFn, poolType);
end

function pooled = doPooling(responses, indexes, spaceRanges, weights, ...
  poolFn, poolType)
numClusters = size(responses, 2);
pooled = zeros(numClusters, size(spaceRanges, 1));
for i = 1 : size(spaceRanges, 1)
  rowSel = indexes(:, 1) >= spaceRanges(i, 1) & ...
    indexes(:, 1) <= spaceRanges(i, 2) & ...
    indexes(:, 2) >= spaceRanges(i, 3) & ...
    indexes(:, 2) <= spaceRanges(i, 4);
  pooled(:, i) = poolFn(responses(rowSel, :))';
  switch(poolType)
    case 'hist'
      normalizingFactor = sum(pooled(:, i));
      if normalizingFactor > eps
        pooled(:, i) = (pooled(:, i) * weights(i)) ./ normalizingFactor;
      end
  end
end
pooled = reshape(pooled, 1, []);
end

function [ranges, weights] = getSpatialRangesForPooling(rows, cols, ...
  numPoolLevels)
numRanges = sum((2.^(0 : numPoolLevels - 1)).^2);
ranges = zeros(numRanges, 4);
weights = zeros(numRanges, 1);
rangesInd = 0;
for i = 1 : numPoolLevels
  rowRanges = floor(1 : (rows - 1) / 2^(i-1) : rows);
  colRanges = floor(1 : (cols - 1) / 2^(i-1) : cols);
  levelWeight = 1 / 2^(numPoolLevels - i + 1);
  if i == 1
    levelWeight = 1 / 2^(numPoolLevels - 1);
  end
  for j = 1 : length(rowRanges) - 1
    if j == 1
      rowStart = 1;
    else
      rowStart = rowRanges(j) + 1;
    end
    rowEnd = rowRanges(j + 1);
    for k = 1 : length(colRanges) - 1
      if k == 1
        colStart = 1;
      else
        colStart = colRanges(k) + 1;
      end
      colEnd = colRanges(k + 1);
      rangesInd = rangesInd + 1;
      ranges(rangesInd, :) = [rowStart rowEnd colStart colEnd];
      weights(rangesInd) = levelWeight;
    end
  end
end
end
