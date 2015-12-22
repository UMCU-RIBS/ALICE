function [xyztCortex,t_surf] = voxplot_func_gm(cname,sName,tName,Tthreshold,Dthreshold,gmName)

%settings

% Tthreshold=4;%4.62;% >10 for groo motor picture, 4.62 FWE corrected
% Dthreshold=8;% distance threshold in mm (<=)
GMthreshold=0.1;

%% load files
% load cortex
%[cname]=spm_select(1,'mat','select cortex.mat');
load(cname); % cortex

% load surface
%[data.sName]=spm_select(1,'image','select image with surface');
s_info=spm_vol(sName); [s]=spm_read_vols(s_info);

% load tmap
%[data.tName]=spm_select(1,'image','select image with tmap');
t_info=spm_vol(tName); [t]=spm_read_vols(t_info);

% load gray matter
%[data.gmName]=spm_select(1,'image','select image with rc1');
gm_info=spm_vol(gmName); [gm]=spm_read_vols(gm_info);

%%
% indices to native surface
[xs,ys,zs]=ind2sub(size(s),find(s>0));
xyzs=[xs ys zs];
clear xs ys zs % housekeeping
xyzs=(xyzs*s_info.mat(1:3,1:3)')+repmat(s_info.mat(1:3,4),1,length(xyzs))';

% indices to native tmap
[xt,yt,zt]=ind2sub(size(t),find(t>Tthreshold));
xyzt=[xt yt zt];
clear xt yt zt % housekeeping
xyzt=(xyzt*t_info.mat(1:3,1:3)')+repmat(t_info.mat(1:3,4),1,length(xyzt))';

% indices to native gray matter
[xgm,ygm,zgm]=ind2sub(size(gm),find(gm>GMthreshold));
xyzgm=[xgm ygm zgm];
clear xgm ygm zgm % housekeeping
xyzgm=(xyzgm*gm_info.mat(1:3,1:3)')+repmat(gm_info.mat(1:3,4),1,length(xyzgm))';

% make selection of t within gm
xyzt=intersect(xyzt,xyzgm,'rows');

% select tmap coordinates that are within Dthreshold mm of surface
tsel=zeros(length(xyzt),1);
tnewind=zeros(length(xyzt),1);
for k=1:length(xyzt)
    distvect=(sum((xyzs-repmat(xyzt(k,:),length(xyzs),1)).^2,2)).^0.5;
    if min(distvect)<=Dthreshold
        tsel(k)=1;
        tnewind(k)=find(distvect==min(distvect),1);
    end
end
clear distvect;
tnewind=tnewind(tnewind>0);

% set rest to []
xyzt(tsel==0,:)=[];
xyztSurf=xyzs(tnewind,:);

% get t values
t_surf=t(t>Tthreshold);
t_surf=t_surf(tsel>0);

% get coordinates on cortex (instead of surface)
xyztCortex_ind=zeros(length(xyzt(:,1)),1);
for k=1:length(xyzt(:,1))    
    distvect=(sum((cortex.vert-repmat(xyzt(k,:),length(cortex.vert),1)).^2,2)).^0.5;
    xyztCortex_ind(k)=find(distvect==min(distvect),1);
end
xyztCortex=cortex.vert(xyztCortex_ind,:);

%% then ctmr_vox_plot

% xyzt: original xyz coordinates of T values 
% xyztSurface: xyz coordinates on the surface closest to the voxel
% xyztCortex: xyz coordinates on the cortex rendering closest to the
    % surface
% t_surf: tvalues corresponding to the above

% ctmr_vox_plot(cortex,xyztCortex,t_surf)
% view(270,30)
% ctmr_vox_plot(cortex,xyzt,t_surf)
% ctmr_vox_plot(cortex,xyzt,ones(size(t_surf)))% more or less the same
% ctmr_vox_plot(cortex,[0 0 0],0);
% 
% add electrodes on cortex
% el_add(elecmatrix,'w',20) % white dods for electrodes
