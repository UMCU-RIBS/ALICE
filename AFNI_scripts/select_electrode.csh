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

set cnt = 1
while ($cnt < $#argv)
 if (("$argv[$cnt]" == "-help") || ("$argv[$cnt]" == "-h") || ("$argv[$cnt]" == "--help")) then
    goto HELP
 endif

 if ("$argv[$cnt]" == "-electrode_i") then
            @ cnt ++
            set electrode_i = "$argv[$cnt]"
 else if ("$argv[$cnt]" == "-afni_sphere") then
            @ cnt ++
            set afni_sphere = "$argv[$cnt]"
 endif

 @ cnt ++
end

     # get the xyz coordinate in the volume
     # really only need this for the afni_sphere case
     # could be a tiny bit faster without this check most of the time
	  plugout_drive  $NPB                                         \
		  -com 'GET_DICOM_XYZ'                               \
		  -quit

	  # have suma report its current surface label - which cluster
	  DriveSuma $NPB -com "get_label"
	  set clustindex = `tail -2 $sumasurf|head -1` #v2.0. old version=-1 $sumasurf`
	  set xyzstr = `tail -1 $surfcoords`
	  # output from plugout is of form "RAI xyz: x y z"
	  # we can use just part of that
	  # if we are using the exact location for a sphere, let's mark that here

echo $electrode_i $clustindex $xyzstr[3-5] $afni_sphere >> $surfcoords_i

set clustval = `echo $clustindex | sed  's/roi//' |sed 's/(I,T,B)R=//'|\
          sed 's/(I,T,B)numeric=//'`

      # make 1/3 bright and add it to the list
      # this doesn't change the data in any way here
      # much smaller memory leak, 1000 iterations less that 256MB total for suma
      set roistr = `ccalc -form "roi%3.3d" $clustval`

      # commented lines only useful for checking if roi's have already been recolored
      # for coloring with white, gray or other constant color, skip these lines
      # use grep to be sure this cluster number is legit and to check status
      # don't put any commands beween the grep and status check
#      grep $roistr temproilist.txt
      # If first time cluster has been identified, recolor to white
      #  could make else condition, rebrighten electrode
#      if ($status) then

          set roirgb = `grep $roistr tempcmap.niml.cmap`
          set rgbout =  ("1.0" "1.0" "1.0")         #old version: `1deval -a "1D:$roirgb[1-3]" -expr a/3`
          # change niml file (redirect, then rename rather than in place with "sed -i ..." because of MacOS oddities)
          cat tempcmap.niml.cmap | sed "s/$roirgb/$rgbout 1 $roirgb[5] ${roistr}/" > tempcmap2.niml.cmap
          mv tempcmap2.niml.cmap tempcmap.niml.cmap
#          DriveSuma $NPB -com surf_cont -switch_dset temp_marked_clusters.1D.dset 
          DriveSuma $NPB -com surf_cont -load_cmap tempcmap.niml.cmap
#          echo $roistr >> temproilist.txt
#      endif

