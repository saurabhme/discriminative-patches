classdef VisualEntityDetectors < handle
  % Class representing a set of detectors.
  %
  % Author: saurabh.me@gmail.com (Saurabh Singh).
  properties
    firstLevModels;
    secondLevModels;
    firstLevMmhtWts;
    secondLevMmhtWts;
    mixModel;
    params;
    logisParams;
    voteWeights;
    modelWeightFn;
  end
  methods
    function obj = VisualEntityDetectors(models, params)
      obj.firstLevModels = constructCompositeDetectors(models);
      obj.firstLevMmhtWts = [];
      obj.params = params;
      obj.secondLevModels = {};
      obj.secondLevMmhtWts = {};
      obj.mixModel = [];
      obj.logisParams = [];
      obj.voteWeights = cell(size(models));
      obj.modelWeightFn = [];
    end
    
    function setMixModel(obj, mixModel)
      obj.mixModel = mixModel;
    end
    
    function setSuccessRatio(obj, successRatio)
      obj.successRatio = successRatio;
    end
    
    function setSecondLevModels(obj, models)
      obj.secondLevModels = models;
    end
    
    function setLogisParams(obj, params)
      obj.logisParams = params;
    end
    
    function setVoteWeights(obj, voteWeights)
      obj.voteWeights = voteWeights;
    end
    
    function setModelWeightFn(obj, fn)
      obj.modelWeightFn = fn;
    end
    
    function num = getNumDetectors(obj)
      if iscell(obj.firstLevModels)
        num = length(obj.firstLevModels);
      else
        num = size(obj.firstLevModels.w, 1);
      end
    end
    
    function results = detectPresenceInImg(obj, sample, ...
        imgHome, removeFeatures, detectionParams)
      detectors.firstLevel = obj.firstLevModels;
      detectors.secondLevel = obj.secondLevModels;
      results = detectPresenceUsingEntDet(sample, ...
        detectors, obj.params, imgHome, removeFeatures, detectionParams);
    end
    
    function voteSpace = doVotingForResult(obj, ...
        detResult, clusts, space)
      % Generates voting distribution for the given image.
      detectionWeights = getWeightsForDetections(obj.modelWeightFn, ...
        detResult);
      voteSpace = doVotingForImage(obj.mixModel, ...
        detResult.firstLevel.detections, ...
        clusts, space, obj.firstLevMmhtWts, obj.logisParams, ...
        obj.voteWeights, detectionWeights, 0);
      
      if ~isempty(obj.secondLevModels)
        error('Second level voting not supported.');
      end
    end
    
    function locSpace = getLocationSpaceForImage(obj, imgData)
      % Generates the location space for the image.
      locSpace = getLocationSpaceForImg(obj.params, imgData);
    end
    
    function response = getResponseForPoints(obj, results, points, space)      
      response = zeros(size(points, 1), length(obj.firstLevModels));
      detections = results.detections;
      for j = 1 : length(detections)
        metadata = detections(j).metadata;
        % Weights based on detection scores, assuming lowest score of -1.
        if isempty(obj.logisParams)
          logisPara = [];
        else
          logisPara = obj.logisParams{j};
        end
        if ~isempty(metadata)
          weights = getPatchWeights(logisPara, ...
            detections(j).decision);
        end
        
        for k = 1 : length(metadata)
          [cx cy] = getPatchCenter(metadata(k));
          cVertExt = getPatchVerticalExtent(metadata(k));
          patchVotes = obj.mixModel{j};
          patchVotes(:, 1) = (patchVotes(:, 1) * cVertExt) + cx;
          patchVotes(:, 2) = (patchVotes(:, 2) * cVertExt) + cy;
          patchVotes(:, 3) = patchVotes(:, 3) * cVertExt;
          gmm = getMixtureForVotes(patchVotes, space);
  
          for m = 1 : size(points, 1)
            response(m, j) = response(m, j) + ...
              pdf(gmm, points(m, :)) * weights(k);
          end
        end
      end
    end
    
  end
end
