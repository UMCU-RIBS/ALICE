#!/bin/tcsh

set NPB = `cat ecognpb.txt`
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


	  plugout_drive  $NPB                                         \
		  -com 'GET_DICOM_XYZ'                               \
		  -quit

	  # have suma report its current surface label - which cluster
	  DriveSuma $NPB -com "get_label"
	  set clustindex = `tail -1 $sumasurf`
	  set xyzstr = `tail -1 $surfcoords`
	  # output from plugout is of form "RAI xyz: x y z"
	  # we can use just part of that
	  # if we are using the exact location for a sphere, let's mark that here

echo $electrode_i $clustindex $xyzstr[3-5] $afni_sphere >> $surfcoords_i



