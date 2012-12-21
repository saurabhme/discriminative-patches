function scales = getLevelScales(numLevels, interval)
% Author: saurabh.me@gmail.com (Saurabh Singh).
sc = 2^(1 / interval);
scales = sc.^(0 : numLevels - 1);
end
