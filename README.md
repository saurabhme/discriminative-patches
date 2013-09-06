Discriminative Patches
======================

This repository contains code for the following paper

Saurabh Singh, Abhinav Gupta and Alexei A. Efros. *"Unsupervised Discovery of
Mid-Level Discriminative Patches."* In European Conference on Computer Vision
(2012). (arXiv:1205.3137) http://graphics.cs.cmu.edu/projects/discriminativePatches/

All Rights Reserved @ saurabh.me@gmail.com (Saurabh Singh).


Setup
=====

1. Git clone this repository (if you are reading this on git-hub).
2. Download the pre-trained models from the [project website](http://graphics.cs.cmu.edu/projects/discriminativePatches/) and un-compress the
file in the root directory of the repository, i.e. as a sibling to the 'code'
directory.
3. Modify the setmeup.m file to make USR.imgDir and USR.modelDir point to the
models directory.
4. cd to code/features directory and run 'mex features.cc' from the matlab prompt.
(This is assuming you have mex already setup).  

Basic Usage
===========

A script that demonstrates how to run pre-trained models is provided in the
'code/user' directory. Simply cd to 'code' directory in repository and run the
following commands on the matlab prompt. 

    >> setmeup
    >> detectDiscPats

Training The Patches
====================

Start by taking a look at
[trainDiscPats.m](https://github.com/saurabhme/discriminative-patches/blob/master/code/user/trainDiscPats.m).
This script runs a training job for the pascal sub-dataset used in paper. Pay
attention to the comments related to run time. To run on your own dataset create
a script similar to getPascalData() that generates the required metadata.


Acknowledgements
================
Some of the code pieces are borrowed from other sources. Following should be an
exhaustive list of those. It is recommended to get the latest libraries from
these sources to remain upto-date with the improvements.

* The features.cc file has been borrowed from the following code-base and
corresponds to the version 4 release.
[_Discriminatively trained deformable part models_](http://people.cs.uchicago.edu/~rbg/latent/)

