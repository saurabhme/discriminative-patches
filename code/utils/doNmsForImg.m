function picks = doNmsForImg(data, decisionScore, overlap)
% Do NMS for patches from a single image.

boxes = getBoxesForPedro(data, decisionScore);
picks = myNms(boxes, overlap);
end
