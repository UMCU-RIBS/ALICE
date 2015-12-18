function out = threshold_autosegmentation(ni_file)

% ni_file = '/Scratch/CTMR_output/subj1_Roli/23032015/CT_seg/clust.nii';

ni_struct=spm_vol(ni_file);
% from structure to data matrix 
ni_data=spm_read_vols(ni_struct);

ni_data(ni_data>1) = 1;

% save the data
out = ni_struct;
out.fname=[ni_struct.fname(1:end-4) '_thresh.nii'];
spm_write_vol(out,ni_data);cd 