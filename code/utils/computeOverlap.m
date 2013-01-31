function overlaps = computeOverlap(boxes1, boxes2, mode)
% Computes the overlap between two sets of boxes
%
% mode: Three possible modes
%   pascal: intersection / union
%   pedro : intersection / first box area
%   wrtmin: intersection / min of two areas
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

switch mode
  case 'pascal'
    overlaps = computePascalOverlap(boxes1, boxes2);
  case 'pedro'
    overlaps = computePedroOverlap(boxes1, boxes2);
  case 'wrtmin'
    overlaps = computeWrtMinOverlap(boxes1, boxes2);
  otherwise
    error('Unrecognized mode');
end
end

function overlaps = computePascalOverlap(boxes1, boxes2)
overlaps = zeros(size(boxes1, 1), size(boxes2, 1));
if isempty(boxes1)
  overlaps = [];
else
  x11 = boxes1(:,1);
  y11 = boxes1(:,2);
  x12 = boxes1(:,3);
  y12 = boxes1(:,4);
  areab1 = (x12-x11+1) .* (y12-y11+1);
  x21 = boxes2(:,1);
  y21 = boxes2(:,2);
  x22 = boxes2(:,3);
  y22 = boxes2(:,4);
  areab2 = (x22-x21+1) .* (y22-y21+1);

  for i = 1 : size(boxes1, 1)
    for j = 1 : size(boxes2, 1)
      xx1 = max(x11(i), x21(j));
      yy1 = max(y11(i), y21(j));
      xx2 = min(x12(i), x22(j));
      yy2 = min(y12(i), y22(j));
      w = xx2-xx1+1;
      h = yy2-yy1+1;
      if w > 0 && h > 0
        overlaps(i, j) = w * h / (areab1(i) + areab2(j) - w * h);
      end
    end
  end  
end
end

function overlaps = computePedroOverlap(boxes1, boxes2)
overlaps = zeros(size(boxes1, 1), size(boxes2, 1));
if isempty(boxes1)
  overlaps = [];
else
  x1 = boxes1(:,1);
  y1 = boxes1(:,2);
  x2 = boxes1(:,3);
  y2 = boxes1(:,4);
  area = (x2-x1+1) .* (y2-y1+1);

  for i = 1 : size(boxes1, 1)
    for j = 1 : size(boxes2, 1)
      x21 = boxes2(j,1);
      y21 = boxes2(j,2);
      x22 = boxes2(j,3);
      y22 = boxes2(j,4);
      
      xx1 = max(x1(i), x21);
      yy1 = max(y1(i), y21);
      xx2 = min(x2(i), x22);
      yy2 = min(y2(i), y22);
      w = xx2-xx1+1;
      h = yy2-yy1+1;
      if w > 0 && h > 0
        overlaps(i, j) = w * h / area(i);
      end
    end
  end  
end
end

function overlaps = computeWrtMinOverlap(boxes1, boxes2)
% Overlap is intersection/min-area
overlaps = zeros(size(boxes1, 1), size(boxes2, 1));
if isempty(boxes1)
  overlaps = [];
else
  x11 = boxes1(:,1);
  y11 = boxes1(:,2);
  x12 = boxes1(:,3);
  y12 = boxes1(:,4);
  areab1 = (x12-x11+1) .* (y12-y11+1);
  x21 = boxes2(:,1);
  y21 = boxes2(:,2);
  x22 = boxes2(:,3);
  y22 = boxes2(:,4);
  areab2 = (x22-x21+1) .* (y22-y21+1);

  for i = 1 : size(boxes1, 1)
    for j = 1 : size(boxes2, 1)
      xx1 = max(x11(i), x21(j));
      yy1 = max(y11(i), y21(j));
      xx2 = min(x12(i), x22(j));
      yy2 = min(y12(i), y22(j));
      w = xx2-xx1+1;
      h = yy2-yy1+1;
      if w > 0 && h > 0
        overlaps(i, j) = w * h / min(areab1(i), areab2(j));
      end
    end
  end  
end
end
