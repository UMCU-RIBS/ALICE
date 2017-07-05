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
      grep $roistr temproilist.txt
      # If first time cluster has been identified, recolor to 1/3 brightness
      #  could make else condition, rebrighten electrode
      if ($status) then
          set roirgb = `grep $roistr tempcmap.niml.cmap`
          set rgbout =  ("1.0" "1.0" "1.0")         #old version: `1deval -a "1D:$roirgb[1-3]" -expr a/3`
          sed -i "s/.*${roistr}.*/$rgbout 1 $clustval ${roistr}/" tempcmap.niml.cmap
          DriveSuma $NPB -com surf_cont -switch_dset temp_marked_clusters.1D.dset 
          DriveSuma $NPB -com surf_cont -load_cmap tempcmap.niml.cmap
          echo $roistr >> temproilist.txt
      endif

