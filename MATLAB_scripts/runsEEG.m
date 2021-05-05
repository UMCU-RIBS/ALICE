function [status] = runsEEG(obj)
%     This function uses freesurfer surface with electrode position extracted from 
%     high res CT 3dclusters. This function doe snot project the
%     coordinates to the brain surface and assumes no brain shift.
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
hemisphere = 'left_right';
hemi = 'L&R';

%set directories
if exist('./pictures/') == 0
    mkdir pictures
end

if exist('./results/')==0
    mkdir results
    mkdir(['results/method_sEEG/' lower(hemisphere) '_hemisphere/intermediate_results/']);

elseif exist('./results/method_sEEG/') == 0
    mkdir results/method_sEEG/
    mkdir(['results/method_sEEG/' lower(hemisphere) '_hemisphere/intermediate_results/']);
end

mypath = ['./results/method_sEEG/' lower(hemisphere) '_hemisphere/intermediate_results/'];
addpath(mypath);


%remove old files
system(['rm ./results/method_sEEG/' lower(hemisphere) '_hemisphere/intermediate_results/' subject '_' hemi '*']);
system(['rm ./results/method_sEEG/' lower(hemisphere) '_hemisphere/intermediate_results/CM_' hemi '*']);
system(['rm ./results/method_sEEG/' lower(hemisphere) '_hemisphere/' subject '_' hemi '*']);
system(['rm ./pictures/' subject '_sEEG_' hemi '*']);
system(['rm ' subject '_' hemi '*']); %backward compatability



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

save([mypath 'CM_' hemi '_electrodes_sorted_all.mat'],'elecmatrix');


%% 4) Tansform coordinates to subject ANAT space:

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

elecmatrix = coord_al_anatSPM(:,1:3);
save([mypath 'CM_' hemi '_electrodes_sorted_all_aligned.mat'],'elecmatrix');


%% 5) extract grid info
f = waitbar(0.2,'Please wait...','windowstyle', 'modal');
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1);

load([mypath 'CM_' hemi '_electrodes_sorted_all_aligned.mat']);
gridLabels = cellstr(num2str(nan(size(elecmatrix(:,1)))));
elecmatrix = elecmatrix*0;

for g=1:size(obj.settings.Grids,2)
    
    grid = obj.settings.Grids{g};
    %find comas:
    comas = strfind(grid,';');
       
    %extract electrode number
    gridEls   = str2num(grid(comas(1)+1:comas(2)-1));
    %extract electrodes coordinates
    elecmatrix(gridEls,:) = coord_al_anatSPM(gridEls,:);
     
    %extract label and remove spaces
    gridLabel = grid(1:comas(1)-1);
    gridLabel = gridLabel((~isspace(gridLabel)));
    gridLabels(gridEls,1) = cellstr(repmat(gridLabel,length(gridEls),1));
    
end

%convert zero coordinates to nans:
[~, index] = ismember(elecmatrix, [0 0 0], 'rows');
if ~isempty(index)
    elecmatrix(logical(index),:) = nan;
    gridLabels(logical(index),:) = {'NaN'};
end
%and remove all nans after last electrode:
elecmatrix(find(~isnan(elecmatrix(:,1))==1,1, 'last')+1:end,:) = [];
gridLabels(find(~isnan(elecmatrix(:,1))==1,1, 'last')+1:end,:) = [];

%% 6) combine electrode files into one

% save all projected electrode locaions in a .mat file
save([mypath subject '_' hemi '_projectedElectrodes_FreeSurfer_3dclust.mat'],'elecmatrix');

% save projected coordinatinates in a txt file
cell_with_coord = [gridLabels num2cell(round(elecmatrix,4))];

try
    writecell(cell_with_coord,[mypath(1:end-21) subject '_' hemi '_projectedElectrodes_FreeSurfer_3dclust.txt'],'Delimiter','tab');
catch
    disp('WARNING: Unable to save coordinates in txt file. Please use more recent version of Matlab (> 2019a)');
end

% make a NIFTI image with all projected electrodes
anatomy_path = './data/FreeSurfer/t1_class.nii';

if isfield(obj.settings,'saveNii') && obj.settings.saveNii == 1
    
    [output,~,~,outputStruct] = position2reslicedImage2(elecmatrix,anatomy_path);
    
    for filenummer = 1:100
        outputStruct.fname = [mypath subject '_' hemi '_projectedElectrodes_FreeSurfer_3dclust' int2str(filenummer) '.nii' ];
        
        if ~exist(outputStruct.fname,'file') > 0
            disp(['saving ' outputStruct.fname]);
            % save the data
            spm_write_vol(outputStruct,output);
            break
        end
    end
end

%% 7) generate cortex to render images:

anatomy_path = './data/FreeSurfer/t1_class.nii';

% from freesurfer: in mrdata/.../freesurfer/mri
gen_cortex_click_from_FreeSurfer(anatomy_path,[subject '_' hemi],0.5,[15 3],'l_r',mypath);
display_view = [90 0];
% load cortex
load([mypath subject '_' hemi '_cortex.mat']);
save([mypath(1:end-21) subject '_' hemi '_cortex.mat'], 'cortex');



%% 8) plot electrodes on surface

% load electrodes on surface
load([mypath subject '_' hemi '_projectedElectrodes_FreeSurfer_3dclust.mat']);
% save final folder
save([mypath(1:end-21) subject '_' hemi '_projectedElectrodes_FreeSurfer_3dclust.mat'],'elecmatrix')

%% plot

facealpha = 0.3;
ctmr_gauss_plot(cortex,[0 0 0],0,facealpha);
currentfig = gcf;
el_add(elecmatrix,'r',20);
label_add(elecmatrix);
display_view = [90 0];
loc_view(display_view(1), display_view(2));

waitbar(0.4,f,'Please wait...','windowstyle', 'modal');

pause(3);
saveas(currentfig,['./pictures/' subject '_sEEG_' hemi '_rightview.png']);

waitbar(0.6,f,'Please wait...','windowstyle', 'modal');

pause(3);
display_view = [-90 0];
loc_view(display_view(1), display_view(2));
pause(3);
saveas(currentfig,['./pictures/' subject '_sEEG_' hemi '_leftview.png']);

waitbar(0.8,f,'Please wait...','windowstyle', 'modal');

pause(3);
display_view = [90 90];
loc_view(display_view(1), display_view(2));
pause(3);
saveas(currentfig,['./pictures/' subject '_' hemi '_topview.png']);

waitbar(1,f,'Please wait...','windowstyle', 'modal');

pause(3);
display_view = [-90 45];
loc_view(display_view(1), display_view(2));

pause(5);
close(f);

