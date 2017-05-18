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
suma $NPB -i $clust_surf -sv $ct >& ./sumaout.log  &

# We need a way to click on the electrodes in the clinical order and 
# find the correspondent center of mass coordinates in clst.1D file. 
# The optimal output would be a txt file with four columns, namely:
# Number_of_the_cluster_in_clinical_order coord_x coord_y coord_z

plugout_drive  $NPB                                               \
               -com 'SWITCH_SESSION A.afni'                       \
               -com 'OPEN_WINDOW A.axialimage geom=600x600+416+44 \
                     ifrac=0.8 opacity=9'                         \
               -com 'OPEN_WINDOW A.sagittalimage geom=+45+430     \
                     ifrac=0.8 opacity=9'                         \
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

echo $NPB > ecognpb.txt