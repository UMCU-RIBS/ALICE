function [status] = runMethod1(obj)
%     Copyright (C) 2009  D. Hermes & K.J. Miller, Dept of Neurology and Neurosurgery, University Medical Center Utrecht
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
% (C) Oct2015. Edited by Anna Gaglianese and Mariana Branco.


%% NOTES;
% This script uses freesurfer surface with electrode position extracted from 
% high res CT 3dclusters (using ctmr script from Dora).


%% set directory and paths:

if exist('./results/')==0
    mkdir results
    mkdir results/projected_electrodes_coord/
end

mypath = './results/';
addpath(mypath);
status = 1;

subject = obj.settings.subject;

%remove old files
system(['rm ./results/' subject '*']);
system(['rm ./results/CM*']);
try
    system(['rm ./results/projected_electrodes_coord/' subject '*']);
end


%% 1.2) Convert DICOM to NIFTI + Coregistration + 3dClustering + electrode selection and sorting

% coregister CT to anatomical MR using Afni and preserving CT resolution.
% extract electrodes clusters using 3D clustering

% extract CM using AFNI-SUMA plug-in.
CM = importdata('./data/3Dclustering/electrode_CM.1D');

%remove repeated electrodes.
[~, index] = unique(CM.data(:,4), 'last');

CM = CM.data(index,[1:4]);

elecCoord = [-CM(:,1:2) CM(:,3)];

elecNum    = CM(:,4);

%check for empty rows and put NANs
elecmatrix = nan(elecNum(end),3); % create empty array 
elecmatrix(elecNum, :) = elecCoord;

save([mypath 'CM_electrodes_sorted_all.mat'],'elecmatrix');


%% 4) Tansform coordinates to subject ANAT space:

load([mypath 'CM_electrodes_sorted_all.mat']);

Tmatrix = dlmread('./data/coregistration/CT_highresRAI_res_shft_al_mat.aff12.1D');
Tmatrix2 = dlmread('./data/coregistration/CT_highresRAI_shft.1D');

T = [reshape(Tmatrix',4,3)  [0 0 0 1]']';
T2 = [reshape(Tmatrix2',4,3)  [0 0 0 1]']';
T3 = T2*T;

coord_al_anatSPM = [];
coord_al_anat = [];

for i = 1:size(elecmatrix,1)
    
  coord = [-elecmatrix(i,1:2) elecmatrix(i,3) 1];
  coord_al_anat(i,:) = T3\coord' ; % = inv(T)*coord'
  coord_al_anatSPM(i,:) = [-coord_al_anat(i,1:2) coord_al_anat(i,3)]; 
  
end

%%%%%%% SPM alignement:
% T = [0.9979    0.0622    0.0154  -13.5301;...
%   -0.0629    0.9971    0.0428   -7.2991;...
%   -0.0127   -0.0437    0.9990  -19.1397;...
%         0         0         0    1.0000];
%
%coord_al_anatSPM = [];
%
%for i = 1:size(elecmatrix,1)  
%  coord = [elecmatrix(i,1:3) 1]; %spm mode
%  coord_al_anatSPM(i,:) = inv(T)*coord' ;  
%end
%%%%%%%%%%%%%%%%%

% check result:
% figure,
% plot3(coord_al_anatSPM(:,1),coord_al_anatSPM(:,2),coord_al_anatSPM(:,3),'.','MarkerSize',20); hold on;
% plot3(elecmatrix(:,1),elecmatrix(:,2),elecmatrix(:,3),'.r','MarkerSize',20); legend('aligned');

elecmatrix = coord_al_anatSPM(:,1:3);
save([mypath subject '_projectedElectrodes_FreeSurfer_3dclust.mat'],'elecmatrix');



%% 5) generate cortex to render images:

anatomy_path = './data/FreeSurfer/t1_class.nii';

% from freesurfer: in mrdata/.../freesurfer/mri
gen_cortex_click_from_FreeSurfer(anatomy_path,[subject '_L'],0.5,[15 3],'l',mypath);
% load cortex
load([mypath subject '_L_cortex.mat']);
save([mypath '/projected_electrodes_coord/' subject '_L_cortex.mat'],'cortex');

% from freesurfer: in mrdata/.../freesurfer/mri
gen_cortex_click_from_FreeSurfer(anatomy_path,[subject '_R'],0.5,[15 3],'r',mypath);

% save cortex
load([mypath subject '_R_cortex.mat']);
save([mypath '/projected_electrodes_coord/' subject '_R_cortex.mat'],'cortex');


%% 8) plot electrodes on surface

% load electrodes on surface
load([mypath subject '_projectedElectrodes_FreeSurfer_3dclust.mat']);
% save final folder
save([mypath '/projected_electrodes_coord/' subject '_projectedElectrodes_FreeSurfer_3dclust.mat'],'elecmatrix')

%load and merge hemispheres in one cortex structure
L_cortex = load([mypath subject '_L_cortex.mat']);
R_cortex = load([mypath subject '_R_cortex.mat']);
clear cortex;
cortex.vert = [R_cortex.cortex.vert; R_cortex.cortex.vert];
cortex.tri = [R_cortex.cortex.tri; R_cortex.cortex.tri];

ctmr_gauss_plot_seeg(L_cortex.cortex,R_cortex.cortex,[0 0 0],0);

el_add(elecmatrix,'r',20);
label_add(elecmatrix);

display_view = [90 0];
loc_view(display_view(1), display_view(2));
saveas(gcf,[subject '_right.png']);

display_view = [-90 0];
loc_view(display_view(1), display_view(2));
saveas(gcf,[subject '_left.png']);

display_view = [90 90];
loc_view(display_view(1), display_view(2));
saveas(gcf,[subject '_top.png']);
