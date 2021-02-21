mypath  = '/Fridge/bci/data/14-420_adults/veere/analysed/ALICE/results/';   %path fo ALICE/results folder
subject = 'veere'; %subject code name
hemi    = 'L';    %implanted hemisphere (L, R or L&R)

% load electrodes on surface
load([mypath subject '_' hemi '_projectedElectrodes_FreeSurfer_3dclust.mat']);

%load cortex
load([mypath subject '_' hemi '_cortex.mat']);

%set brain transparency
facealpha = 0.3; %1 for opaque, 0 for transparent

%plot brain
ctmr_gauss_plot(cortex,[0 0 0],0,facealpha);

%add electrodes
el_add(elecmatrix,'r',20);

%add label
label_add(elecmatrix);

%set view
loc_view(90, 0);  %for right view
loc_view(-90, 0); %for left view

%save figure
saveas(gcf,[subject '_' hemi '_SETVIEW.png']);