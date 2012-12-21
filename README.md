discriminative-patches
======================

This repository contains code for the following paper

Saurabh Singh, Abhinav Gupta and Alexei A. Efros. "Unsupervised Discovery of
Mid-Level Discriminative Patches." In European Conference on Computer Vision
(2012). (arXiv:1205.3137) http://graphics.cs.cmu.edu/projects/discriminativePatches/

All Rights Reserved @ saurabh.me@gmail.com (Saurabh Singh).


Setup
=====

1. Git clone this repository (if you are reading this on git-hub).  
2. Download the pre-trained models from the project website and un-compress the
file in the root directory of the repository, i.e. as a sibling to the 'code'
directory. Link to project website:
http://graphics.cs.cmu.edu/projects/discriminativePatches/  
3. Modify the setmeup.m file to make USR.imgDir and USR.modelDir point to the
models directory.  
4. cd to code/features directory and run 'mex features.cc' from the matlab prompt.
(This is assuming you have mex already setup).  

Basic Usage
===========

A script that demonstrates how to run pre-trained models is provided in the
'user' directory. Simply cd to 'code' directory in repository. 

    >> setmeup
    >> detectDiscPats

Acknowledgements
================
Some of the code pieces are borrowed from other sources. Following should be an
exhaustive list of those. It is recommended to get the latest libraries from
these sources to remain upto-date with the improvements.

* The features.cc file has been borrowed from the following code-base and
corresponds to the version 4 release.
Discriminatively trained deformable part models
http://people.cs.uchicago.edu/~rbg/latent/

