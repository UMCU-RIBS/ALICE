function [status] = runHermes(obj)
%     This function uses freesurfer surface with electrode position extracted from
%     high res CT 3dclusters. This fucntion project the grid using Hermes
%     ea method. This function was adapted from by Hermes & Miller.
%
%     Copyright (C) 2020  D. Hermes & K.J. Miller, Dept of Neurology and Neurosurgery, University Medical Center Utrecht
%                         MP Branco, UMC Utrecht.
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
hemisphere = obj.settings.Hemisphere{obj.settings.Tabnum};
if strcmp(hemisphere, 'Left')
    hemi = 'L';
elseif strcmp(hemisphere, 'Right')
    hemi = 'R';
elseif strcmp(hemisphere, 'Both')
    hemi = 'L&R';
end

%set directories
if exist('./pictures/') == 0
    mkdir pictures
end

if exist('./results/') == 0
    mkdir results
    mkdir(['results/method_Hermes/' lower(hemisphere) '_hemisphere/intermediate_results/']);

elseif exist('./results/method_Hermes/') == 0
    mkdir results/method_Hermes/
    mkdir(['results/method_Hermes/' lower(hemisphere) '_hemisphere/intermediate_results/']);

elseif exist(['./results/method_Hermes/' lower(hemisphere) '_hemisphere']) == 0

    mkdir(['results/method_Hermes/' lower(hemisphere) '_hemisphere/intermediate_results/']);
end

mypath = ['./results/method_Hermes/' lower(hemisphere) '_hemisphere/intermediate_results/'];
addpath(mypath);

%remove old files
system(['rm ./results/method_Hermes/' lower(hemisphere) '_hemisphere/intermediate_results/' subject '_' hemi '*']);
system(['rm ./results/method_Hermes/' lower(hemisphere) '_hemisphere/intermediate_results/CM_' hemi '*']);
system(['rm ./results/method_Hermes/' lower(hemisphere) '_hemisphere/' subject '_' hemi '*']);
system(['rm ./pictures/' subject '_Hermes_' hemi '*']);
system(['rm ' subject '_' hemi '*']);



%% 1.1) generate surface to project electrodes to

if exist([mypath '/' subject '_' hemi '_balloon_11_03.img'])==0
    % if using freesurfer:
    get_mask_from_FreeSurfer([subject '_' hemi],... % subject name
        './data/FreeSurfer/t1_class.nii',... % freesurfer class file
        mypath,... % where you want to safe the file
        hemi,... % 'l' for left 'r' for right
        11,0.3); % settings for smoothing and threshold
    %Visualize the surface with afni or mricron
    %saved as subject_balloon_11_03, where 11 and 0.3 are the chosen parameters.
end

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


%% 5) project electrodes 2 surface
%start waitbar
f = waitbar(0.2,'Please wait...','windowstyle', 'modal');
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1);

system(['rm ./results/' subject '_' hemi '_singleGrid*']);

load([mypath 'CM_' hemi '_electrodes_sorted_all_aligned.mat']);
gridLabels = cellstr(num2str(nan(size(elecmatrix(:,1)))));
elecmatrix = elecmatrix*0;

% electrodes2surf(subject,localnorm index,do not project electrodes closer than 3 mm to surface)

% electrodes are projected per grid with electrodes2surf.m
% in this example there were 7 grids

