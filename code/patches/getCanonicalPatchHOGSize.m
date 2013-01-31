function [prSize, pcSize, pzSize] = getCanonicalPatchHOGSize(params)
% Canonical size for patch HOGs.
% Author: saurabh.me@gmail.com (Saurabh Singh).
prSize = round(params.patchCanonicalSize(1) / params.sBins) - 2;
pcSize = round(params.patchCanonicalSize(2) / params.sBins) - 2;
pzSize = 31;
end
