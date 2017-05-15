#!/bin/tcsh -f

set cnt = 1

# set default values for volume and neighbors in clustering
set r = 10
set is = 1

if ($#argv == 0) then
   goto HELP
endif


 if ("$argv[$cnt]" == "-CT_path") then
            @ cnt ++
            set ct = "$argv[$cnt]"
 endif
 
 @ cnt ++
 if ("$argv[$cnt]" == "-radius") then
            @ cnt ++
            set r = "$argv[$cnt]"
 endif

 @ cnt ++
 if ("$argv[$cnt]" == "-interelectrode_space") then
            @ cnt ++
            set is = "$argv[$cnt]"
 endif

 @ cnt ++
 if ("$argv[$cnt]" == "-clip_value") then
            @ cnt ++
            set cv = "$argv[$cnt]"
 endif  

# do what we came for - clustering
3dclust -savemask 3dclusters_r${r}_is${is}_thr${cv}.nii -overwrite -1Dformat -1clip $cv $is $r $ct  > clst.1D 

# make sure the clusters all show up in afni with distinct colors
3drefit -cmap INT_CMAP 3dclusters_r${r}_is${is}_thr${cv}.nii 

# now resample the clusters, erode, dilate and cluster again
# this helps separate the clusters that overlap
3dresample -prefix temp_clusts_rs0.5 -overwrite -rmode NN -dxyz 0.5 0.5 0.5 -inset 3dclusters_r${r}_is${is}_thr${cv}.nii
3dmask_tool -dilate_inputs -1 +2 -prefix temp_clusts_rs0.5_de2 -overwrite -inputs temp_clusts_rs0.5+orig
3dclust -savemask 3dclusters_r${r}_is${is}_thr${cv}.nii -overwrite -1Dformat -1clip $cv $is $r temp_clusts_rs0.5_de2+orig > clst.1D 

3drefit -cmap INT_CMAP 3dclusters_r${r}_is${is}_thr${cv}.nii 

rm temp_clusts*.HEAD temp_clusts*.BRIK*

IsoSurface -isorois+dsets -mergerois+dset -autocrop -o_gii 3dclusters_r${r}_is${is}_thr${cv}.gii -input 3dclusters_r${r}_is${is}_thr${cv}.nii  


echo "Clustered dataset saved as 3dclusters_r${r}_is${is}_thr${cv}.nii"
echo "Table of coordinates saved as clst.1D"
exit

HELP:
   echo ""
   echo "Usage: `basename $0` <-CT_path BASE> <-clip_value CLIP_VALUE> <-radius RADIUS> <-interelectrode_space INTERELECTRODE_SPACE> [-no_cp] "
   echo "                     "
   echo ""
   echo "   Run inside /data/CT/3dclustering"
   echo "   tcsh @3dclustering -CT_path path_to_CT  -radius cluster_size_radius -interelectrode_space distance_between_cluster -clip_value max_CT_intensity_value "
   echo "   Suggested values: radius (really volume in ul) = 3 to 5, interelectrode_space = 0 to 1 "
   echo ""
   echo "example use:"
   echo "tcsh -x @3dclustering -CT_path clusts_rs0.5_de2+orig. -radius 10 -interelectrode_space 1 -clip_value 1"
