
%   Copyright 2018 Wenbin Yang <bysin7@gmail.com>
%   This file is part of A-BLITZ-ER[1] (Analyzer of Behavioral Learning 
%   In The ZEbrafish Result.) i.e. the analyzer of BLITZ[2]. 
%
%   BLITZ (Behavioral Learning In The Zebrafish) is a software that 
%   allows researchers to train larval zebrafish to associate 
%   visual pattern with electric shock in a fully automated way, which 
%   is adapted from MindControl.[3]
%   [1]: https://github.com/Wenlab/ABLITZER
%   [2]: https://github.com/Wenlab/BLITZ
%   [3]: https://github.com/samuellab/mindcontrol
%
%
%   Filename: ABLITZER.m
%   Abstract: 
%       The main class is defined in this file, it is ...
%       A class with data structure, stores the experimental data of the
%       entire data set about an experiment, including both categoried 
%       recorded data from yaml files and analysis results at statistical
%       level. It also provides some functions:
%       
%       1. Read in yaml file
%       2. Evaluate fish performance in the task from multiple perspectives
%       3. Visualize the quatitative statistical results in figures with
%          optional annotations
%
%   
%   
%   Current Version: 1.2
%   Author: Wenbin Yang <bysin7@gmail.com>
%   Modified on: May 6, 2018
% 
%   Orinigal Version: 1.0
%   Author: Wenbin Yang <bysin7@gmail.com>
%   Created on: May 3, 2018
% 



classdef ABLITZER < handle % Make the class a real class not a value class

    properties 
        FishStack; % Stack to store all fish data
        % Devide fishStack into different groups based on different tags
        % Put idx of data in 2nd column
        FishGroups = struct('Name',[],'Data',[],'Tag',[],'Note',[]);
        StatRes; % statistical results about the entire experiment
        
        Notes = ''; % additional notes about the dataset
        
        
    end
    
    methods
%         function obj = ABLITZER(numFish) % Constructor
%             tempExpData(obj.MaxFrames) = EXPDATA; 
%             obj.ExpData = tempExpData;
%             if (nargin == 0)
%                 resArray(obj.MaxFish) = RESDATA;
%                 obj.ResAll = resArray;
%             elseif (nargin == 1)
%                 resArray(numFish) = RESDATA;
%                 obj.ResAll = resArray;
%             else
%                 error('Wrong initialization for ABLITZER');
%             end
%         end

        
        % Reads in a yaml file produced by the BLITZ software
        % and exports a struct of BLITZ experiment data that is
        % easy to manipulate in MATLAB
        yaml2matlab(obj, endFrame, pathName, fileName);
        
        % load mat files which matches tags provided in the same directory
        importMatsByTags(obj, tags, pathName);
        
        % remove fish data whose data quality lower than threshold
        remove_invalid_data_pair(obj);
        
        % classify data into different groups by tags. (e.g. Experiment
        % Type): To Improve
        classifyFishByTags(obj, tags);
        
        % Find desired fish by providing tag-value pairs
        indices = findFishByTagValuePairs(obj,varargin);
        % convert old expData and resData to ABLITZER
        importOldData2Ablitzer(obj, pathName, fileName);
        
        % process all yaml files in one day
        processOneDayYamls(obj,pathName,expDate);
        
        
        quantifyMemoryStat(obj);
        % plot PIs of an entire group to see whether there's
        % any statistical significance. Normally, use this function
        % after "classifyFishByTags".
        % INPUT:
        %   idxExpGroup: the index of experiment group data in FishGroup struct
        %   idxCtrlGroup: the index of control group data in FishGroup struct
        plotPIsOfGroup(obj,idxExpGroup,idxCtrlGroup,metricType);
        
        % plot performance versus fish age
        plotOntogenyByPI(obj,metricType);
        
        % statistically plot non-CS area proportion versus time
        plotPIsInTest(obj);
        
           
    end
       
end

