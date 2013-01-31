classdef PresenceDetectionResults < handle
  % Class representing detection results.
  %
  % Author: saurabh.me@gmail.com (Saurabh Singh).
  properties
    results;
    resultsDir;
  end
  methods
    function obj = PresenceDetectionResults(resultsDir)
      obj.resultsDir = resultsDir;
      load([resultsDir 'all_detections.mat'], 'allDetections');
      obj.results = allDetections;
    end
    
    function result = getPosResult(obj, id)
      fileName = sprintf('%s/pos/%d_res.mat', obj.resultsDir, id);
      result = loadAndCheck(fileName, 'detResults');
    end
    
    function result = getNegResult(obj, id)
      fileName = sprintf('%s/neg/%d_res.mat', obj.resultsDir, id);
      result = loadAndCheck(fileName, 'detResults');
    end

    function numClusters = getNumClusters(obj)
      numClusters = length(obj.results.selectedClusters);
    end

    function numPos = getNumPosResults(obj)
      numPos = length(obj.results.allPos);
    end

    function numNeg = getNumNegResults(obj)
      numNeg = length(obj.results.allNeg);
    end
    
    function posIds = getPosImgIds(obj)
      posIds = obj.results.allPos;
    end
    
    function negIds = getNegImgIds(obj)
      negIds = obj.results.allNeg;
    end
  end
end
