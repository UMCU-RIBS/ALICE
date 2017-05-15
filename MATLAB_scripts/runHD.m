function [status] = runHD(obj)
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
% high res CT 3dclusters (using ctmr scirpt from Dora).


%% set directory and paths:

if exist('./results_HD/')==0
    mkdir results_HD
    mkdir results_HD/projected_electrodes_coord
end

mypath = './results_HD/';
addpath(mypath);
status = 1;

subject = obj.settings.subject;

%remove old files
system(['rm ./results_HD/' subject '*']);
system(['rm ./results_HD/CM*']);

%% 1.1) generate surface to project electrodes to
hemisphere = obj.settings.Hemisphere;
if strcmp(hemisphere, 'Left')
    hemi = 'l';
else
    hemi = 'r';
end

if exist(['./results_HD/' subject '_balloon_11_03.img'])==0
    % if using freesurfer:
    get_mask_from_FreeSurfer(subject,... % subject name
        './data/FreeSurfer/t1_class.nii',... % freesurfer class file
        './results_HD/',... % where you want to safe the file
        hemi,... % 'l' for left 'r' for right
        11,0.3); % settings for smoothing and threshold
    %Visualize the surface with afni or mricron
    %saved as subject_balloon_11_03, where 11 and 0.3 are the chosen parameters.
end

%% 1.2) Convert DICOM to NIFTI + Coregistration + 3dClustering + electrode selection and sorting

% coregister CT to anatomical MR using Afni and preserving CT resolution.
% extract electrodes clusters using 3D clustering

% extract CM using AFNI-SUMA plug-in.
elecmatrix = importdata('./data/3Dclustering/electrode_CM.1D');
elecmatrix = elecmatrix.data(:,[1:3]);
elecmatrix = [-elecmatrix(:,1:2) elecmatrix(:,3)];

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

% check result:
% figure,
% plot3(coord_al_anatSPM(:,1),coord_al_anatSPM(:,2),coord_al_anatSPM(:,3),'.','MarkerSize',20); hold on;
% plot3(elecmatrix(:,1),elecmatrix(:,2),elecmatrix(:,3),'.r','MarkerSize',20); legend('aligned');

elecmatrix = coord_al_anatSPM;
save([mypath 'CM_electrodes_sorted_all_aligned.mat'],'elecmatrix');


%% 5) project electrodes 2 surface

electrodes_path = [mypath 'CM_electrodes_sorted_all_aligned.mat'];
surface_path = [mypath subject '_balloon_11_03.img'];
anatomy_path = './data/FreeSurfer/t1_class.nii';

%% 6) combine electrode files into one 

% save all projected electrode locaions in a .mat file
save([mypath subject '_electrodes_NOT_PROJECTED.mat'],'elecmatrix');


% make a NIFTI image with all projected electrodes
[output,els,els_ind,outputStruct]=...
    position2reslicedImage2(elecmatrix,anatomy_path);

for filenummer=1:100
    outputStruct.fname=[mypath subject '_electrodes_NOT_PROJECTED' int2str(filenummer) '.img' ];
    if ~exist(outputStruct.fname,'file')>0
        disp(['saving ' outputStruct.fname]);
        % save the data
        spm_write_vol(outputStruct,output);
        break
    end
end

%% 7) generate cortex to render images:

hemisphere = obj.settings.Hemisphere;
if strcmp(hemisphere, 'Left')
    % from freesurfer: in mrdata/.../freesurfer/mri
    gen_cortex_click_from_FreeSurfer(anatomy_path,[subject '_L'],0.5,[15 3],'l',mypath);
    display_view = [270 0];
    % load cortex
    load([mypath subject '_L_cortex.mat']);
    save([mypath '/projected_electrodes_coord/' subject '_L_cortex.mat'],'cortex');
    
elseif strcmp(hemisphere, 'Right')
    % from freesurfer: in mrdata/.../freesurfer/mri
    gen_cortex_click_from_FreeSurfer(anatomy_path,[subject '_R'],0.5,[15 3],'r',mypath);
    display_view = [90 0];
    % load cortex
    load([mypath subject '_R_cortex.mat']);
    save([mypath '/projected_electrodes_coord/' subject '_R_cortex.mat'],'cortex');
end

%% 8) plot electrodes on surface before correction

% load electrodes on surface
load([mypath subject '_electrodes_NOT_PROJECTED.mat']);
% save final folder
save([mypath '/projected_electrodes_coord/' subject '_electrodes_NOT_PROJECTED.mat'],'elecmatrix')

ctmr_gauss_plot(cortex,[0 0 0],0);
el_add(elecmatrix,'r',20);
loc_view(display_view(1), display_view(2));


%% 9) NeuralAct for HD

subj.electrodes = elecmatrix;

%make the model coarser:
% load cortex
cortexcoarser = coarserModel(cortex, 5000);

%compute the convex hull:
hullcortex = hullModel(cortexcoarser);

% View the brain and electrode locations
%look at that brain and the electrode grids, using viewBrain:
%(see also |viewBrain|)
figure, set(gca, 'Color', 'none'); set(gcf, 'Color', 'w'); grid on;
viewBrain(hullcortex, subj, {'brain', 'electrodes'}, 0.7, 32, [330,00]);
title('Flattened brain model and electrode locations');
light('Position',[-200, -200, 200]);

% Project the electrodes
%project the electrodes onto the surface of the brain:
normdist = 25;
%(using the normal vector projection; the normal vector is computed by
%averaging the normal vectors at the electrode distance normdist and less;
%see also |projectElectrodes| for a more thorough information on its arguments)
[ subj ] = projectElectrodes(hullcortex, subj, normdist);

%plot no activations:
kernel = 'linear';
param = 10;
cutoff = 10;
subj.activations = zeros(size(elecmatrix,1),1);
%produce an empty contribution field.
[ vcontribs ] = electrodesContributions( cortex, subj, kernel, param, cutoff);

save([mypath 'neuralAct_data_to_plot'], 'subj', 'cortex', 'cortexcoarser', 'elecmatrix','hullcortex', 'vcontribs');

trielectrodes = subj.trielectrodes;
save([mypath '/projected_electrodes_coord/Electrodes_displayed_on_surface'], 'trielectrodes');

%% Plot
load([mypath 'neuralAct_data_to_plot']);

viewstruct.what2view = {'brain', 'trielectrodes','electrodes'};
viewstruct.viewvect = [display_view];
viewstruct.material = 'dull';
viewstruct.enablelight = 1;
viewstruct.enableaxis = 0;
if strcmp(hemisphere, 'Right')
    viewstruct.lightpos = [200, 0, 200];
else
    viewstruct.lightpos = [-200, 0, 200];
end
viewstruct.lightingtype = 'gouraud';
cmapstruct.cmap = colormap('Jet'); close(gcf); %because colormap creates a figure
cmapstruct.basecol = [0.7, 0.7, 0.7];
cmapstruct.fading = false;
cmapstruct.ixg2 = floor(length(cmapstruct.cmap) * 0.15);
cmapstruct.ixg1 = -cmapstruct.ixg2;
cmapstruct.enablecolormap = true;
cmapstruct.enablecolorbar = false;
cmapstruct.cmin = 0;
cmapstruct.cmax = 1;

%Run |NeuralAct|:
%add spheres electrodes
viewstruct.what2view = {'brain'};
figure; set(gca, 'Color', 'none'); set(gcf, 'Color', 'w'); grid off;
NeuralAct( cortex, vcontribs, subj, 1, cmapstruct, viewstruct );
plotSpheres(subj.trielectrodes, 'b');

