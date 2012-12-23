function picks = doNmsForImg(data, decisionScore, overlap)
% Do NMS for patches from a single image.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

boxes = getBoxesForPedro(data, decisionScore);
picks = myNms(boxes, overlap);
end
