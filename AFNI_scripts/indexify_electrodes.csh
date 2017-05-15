#!/bin/tcsh
# usage:
# indexify_electrodes.csh coordlist.1D cluster_dset
#
setenv AFNI_1D_ZERO_TEXT YES
set surfcoords_i = $argv[1]
set clustset = $argv[2]

# make a smaller dataset that only has the non-zero voxels
#  for speed. 3dCM and 3dcalc steps below should go faster
#  make box a little bigger for isosurface to work correctly
3dAutobox -prefix temp_clusts.nii.gz -noclust -npad 2 -overwrite -input $clustset
set clustset = temp_clusts.nii.gz

# name of reordered electrodes
set eclustset = eclusts+orig
# name of spheres at electrode positions
set sclustset = sclusts+orig

# output centers of mass to 1D text file
set electrodeCM = electrode_CM.1D
# spheres of some radius will be put at each center of mass
set srad = 1.5
# look around xyz location to find a voxel value
#  at any particular xyz, might be off because of rounding
#  or surface node correspondence
set voxrad = `ccalc '0.5'`

set elabel = elabels.txt

# make unique list of electrodes first
#  we only want the last electrode reported
set electrodes_list = (`1dcat "${surfcoords_i}[0]" | uniq`)

# build two corresponding lists
# list of electrode indices
set elist = ()
# list of corresponding indices
set clist = ()
# list of required spheres
set alist = ()

echo "# x      y     z       electrode  " > $electrodeCM
echo "" > $elabel

# at each electrode position, need to update with correct
#  electrode index
foreach electrode ($electrodes_list)
   # get the last occurrence of the electrode in i x y z file
   #  look for the electrode i at beginning of line
   #  user may have selected the same electrode multiple times
   #  to correct a previous bad selection
   set xyz = ( `grep "^$electrode " $surfcoords_i| tail -1` )
   # now have suma given cluster index, so don't need to get value at xyz coordinate
   # get closest cluster value around the electrode xyz
   #   don't look far,slightly more than a voxel
   set clustxyzval = `3dmaskave -max -dball $xyz[3] $xyz[4] $xyz[5] $voxrad -quiet $clustset`
   set clustroi = $xyz[2]
   set clustval = `echo $clustroi | sed  's/roi//'`
   set diff = `ccalc -int "equals($clustval,$clustxyzval)"`
   if $diff == '1' then
      echo "Cluster number $clustval does not match value from volume $clustxyzval"
      echo "   Using $clustval as cluster index"
   endif
   if ($clustval != 0) then
      # if user had put 'A' then a sphere will be placed at the exact coordinate
      if ($#xyz == 6) then
         if (($xyz[6] == 'A') || ($xyz[6] == 'a')) then
            set cm = ( $xyz[3-5] )
            # set list to use coordinate directly and put sphere there instead of cluster
            set alist = ( $alist 1 )
         else
            set alist = ( $alist 0 )
         endif
      else
         set cm = `3dCM "${clustset}<$clustval>"`
         set alist = ( $alist 0 )
      endif
      echo  "$cm $electrode" >> $electrodeCM
      set elist = ( $elist $electrode )
      set clist = ( $clist $clustval )
      echo $electrode "Electrode_$electrode" >> $elabel
   else
      echo "No value found at electrode position - $electrode"
   endif
end

# put the list of required spheres in a single column
echo $alist > required_spheres.1D

# put spheres at each center of mass with electrode index value
set sbase = `@GetAfniPrefix $sclustset`

3dUndump -xyz -orient RAI -master $clustset -overwrite -datum byte \
   -srad $srad -prefix $sbase $electrodeCM
# "atlasize" the sclustset here for labels to show up
@Atlasize -space ORIG -dset $sclustset \
                      -lab_file $elabel 1 0

# color in AFNI with banded colorscale
3drefit -cmap INT_CMAP $sclustset

# now build new reordered cluster dataset with just the electrodes
#  in the correct order (method suggested by Paul Taylor - thanks!)

# start with empty dataset
3dcalc -a $clustset -expr '0' -prefix $eclustset -overwrite

set n = $#elist
set ebase = `@GetAfniPrefix $eclustset`
foreach ei (`count -digits 3 1 $n `)
   # take value from old list and replace with electrode index
   #  from new list, adding each electrode, one at a time to the
   #  same dataset (unless voxel value not already set in output)
   set sreq = $alist[$ei]
   3dcalc -a $clustset -b $eclustset -c $sclustset    \
    -expr "(b + $elist[$ei]*equals(a,$clist[$ei])*not(b)*not($sreq)) \
            +c*(equals($elist[$ei],c)*step($sreq))"  \
    -prefix $ebase -overwrite
end
# color in AFNI with banded colorscale
3drefit -cmap INT_CMAP $eclustset

# "atlasize" the eclust dataset too here for labels to show up
@Atlasize -space ORIG -dset $eclustset -lab_file $elabel 1 0

rm sclust*.gii
rm eclust*.gii

IsoSurface -isorois+dsets -mergerois+dset -autocrop -o_gii sclust -input $sclustset -remesh 0.1
IsoSurface -isorois+dsets -mergerois+dset -autocrop -o_gii eclust -input $eclustset -remesh 0.1
