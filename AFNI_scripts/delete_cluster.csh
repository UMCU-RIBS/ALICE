#!/bin/tcsh

set NPB = `cat ecognpb.txt`
if ("$NPB" == "") then
   echo ecognpb.txt is not in current directory!
   echo assuming 0 here instead
   set PIF = DriveAfniElectrodes
   set NPB = "-npb 0 -pif $PIF -echo_edu"
endif

setenv SUMA_DriveSumaMaxWait 10
setenv AFNI_ENVIRON_WARNINGS NO
setenv SUMA_DriveSumaQuiet YES

set surfcoords = "surf_xyz.1D"  # record the electrode positions in a text file - this one gets the position at the surface
set surfcoords_i = "surf_ixyz.1D"  # record the electrode positions in a text file - this one gets the position at surface with index
set sumasurf = lastsurfout.txt 

# get the xyz coordinate in the volume
# really only need this for the afni_sphere case
# could be a tiny bit faster without this check most of the time
plugout_drive  $NPB                                    \
	-com 'GET_DICOM_XYZ'                               \
	-quit

# have suma report its current surface label - which cluster
DriveSuma $NPB -com "get_label"
set clustindex = `tail -2 $sumasurf|head -1` #v2.0. old version=-1 $sumasurf`
set xyzstr = `tail -1 $surfcoords`

set clustval = `echo $clustindex | sed  's/roi//' |sed 's/(I,T,B)R=//'|\
          sed 's/(I,T,B)numeric=//'`

# make 1/3 bright and add it to the list
# this doesn't change the data in any way here
# much smaller memory leak, 1000 iterations less that 256MB total for suma
set roistr = `ccalc -form "roi%3.3d" $clustval`

# If first time cluster has been identified, recolor to white
set roirgb = `grep $roistr tempcmap.niml.cmap`
set rgbout =  ("0.0" "0.0" "0.0" "0") 
       
# change niml file (redirect, then rename rather than in place with "sed -i ..." because of MacOS oddities)
cat tempcmap.niml.cmap | sed "s/$roirgb/$rgbout $roirgb[5] ${roistr}/" > tempcmap2.niml.cmap
mv tempcmap2.niml.cmap tempcmap.niml.cmap
DriveSuma $NPB -com surf_cont -load_cmap tempcmap.niml.cmap


