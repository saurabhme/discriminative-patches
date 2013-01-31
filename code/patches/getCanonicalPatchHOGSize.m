function [prSize, pcSize, pzSize] = getCanonicalPatchHOGSize(params)
% Canonical size for patch HOGs.
prSize = round(params.patchCanonicalSize(1) / params.sBins) - 2;
pcSize = round(params.patchCanonicalSize(2) / params.sBins) - 2;
pzSize = 31;
end
