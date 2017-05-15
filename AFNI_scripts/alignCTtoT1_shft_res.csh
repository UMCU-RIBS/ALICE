#!/bin/tcsh -f


   set cnt = 1


 if ("$argv[$cnt]" == "-CT_path") then
              
         
            @ cnt ++
            set ct = "$argv[$cnt]"
              
            
 endif
 
 @ cnt ++
 if ("$argv[$cnt]" == "-T1_path") then
            
         
            @ cnt ++
            set t1 = "$argv[$cnt]"
               
            
 endif

# master grid added   
@Align_Centers -base $t1  -dset $ct
3dresample -input CT_highresRAI_shft.nii -prefix CT_highresRAI_res_shft.nii  -master $t1  -dxyz 1 1 1 -rmode NN

align_epi_anat.py -dset1 $t1 -dset2  CT_highresRAI_res_shft.nii -dset1_strip None -dset2_strip None -dset2to1 -suffix _al  -feature_size 1  -overwrite -cost nmi -giant_move -rigid_body

3dcopy  CT_highresRAI_res_shft_al+orig CT_highresRAI_res_al.nii
afni CT_highresRAI_res_al.nii $t1 


HELP:
   echo ""
   echo "Usage: `basename $0` <-CT_path BASE> <-T1_path DSET> [-no_cp] "
   echo "                     "
   echo ""
   echo "   Run inside /data/CT/coregistration"
   echo "   tcsh @alignCTtoT1 -CT_path path_to_CT -T1_path path_to_anatomy"
   echo "   "
   echo ""
   
   
   
   

#set input = $2
#set CTdir = `dirname $input`
#set T1dir = `dirname $input`
#setenv AFNI_DECONFLICT OVERWRITE
#set name = "$input"

#read test 

#afni $T1dir/ANAT*.nii  -dset $CTdir/CT_highresRAI.nii

#@Align_Centers -base $T1dir/ANAT_????.nii  -dset $CTdir/CT_highresRAI.nii

#align_epi_anat.py -dset1 $T1dir -dset2 $CTdir  -dset1_strip None -dset2_strip None -dset2to1 -suffix _al2ct_nmi_noclip  -feature_size 1  -overwrite -cost nmi -giant_move -master_dset2 CT_highresRAInoclip_shft.nii

#afni $T1dir  CT_highresRAInoclip_shft_al.nii

