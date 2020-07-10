function [status] = runHD(obj)
%     This function uses freesurfer surface with electrode position extracted from 
%     high res CT 3dclusters. This function uses NeuralAct toolbox to
%     display the grid on the surface and assumes small brain shift.
%
%     Copyright (C) 2020  MP Branco. UMC Utrecht
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


%% set directory and paths:

status = 1;

subject = obj.settings.subject;

%set hemisphere
hemisphere = obj.settings.Hemisphere;
if strcmp(hemisphere, 'Left')
    hemi = 'L';
elseif strcmp(hemisphere, 'Right')
    hemi = 'R';
elseif strcmp(hemisphere, 'Both')
    hemi = 'L&R';
    hemisphere = 'left_right';
end

%set directories
if exist('./pictures/') == 0
    mkdir pictures
end

if exist('./results/')==0
    mkdir results
    mkdir(['results/method_HD/' lower(hemisphere) '_hemisphere/intermediate_results/']);

elseif exist('./results/method_HD/') == 0
    mkdir results/method_HD/
    mkdir(['results/method_HD/' lower(hemisphere) '_hemisphere/intermediate_results/']);
end

mypath = ['./results/method_HD/' lower(hemisphere) '_hemisphere/intermediate_results/'];
addpath(mypath);

%remove old files
system(['rm ./results/method_HD/' lower(hemisphere) '_hemisphere/intermediate_results/' subject '_' hemi '*']);
system(['rm ./results/method_HD/' lower(hemisphere) '_hemisphere/intermediate_results/CM_' hemi '*']);
system(['rm ./results/method_HD/' lower(hemisphere) '_hemisphere/' subject '_' hemi '*']);
system(['rm ./pictures/' subject '_HD_' hemi '*']);
system(['rm ' subject '_' hemi '*']); %backward compatability



%% Convert DICOM to NIFTI + Coregistration + 3dClustering + electrode selection and sorting

% coregister CT to anatomical MR using Afni and preserving CT resolution.
% extract electrodes clusters using 3D clustering

% extract CM using AFNI-SUMA plug-in.
elecmatrix = importdata('./data/3Dclustering/electrode_CM.1D');

%remove repeated electrodes.
[~, index] = unique(elecmatrix.data(:,4), 'last');

elecmatrix = elecmatrix.data(index,[1:3]);

elecmatrix = [-elecmatrix(:,1:2) elecmatrix(:,3)];

save([mypath 'CM_' hemi '_electrodes_sorted_all.mat'],'elecmatrix');


%% Tansform coordinates to subject ANAT space:

load([mypath 'CM_' hemi '_electrodes_sorted_all.mat']);

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
save([mypath 'CM_' hemi '_electrodes_sorted_all_aligned.mat'],'elecmatrix');


%% extract grid info
%start waitbar
f = waitbar(0.2,'Please wait...','windowstyle', 'modal');
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1);

load([mypath 'CM_' hemi '_electrodes_sorted_all_aligned.mat']);
gridLabels = num2cell(elecmatrix(:,1));
elecmatrix = zeros(size(elecmatrix));

for g=1:size(obj.settings.Grids,2)
    
    grids = obj.settings.Grids{g};
    %find comas:
    comas = strfind(grids,',');
       
    %extract electrode number
    gridEls   = str2num(grids(comas(1)+1:comas(2)-1));
    %extract electrode coordinates
    elecmatrix(gridEls,:) = coord_al_anatSPM(gridEls,:);
    
    %extract label and remove spaces
    gridLabel = grids(1:comas(1)-1);
    gridLabel = gridLabel((~isspace(gridLabel)));
    gridLabels(gridEls,1) = cellstr(repmat(gridLabel,length(gridEls),1));
    
end

%convert zero coordinates to nans:
[~, index] = ismember(elecmatrix, [0 0 0], 'rows');
if ~isempty(index)
    elecmatrix(logical(index),:) = nan;
    gridLabels(logical(index),:) = {'NaN'};
end
%and remove all nans because we are only interested in HD:
gridLabels(isnan(elecmatrix(:,1))) = [];
elecmatrix(isnan(elecmatrix(:,1)),:) = [];

%% combine electrode files into one 

% save all projected electrode locaions in a .mat file
save([mypath subject '_' hemi '_electrodes_NOT_PROJECTED.mat'],'elecmatrix');


% make a NIFTI image with all projected electrodes
if isfield(obj.settings,'saveNii') && obj.settings.saveNii == 1
    
    [output,~,~,outputStruct]=...
        position2reslicedImage2(elecmatrix,anatomy_path);
    
    for filenummer=1:100
        outputStruct.fname=[mypath subject '_' hemi '_electrodes_NOT_PROJECTED' int2str(filenummer) '.img' ];
        if ~exist(outputStruct.fname,'file')>0
            disp(['saving ' outputStruct.fname]);
            % save the data
            spm_write_vol(outputStruct,output);
            break
        end
    end
