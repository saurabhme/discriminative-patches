function [selected, order] = cleanUpOverlapping(patches, scores, ...
  correspImgs, maxOverlap)
% Author: saurabh.me@gmail.com (Saurabh Singh).
[unused, inds] = sort(scores, 'descend');
selected = false(size(patches));
sortedPats = patches(inds);
bbx = getBoxesForPedro(sortedPats);
[uniqueImIds, m, n] = unique(correspImgs, 'first');
[vals, unids] = sort(m);
uniqueImIds = uniqueImIds(unids);
for i = 1 : length(uniqueImIds)
  imId = uniqueImIds(i);
  sameImgPatInds = find(correspImgs(inds) == imId);
  bx = bbx(sameImgPatInds,  :);
  overlaps = computeOverlap(bx, bx, 'pascal');
  nEl = numel(overlaps);
  interval = size(overlaps, 1) + 1;
  overlaps(1:interval:nEl) = 0;
  aboveThresh = overlaps > maxOverlap;
  [p, q] = max(overlaps, [], 2);
  isActive = true(size(p));
  for j = 1 : length(q)
    if ~isActive(j)
      continue;
    end
    selected(inds(sameImgPatInds(j))) = true;
    isActive(aboveThresh(:, j)) = false;
  end
end
[unused, order] = sort(scores(selected), 'descend');
selectedInds = find(selected);
order = selectedInds(order);
end
