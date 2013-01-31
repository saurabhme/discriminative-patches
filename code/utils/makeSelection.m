function [WP, WNP] = makeSelection(allImages, categories)
% Divide the given set into two parts. With and without the category.
%
% Author: saurabh.me@gmail.com (Saurabh Singh).

WP = zeros(size(allImages));
WNP = zeros(size(allImages));
wpInd = 0;
wnpInd = 0;
for i = 1 : length(allImages)
  objNames = {allImages(i).annotation.object.name};
  if sum(ismember(categories, objNames)) > 0
    wpInd = wpInd + 1;
    WP(wpInd) = i;
  else
    wnpInd = wnpInd + 1;
    WNP(wnpInd) = i;
  end
end

WP = WP(1:wpInd);
WNP = WNP(1:wnpInd);
end