end

%% generate cortex to render images:

anatomy_path = './data/FreeSurfer/t1_class.nii';

hemisphere = obj.settings.Hemisphere;
if strcmp(hemisphere, 'Left')
    % from freesurfer: in mrdata/.../freesurfer/mri
    gen_cortex_click_from_FreeSurfer(anatomy_path,[subject '_L'],0.5,[15 3],'l',mypath);
    display_view = [270 0];
    % load cortex
    load([mypath subject '_L_cortex.mat']);
    save([mypath(1:end-21) subject '_L_cortex.mat'],'cortex');
    
elseif strcmp(hemisphere, 'Right')
    % from freesurfer: in mrdata/.../freesurfer/mri
    gen_cortex_click_from_FreeSurfer(anatomy_path,[subject '_R'],0.5,[15 3],'r',mypath);
    display_view = [90 0];
    % load cortex
    load([mypath subject '_R_cortex.mat']);
    save([mypath(1:end-21) subject '_R_cortex.mat'],'cortex');
else
    % from freesurfer: in mrdata/.../freesurfer/mri
    gen_cortex_click_from_FreeSurfer(anatomy_path,[subject '_L&R'],0.5,[15 3],'l_r',mypath);
    display_view = [90 0];
    % load cortex
    load([mypath subject '_L&R_cortex.mat']);
    save([mypath(1:end-21) subject '_L&R_cortex.mat'],'cortex');
end


%% save electrodes on surface before correction

% load electrodes on surface
load([mypath subject '_' hemi '_electrodes_NOT_PROJECTED.mat']);
% save final folder
save([mypath(1:end-21) subject '_' hemi '_electrodes_NOT_PROJECTED.mat'],'elecmatrix')


%% NeuralAct for HD
waitbar(0.6,f,'Please wait...','windowstyle', 'modal');

subj.electrodes = elecmatrix;

%make the model coarser:
% load cortex
cortexcoarser = coarserModel(cortex, 5000);

%compute the convex hull:
hullcortex = hullModel(cortexcoarser);

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

save([mypath subject '_' hemi '_neuralAct_data_to_plot'], 'subj', 'cortex', 'cortexcoarser', 'elecmatrix','hullcortex', 'vcontribs');

trielectrodes = subj.trielectrodes;
% trielectrodes(3,3) = trielectrodes(3,3)-1; %correct one electrode of
save([mypath(1:end-21) subject '_' hemi '_Electrodes_displayed_on_surface'], 'trielectrodes');


%% Save coordinates in txt file
cell_with_coord = [gridLabels num2cell(round(trielectrodes,4))];

try
    writecell(cell_with_coord,[mypath(1:end-21) subject '_' hemi '_Electrodes_displayed_on_surface.txt'],'Delimiter','tab');
catch
    disp('WARNING: Unable to save coordinates in txt file. Please use more recent version of Matlab (> 2019a)');
end

%% Plotting
load([mypath subject '_' hemi '_neuralAct_data_to_plot']);

viewstruct.what2view        = {'brain', 'trielectrodes','electrodes'};
viewstruct.viewvect         = display_view;
viewstruct.material         = 'dull';
viewstruct.enablelight      = 1;
viewstruct.enableaxis       = 0;

if strcmp(hemisphere, 'Right')
    viewstruct.lightpos = [200, 0, 200];
else
    viewstruct.lightpos = [-200, 0, 200];
end

viewstruct.lightingtype     = 'gouraud';
cmapstruct.cmap             = colormap('Jet'); 
if ishandle(2)
    close(gcf); %because colormap creates a figure but not in newer versions of matlab
end
cmapstruct.basecol          = [0.7, 0.7, 0.7];
cmapstruct.fading           = false;
cmapstruct.ixg2             = floor(length(cmapstruct.cmap) * 0.15);
cmapstruct.ixg1             = -cmapstruct.ixg2;
cmapstruct.enablecolormap   = true;
cmapstruct.enablecolorbar   = false;
cmapstruct.cmin             = 0;
cmapstruct.cmax             = 1;
viewstruct.what2view        = {'brain'};

waitbar(0.8,f,'Please wait...','windowstyle', 'modal');

%% Plot brain

facealpha = 1;
ctmr_gauss_plot(cortex,[0 0 0],0,facealpha);
fg = gcf;
%Add spheres electrodes
plotSpheres(subj.trielectrodes, 'b');
loc_view(display_view(1), display_view(2)+30);
pause(3);

saveas(fg,['./pictures/' subject '_HD_' hemi '.png']);

pause(3);
waitbar(1,f,'Please wait...','windowstyle', 'modal');

pause(5);
close(f);

