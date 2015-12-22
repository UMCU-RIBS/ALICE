%settings

Tthreshold=5;% >  fmri threshold
Dthreshold=6;% distance threshold in mm (<=) --> voxel depth for fmri activation

%% laod files
% load cortex
[cname]=spm_select(1,'mat','select cortex.mat');
load(cname); % cortex

% load surface
[data.sName]=spm_select(1,'image','select image with surface');
s_info=spm_vol(data.sName); [s]=spm_read_vols(s_info);

% load tmap --> NOT A RESLICED TMAP, THAT WILL TAKE TOO MUCH MEMORY
[data.tName]=spm_select(1,'image','select image with tmap');
t_info=spm_vol(data.tName); [t]=spm_read_vols(t_info);

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

% select tmap coordinates that are within X mm of surface
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

%% get coordinates on cortex (instead of surface)
xyztCortex_ind=zeros(length(xyzt),1);
for k=1:length(xyzt)    
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
clear size
ctmr_vox_plot(cortex,xyztCortex,ones(size(t_surf)))
% ctmr_vox_plot(cortex,xyztCortex,t_surf)

% ctmr_vox_plot(cortex,xyzt,t_surf)
% ctmr_vox_plot(cortex,xyzt,ones(size(t_surf)))% more or less the same
% ctmr_vox_plot(cortex,[0 0 0],0);
% el_add(xyztSurf,'r');
% el_add(xyztCortex,'b');
% el_add(xyztCortex,'y'); % Nice!!
view(250,35)

%% only significantly activated electrodes 
% load cortex
% load electrodes on surface
subject='kell';
significant_electrodes = [3 4 76] %count_localizer taak, #3,4,108 of electrodetable, 63 also significant, but interhemispheric
switch subject
    case 'kell'
                load(['/raid/bci/users/mariska/ArtikelFrontalWM/ctmr/kell/data/' subject '_electrodes_surface_loc_all.mat']);
                elecmatrix_significant=elecmatrix(significant_electrodes,:)
end



%% add electrodes on the cortex
load '/raid/bci/users/mariska/ArtikelFrontalWM/ecog/kell/kell_count/workspace/kell211107S002R01_workspace.mat' 
contrast_r2=1;
r2=r2Results(contrast_r2).trialsFreqOI.r2sign;

el_add(elecmatrix,'w',25) % white dods for electrodes
el_add_withr2(elecmatrix_significant,r2,25) % with r2

% load('../data/groo/ct/electrodes_surface_loc_all.mat') % out_els
% load ('../data/groo/ecog/motorduim_tabg.mat')
% % if there are electrodes uner the surface use p_zoom to cortex surface (normal,closest point if within 3 mm)
% % out_els2=p_zoom(out_els, cortex.vert,5,1);
% freq=4;
% r2=-mnewdatar2.r2([1:96 105:128],freq);
% r2(mnewdatar2.p(:,freq)>0.05/120)=0;
% el_add_withr2(elecmatrix,r2,30);
% % use as el_add_withr2(els,r2,size)

%% add angio
img_angio='/raid/bci/subjects/tesfaqergis/mrdata/analysis/angio/tesf290808/ANG_tesf290808_15_1/rANG_tesf290808_15_1-s004-0001.nii';

V=spm_vol(img_angio);
[Data,XYZ]=spm_read_vols(V);

X=zeros(size(Data));
Y=X;
Z=X;
X(:)=XYZ(1,:);
Y(:)=XYZ(2,:);
Z(:)=XYZ(3,:);
clear XYZ;

FV_angio=isosurface(X,Y,Z,Data,100,'verbose');
NFV_angio=reducepatch(FV_angio);
clear FV_angio;

alpha(0.5);
p_angio=patch(NFV_angio);
% settings:
set(p_angio, 'FaceColor', [1 1 0], 'EdgeColor', 'none',...
    'FaceAlpha',1, 'FaceLighting', 'phong');

xlim([round(min(X(:)))-1 round(max(X(:)))+1])
ylim([round(min(Y(:)))-1 round(max(Y(:)))+1])
zlim([round(min(Z(:)))-1 round(max(Z(:)))+1])


