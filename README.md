# Multi-Channel-Mosaicking
Public repository for multi-channel mosaicking algorithm, as described in JBO publication.
Written in Matlab R2019a (Mathworks). 

Included in this repository is an implementation of graph-cut based stitching, as done by Kose et al., which greatly increases the quality of mosaics. This implementation is based on a Matlab wrapper by Shai Bagon:
https://github.com/shaibagon/GCMex

The graph-cut based stitching is under patent protection. In order to use the code and algorithm for research purposes, please include the following citations in any publications.

**Novel mosaicking algorithm:**

[a] Multi-channel correlation improves the noise tolerance of real-time hyperspectral micro-image mosaicking. Ryan T. Lang et al., Journal of Biomedical Optics. **Submitted and pending review.**

**Graph-cut based stitching implementation:**

[b] Automated video-mosaicking approach for confocal microscopic imaging in vivo: an approach to address challenges in imaging living tissue and extend field of view. Kivanc Kose et al., Scientific Reports, vol. 7, no. 10759, September 2017

[c] Matlab Wrapper for Graph Cut. Shai Bagon. in https://github.com/shaibagon/GCMex, December 2006.

**Graph-cut minimization theory and methods:**

[d] Efficient Approximate Energy Minimization via Graph Cuts Yuri Boykov, Olga Veksler, Ramin Zabih, IEEE transactions on PAMI, vol. 20, no. 12, p. 1222-1239, November 2001.

[e] What Energy Functions can be Minimized via Graph Cuts? Vladimir Kolmogorov and Ramin Zabih. IEEE Transactions on Pattern Analysis and Machine Intelligence (PAMI), vol. 26, no. 2, February 2004, pp. 147-159.

[f] An Experimental Comparison of Min-Cut/Max-Flow Algorithms for Energy Minimization in Vision. Yuri Boykov and Vladimir Kolmogorov. In IEEE Transactions on Pattern Analysis and Machine Intelligence (PAMI), vol. 26, no. 9, September 2004, pp. 1124-1137.


### 1) Install

Clone the repository and run compile_gc.m (in GCmex2.0 directory) to build the MEX libraries and enable graph-cut based stitching.

### 2) Usage and File Descriptions

**Files**

Test_Mosaic.m - Test "main" program to show mosaicking capabilities, accesses data from "Test_Data" directory

mchannel_nxcorr_reg_GPU.m - Function for cross-correlation based m-channel mosaicking alignment/registration

Frame_Blend.m & stitchImages.m - Functions for implementing Kose's graph-cut based stitching

**Directories**

GCmex2.0 - Matlab wrapper by Shai Bagon that implements graph-cut minimization

Test_Data - Contains some test images for showing mosaicking capabilities. Each sub-folder in this directory will be treated as a data channel, and within each sub-directory should be an equal number of sequential images labelled "frame#.tif", where the # is replaced by the image number tag starting at 0. The test data only mosaics 2 images - there is no theoretical limit to the number of possible sequential images, it is constrained by system memory.