% electrodes2surf(
% 1: subject
% 2: number of electrodes local norm for projection (0 = whole grid)
% 3: 0 = project all electrodes, 1 = only project electrodes > 3 mm
%    from surface, 2 = only map to closest point (for strips)
% 4: electrode numbers
% 5: (optional) electrode matrix.mat (if not given, SPM_select popup)
% 6: (optional) surface.img (if not given, SPM_select popup)
% 7: (optional) mr.img for same image space with electrode
%    positions
% automatically saves:
%       a matrix with projected electrode positions
%       a nifti image with projected electrodes
% saved as electrodes_onsurface_filenumber_inputnr2

electrodes_path = [mypath 'CM_' hemi '_electrodes_sorted_all_aligned.mat'];
surface_path = [mypath subject '_' hemi '_balloon_11_03.nii'];
anatomy_path = './data/FreeSurfer/t1_class.nii';

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

    %extract grid size
    gridSize   = str2num(grid(comas(1)+1:end));

    %define params for projection method
    if min(gridSize)==1
        %strip
        parm(1) = 0;
        parm(2) = 2;
    elseif min(gridSize)==2
        %small grid 2xN
        parm(1) = 4;
        parm(2) = 1;
    elseif min(gridSize)>2
        %big grids: 3xN, 4xN, 6xN, 8xN
        parm(1) = 5;
        parm(2) = 1;
    else
        disp('! WARNING: Grid cannot have dimension 0. Please add grid again.');
        %log
        str = get(obj.controls.txtLog, 'string');
        if length(str)>=obj.settings.NUM_LINES
            str = str( (end - (obj.settings.NUM_LINES-1)) :end);
        end
        set(obj.controls.txtLog, 'string',{str{:},'>! WARNING: Grid cannot have dimension 0. Please add grid again.'});
        loggingActions(obj.settings.currdir,3,' >! WARNING: Grid cannot have dimension 0. Please add grid again.');
    end

    %project electrodes
    try
        [out_els,~] = electrodes2surf_FreeSurfer(subject,hemi,parm(1),parm(2),gridEls,electrodes_path, surface_path, anatomy_path, mypath);
    catch
        parm(2) = 2;
        [out_els,~] = electrodes2surf_FreeSurfer(subject,hemi,parm(1),parm(2),gridEls,electrodes_path, surface_path, anatomy_path, mypath);
    end
    %saves as subject_singleGrid_projectedElectrodes_FreeSurfer_X_parm1_parm2,
    %where X is the number of the generated file (1 for the first file with
    %parameters X, Y and 2 for second file with same parameters),
    %and parm1 and parm2 the 2nd and 3rd of the projection function.

    elecmatrix(gridEls,:) = out_els;

end

%convert zero coordinates to nans:
[~, index] = ismember(elecmatrix, [0 0 0], 'rows');
if ~isempty(index)
    elecmatrix(logical(index),:) = nan;
end
%and add all nans after last electrode:
elecmatrix(find(~isnan(elecmatrix(:,1))==1,1, 'last')+1:length(gridLabels),:) = nan;

waitbar(0.4,f,'Please wait...','windowstyle', 'modal');


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

hemisphere = obj.settings.Hemisphere{obj.settings.Tabnum};

if strcmp(hemisphere, 'Left')
    % from freesurfer: in mrdata/.../freesurfer/mri
    gen_cortex_click_from_FreeSurfer(anatomy_path,[subject '_L'],0.5,[15 3],'l',mypath);
    display_view = [-90 0];
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

%% 8) plot electrodes on surface

% load electrodes on surface
load([mypath subject '_' hemi '_projectedElectrodes_FreeSurfer_3dclust.mat']);
% save final folder
save([mypath(1:end-21) subject '_' hemi '_projectedElectrodes_FreeSurfer_3dclust.mat'],'elecmatrix')

%% plot
facealpha = 1;
ctmr_gauss_plot(cortex,[0 0 0],0,facealpha);
fg = gcf;
el_add(elecmatrix,'r',20);
label_add(elecmatrix);

loc_view(90, 0); drawnow
waitbar(0.6,f,'Please wait...','windowstyle', 'modal');

saveas(fg,['./pictures/' subject '_Hermes_' hemi '_rightview.png']);
pause(5);

waitbar(0.8,f,'Please wait...','windowstyle', 'modal');

pause(6);
loc_view(-90, 0);drawnow
saveas(fg,['./pictures/' subject '_Hermes_' hemi '_leftview.png']);


pause(5);
loc_view(display_view(1), display_view(2));drawnow
waitbar(1,f,'Please wait...','windowstyle', 'modal');

pause(5);
close(f);

