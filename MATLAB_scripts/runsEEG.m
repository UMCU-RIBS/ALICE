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
%Note [MPB 10-08-2022]: the indices inside electrode_CM.1D are the indices
%of the labels in electrode_labels.txt

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

%extract electrode numbers
if ~isfield(obj.settings, 'Labels') || isempty(obj.settings.Labels)
    errordlg('Please enter *.txt file with electrode labels in Step 2!');
    close(f);
    return;
else
    labels = readcell(obj.settings.Labels);
end

for g=1:size(obj.settings.Grids,2)
    
    grid       = obj.settings.Grids{g};
    %find comas:
    comas      = strfind(grid,';');
       
    gridLabels = labels;
    gridEls    = find(ismember(regexprep(labels,'\d+$',''), strtrim(grid(1:comas(1)-1))));

    % new method: interpolate electrodes between first and last of the shaft
    if sum(isnan(coord_al_anatSPM(gridEls)))>0
        firstEl = coord_al_anatSPM(gridEls(1),:);
        lastEl  = coord_al_anatSPM(gridEls(end),:);
        if sum(isnan(firstEl))>0 || sum(isnan(lastEl))>0
            errordlg('Either the first or last electrode coordinate is missing. Please select again in Step 2.');
            return;
        end

        %interpolate coordinates in between
        numEls    = numel(gridEls);
        numPoints = numEls - 2;
        px = nan(numPoints,1);
        py = nan(numPoints,1);
        pz = nan(numPoints,1);

        for i=1:numPoints

            px(i) = (firstEl(1)*i + lastEl(1)*(numPoints-i+1)) / (numPoints+1);
            py(i) = (firstEl(2)*i + lastEl(2)*(numPoints-i+1)) / (numPoints+1);
            pz(i) = (firstEl(3)*i + lastEl(3)*(numPoints-i+1)) / (numPoints+1);

        end

        interpEls             = flipud([lastEl; [px py pz]; firstEl]);
        elecmatrix(gridEls,:) = interpEls;
    
    else 
        %use all selected electrodes
        elecmatrix(gridEls,:) = coord_al_anatSPM(gridEls,:);
    end
       
end

%convert zero coordinates to nans:
[~, index] = ismember(elecmatrix, [0 0 0], 'rows');
if ~isempty(index)
    elecmatrix(logical(index),:) = nan;
end
%and add all nans after last electrode:
elecmatrix(find(~isnan(elecmatrix(:,1))==1,1, 'last')+1:length(gridLabels),:) = nan;

waitbar(0.3,f,'Please wait...','windowstyle', 'modal');


%% 6) combine electrode files into one

% save all projected electrode locaions in a .mat file
save([mypath subject '_' hemi '_projectedElectrodes_FreeSurfer_3dclust.mat'],'elecmatrix');

% save projected coordinatinates in a tsv file
cell_with_coord = [{'name', 'x', 'y', 'z', 'size'}; gridLabels num2cell(round(elecmatrix,4)) repmat({'n/a'},size(gridLabels))];

try
    writecell(cell_with_coord,[mypath(1:end-21) subject '_' hemi '_projectedElectrodes_FreeSurfer_3dclust.txt'],'Delimiter','tab');
    movefile([mypath(1:end-21) subject '_' hemi '_projectedElectrodes_FreeSurfer_3dclust.txt'], [mypath(1:end-21) subject '_' hemi '_projectedElectrodes_FreeSurfer_3dclust.tsv']);
catch
    disp('WARNING: Unable to save coordinates in tsv file. Please use more recent version of Matlab (> 2019a)');
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
loc_view(display_view(1), display_view(2));drawnow

waitbar(0.4,f,'Please wait...','windowstyle', 'modal');

pause(5);
saveas(currentfig,['./pictures/' subject '_sEEG_' hemi '_rightview.png']);

waitbar(0.6,f,'Please wait...','windowstyle', 'modal');

pause(5);
display_view = [-90 0];
loc_view(display_view(1), display_view(2));drawnow
pause(3);
saveas(currentfig,['./pictures/' subject '_sEEG_' hemi '_leftview.png']);

waitbar(0.8,f,'Please wait...','windowstyle', 'modal');

pause(5);
display_view = [90 90];
loc_view(display_view(1), display_view(2)); drawnow
pause(3);
saveas(currentfig,['./pictures/' subject '_sEEG_' hemi '_topview.png']);

waitbar(1,f,'Please wait...','windowstyle', 'modal');

pause(35);
display_view = [-90 45];
loc_view(display_view(1), display_view(2)); drawnow

pause(5);
close(f);

