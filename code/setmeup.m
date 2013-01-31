%% Setup the environment.
% Author: saurabh.me@gmail.com (Saurabh Singh).

% Setup the paths.
USR.imgDir = '../models/';
USR.modelDir = '../models/';

% Add all the subdirectories to the path.
addpath(genpath(pwd));

%% Set paths and file names
% Add libsvm to path.
% http://www.csie.ntu.edu.tw/~cjlin/libsvm/
addpath(genpath('/home/saurabh/Work/cv-libs/libsvm-3.12/'));

% Add clustering code to path
% https://gforge.inria.fr/projects/yael
addpath(genpath('/home/saurabh/Work/cv-libs/yael_v204/'));

% Add other utilities to path.
% http://www.mathworks.com/matlabcentral/fileexchange/31532-pack-unpack-variables-to-from-structures-with-enhanced-functionality/content/html/v2struct.html
addpath(genpath('/home/saurabh/Work/cv-libs/v2struct/'));

% Add VOCdevkit to path.
% http://pascallin.ecs.soton.ac.uk/challenges/VOC/
addpath(genpath('/home/saurabh/Work/cv-libs/VOCdevkit/'));

%%

VOCinit;

%%

% Set up global variables used throughout the codes
% Processing directories
CONFIG.processingDir = '../outputs/';

CONFIG.projectDataDir = CONFIG.processingDir;
CONFIG.pascalDataDir = CONFIG.processingDir;
CONFIG.pascalImgHome = [fileparts(VOCopts.imgpath) '/'];