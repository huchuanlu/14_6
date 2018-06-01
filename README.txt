The code is a preliminary version of the Multiple Kernel Boosting (MKB) tracker, which is first proposed in

Fan Yang, Huchuan Lu, Yen-Wei Chen, "Human Tracking by Multiple Kernel Boosting with Locality Affinity Constraints", 10th Asian Conference on Computer Vision (ACCV2010), vol. 4, pp. 39-50, 2010

The code is implemented by MATLAB with libsvm library and VLFeat library to extract HoG and SIFT features.

Run "tracker" to see how the tracker works. A sample dataset "tom1" is included in data folder.

Change parameters in the "trackparam" file to run other sequences.

Tracking results (images) will be saved in the \result directory with the tracking data as a mat file.  
