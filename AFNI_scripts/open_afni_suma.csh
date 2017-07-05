#!/bin/tcsh

# script to write out electrode positions

# assumes one has previously run this previous script and created the roi surfaces for all the electrodes
# with these commands
# tcsh @3dclustering -CT_path CT.nii -radius 4 -interelectrode_space 3 -clip_value 2999
# IsoSurface -isorois+dsets -mergerois+dset -autocrop -o_gii 3dclusters.gii -input 3dclusters_r?_is?.nii

set PIF = DriveAfniElectrodes    #A string identifying programs launched by this script

                           #Get a free line and tag programs from this script
set NPB = "-npb `afni -available_npb_quiet` -pif $PIF -echo_edu" 
set surfcoords = "surf_xyz.1D"  # record the electrode positions in a text file - this one gets the position at the surface
#set surfcoords_i = "surf_ixyz.1D"  # record the electrode positions in a text file - this one gets the position at surface with index
set sumasurf = lastsurfout.txt 
set ct = "CT+orig"
set clust_surf = "3dclusters.gii"
set clustset = ''

@Quiet_Talkers -pif $PIF   #Quiet previously launched programs

set cnt = 1
while ($cnt < $#argv)
 if (("$argv[$cnt]" == "-help") || ("$argv[$cnt]" == "-h") || ("$argv[$cnt]" == "--help")) then
    goto HELP
 endif

 if ("$argv[$cnt]" == "-CT_path") then
            @ cnt ++
            set ct = "$argv[$cnt]"
 else if ("$argv[$cnt]" == "-clust_set") then
            @ cnt ++
            set clustset = "$argv[$cnt]"
 else if ("$argv[$cnt]" == "-clust_surf") then
            @ cnt ++
            set clust_surf = "$argv[$cnt]"
 else goto HELP
 endif

 @ cnt ++
end


####### START new code for el cluster shading v2.0 (MPBranco 300617)###########################

set clust_surf_base = `basename -s .gii $clust_surf`
set clust_niml_set = ${clust_surf_base}.niml.dset


rm lastsurfout.txt temproilist.txt

# make a temporary copy of the coloring dataset to recolor as we go
set nlabels = `3dinfo -labeltable $clust_niml_set | grep ni_dimen | awk -F\" '{print $2}'`
@ nlabels ++
# copy just the labels from the niml dset
3dinfo -labeltable $clust_niml_set | tail -$nlabels | grep -v VALUE_LABEL_DTABLE \
   | tr -d \" > temp_labels.txt
MakeColorMap -std ROI_i256 |tail -256 > roi256.1D
# now create a proper SUMA compatible colormap by combining the two files
#  index label RGBA
@ nlabels --
rm tempcmap.txt
foreach li (`count -digits 1 1 $nlabels`)
   set ind_label = `sed "${li}q;d" temp_labels.txt`
   set rgb = `sed "${li}q;d" roi256.1D`
   # put them all together (RGB are fractional values, Alpha=1)
   # index label R G B A
   # 1 electrode_1 0.1 0.4 0.02 1
   echo $ind_label $rgb 1 >> tempcmap.txt
end

# create a non-colored copy of the dataset - just nodes and cluster indices
ConvertDset -overwrite -input $clust_niml_set -dset_labels 'R' -o temp_marked_clusters.1D
# make color map used below and updated too
MakeColorMap -usercolutfile tempcmap.txt \
      -suma_cmap tempcmap -overwrite >& /dev/null

#      -sdset temp_marked_clusters.niml.dset \

####### END of new code for el cluster shading v2.0###########################


# if cluster dataset was not specified, try to find one
if ($clustset == '') then
  set clustsets = (3dclusters_r?_is?.nii)
  set clustset = $clustsets[0]
endif


afni $NPB -niml -yesplugouts -dset $ct $clustset  >& ./afniout.log &

sleep 1
# delete copy of previous surface coordinates and region if it exists
if -e $surfcoords then
   mv $surfcoords $surfcoords.old
#  mv $surfcoords_i $surfcoords_i.old
endif

# coordinates sent to text file by AFNI with plugout xyz
setenv AFNI_OUTPLUG $surfcoords
# text output from suma driven command with cluster index with surface name
setenv SUMA_OUTPLUG  $sumasurf
suma $NPB -DSUMA_AllowDsetReplacement=YES -i $clust_surf -sv $ct >& ./sumaout.log  & #####edited for v2.0

DriveSuma $NPB -com surf_cont -view_object_cont y

# We need a way to click on the electrodes in the clinical order and 
# find the correspondent center of mass coordinates in clst.1D file. 
# The optimal output would be a txt file with four columns, namely:
# Number_of_the_cluster_in_clinical_order coord_x coord_y coord_z

plugout_drive  $NPB                                               \
               -com 'SWITCH_SESSION A.afni'                       \
               -com 'OPEN_WINDOW A.axialimage geom=600x600+416+44 \
                     ifrac=0.8 opacity=5'                         \
               -com 'OPEN_WINDOW A.sagittalimage geom=+45+430     \
                     ifrac=0.8 opacity=5'                         \
               -com "SWITCH_UNDERLAY $ct"                         \
               -com "SWITCH_OVERLAY $clustset"                    \
               -com 'SEE_OVERLAY +'                               \
               -com "SET_OUTPLUG $surfcoords"                     \
               -quit

# suma sends surface object output to a particular file
# and start talking to afni
DriveSuma $NPB \
          -com  viewer_cont -key t

#        set l = `prompt_user -pause 


####### START new code for el cluster shading v2.0 (MPBranco 300617)###########################
sleep 2
# update coloring to ROI_i256 instead of IsoSurface coloring (which might be the same anyway)
#  and use copy of cluster niml dset for colors that gets updated below
      DriveSuma $NPB -com surf_cont -load_dset temp_marked_clusters.1D.dset \
          -surf_label $clust_surf
      DriveSuma $NPB -com surf_cont -switch_dset temp_marked_clusters.1D.dset 
      DriveSuma $NPB -com surf_cont -load_cmap tempcmap.niml.cmap
      DriveSuma $NPB -com surf_cont -switch_cmap tempcmap -Dim 0.6 \
                     -switch_cmode Dir -1_only Y
####### END new code for el cluster shading v2.0 (MPBranco 300617)###########################


echo $NPB > ecognpb.txt