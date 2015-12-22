% output mni_elcoord

% you need:
% elecmatrix: electrode times XYZ in subject space
% spm normalization parameters
% normalized MRI
% have SPM8 or SPM5 in the path

% create ./data/temp/

% Dora Hermes - July 2012

subj='name';
par.anat = './data/t1.nii';
par.norm_mat = './data/t1_seg_sn.mat'; % normalizationmmatrix from SPM
load(['.data/' subj '_electrodes_surface_loc_all.mat']);
% make a ./data/temp diractory to save data
mkdir ./data/temp
% elecmatrix=[]; % load XYZ individual subjects

% quick fix for missing electrodes:
% correct for electrodes somehow gone missing through normalization
% electrodes can go missing because voxels might get lost in normalization,
% you can shift the electrode by 1 mm and see whether it does not get lost,
% this can happen for ~ 10 electrodes or more
% if this does not work, you can use a normalization with increased voxel
% size, which will slow down the entire process and take up more space
% example for electrode number 20 and 30
if (isequal(subj,'name'))
    elecmatrix(20,:)=elecmatrix(20,:)-1;
    elecmatrix(30,:)=elecmatrix(30,:)-1;
end
% put electrode positions in the T1 space nifti
[output,els,els_ind,outputStruct] = position2reslicedImage_nrs(elecmatrix,par.anat,subj);
clear output
%% normalize the T2 space nifti with electrodes
% nii_normels=[pwd '/data/temp/' subj '_electrodesNRs1.nii'];
nii_normels=['./data/temp/' subj '_electrodesNRs1.nii'];
flags.preserve  = 0;
flags.bb        = [-90 -120 -60; 90 96 100];
flags.vox       = [1 1 1]; % here is the voxel size
flags.interp    = 0;
flags.wrap      = [0 0 0];
flags.prefix    = 'w';

job.subj.matname{1}=par.norm_mat;
job.subj.resample{1}=nii_normels;
job.roptions=flags;

% normalize the image with electrodess
spm_run_normalise_write(job);

%% get normalized electrode coordinates

nii_normels=['./data/temp/w' subj '_electrodesNRs1.nii'];

data.Struct=spm_vol(nii_normels);
[m,xyz]=spm_read_vols(data.Struct);% from structure to data matrix

mni_elcoord=zeros(max(m(:)),3);

% check for missing electrodes and display in command window
for k=1:max(m(:))
    if isempty(find(m(:)==k,1));
        disp(['electrode ' int2str(k) ' missing'])
    end
end

for k=1:max(m(:))
    mni_elcoord(k,:)=xyz(:,find(m(:)==k,1));
end

% mni_elcoord is your output :)


