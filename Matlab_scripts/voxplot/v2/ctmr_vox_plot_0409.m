function ctmr_vox_plot_0409(cortex,xyz,weights,smoothplot)
% function [xyz]=ctmr_gauss_plot(cortex,xyz,weights,smoothing)
% projects electrode locations onto their cortical spots in the 
% left hemisphere and plots about them using a gaussian kernel
% for only cortex use: 
% ctmr_gauss_plot(cortex,[0 0 0],0)
% rel_dir=which('loc_plot');
% rel_dir((length(rel_dir)-10):length(rel_dir))=[];
% addpath(rel_dir)

%load in colormap
% load('loc_colormap')
%
% cm1=[repmat([1 0 0],100,1)];
% cm1(1:50,1)=[0.7:(1-0.7)/49:1];
% cm1(1:20,2)=[0.7:-0.7/19:0];
% cm1(1:20,3)=[0.7:-0.7/19:0];
% cm1(51:100,2)=[0:0.8/49:0.8];

cm1=[repmat([1 0 0],100,1)];
cm1(1:10,1)=[0.7:(1-0.7)/9:1];
cm1(51:100,1)=[1:-(1-0.7)/49:0.7];
cm1(1:50,2)=[0.7:-0.7/49:0];
cm1(1:10,3)=[0.7:-0.7/9:0];
cm2=cool(100);
cm=[cm2;[0.7 0.7 0.7]; [0.7 0.7 0.7]; cm1];

%
brain=cortex.vert;
v='l';
% %view from which side?
% temp=1;
% while temp==1
%     disp('---------------------------------------')
%     disp('to view from right press ''r''')
%     disp('to view from left press ''l''');
%     v=input('','s');
%     if v=='l'      
%         temp=0;
%     elseif v=='r'      
%         temp=0;
%     else
%         disp('you didn''t press r, or l try again (is caps on?)')
%     end
% end

if length(weights)~=length(xyz(:,1))
    error('you sent a different number of weights than xyz (perhaps a whole matrix instead of vector)')
end

%%%%%%%%% remove gaussian smoothing???
%gaussian "cortical" spreading parameter - in mm, so if set at 10, its 1 cm
%- distance between adjacent xyz
gsp=8;%2 50

% smoothplot=1; % 1 smoothed circles, 2 circles, 0 squares

c=zeros(length(cortex.vert),1);
for k=1:length(xyz(:,1))
    b_z=abs(brain(:,3)-xyz(k,3));
    b_y=abs(brain(:,2)-xyz(k,2));
    b_x=abs(brain(:,1)-xyz(k,1));
    
    if smoothplot==1 % smooth cosine circles
        voxelsm=5;
        d1=(2*pi*((b_x).^2+(b_y).^2+(b_z).^2).^.5)/voxelsm.^2;
        d1(d1>pi/2)=pi/2;
        d=weights(k)*(cos(d1).^2);
%         d=weights(k)*exp((-(b_x.^2+b_z.^2+b_y.^2))/gsp); % gaussian smoothing
       
    elseif smoothplot==2 % circles
        voxelsm=3;
        d1=((b_x).^2+(b_y).^2+(b_z).^2).^.5;
        d=d1<voxelsm;
        d=d*weights(k);
        d(c~=0)=0;%no extra color to overlapping square voxels
    else % squares
        ssize=2;
        d=b_z<ssize & b_y<ssize & b_x<ssize;
        d=d*weights(k); % no smoothing
        d(c~=0)=0;%no extra color to overlapping square voxels
    end

    % d=weights(k)*exp((-(b_x.^2+b_z.^2+b_y.^2).^.5)/gsp^.5); %exponential fall off
    % d=weights(k)*exp((-(b_x.^2+b_z.^2+b_y.^2))/gsp); % gaussian smoothing

    c=c+d;
end

if smoothplot==1 %correct maximum for overlap
    c=(max(weights)/max(c))*c;
end
% c=(c/max(c));
a=tripatch(cortex, '', c);
shading interp;
a=get(gca);
%%NOTE: MAY WANT TO MAKE AXIS THE SAME MAGNITUDE ACROSS ALL COMPONENTS TO REFLECT
%%RELEVANCE OF CHANNEL FOR COMPARISON's ACROSS CORTICES
d=a.CLim;
set(gca,'CLim',[-max(abs(c)) max(abs(c))])
l=light;
colormap(cm)
lighting gouraud; %play with lighting...
% material dull;
material([.3 .8 .1 10 1]);
axis off
set(gcf,'Renderer', 'zbuffer')

if v=='l'
view(270, 0);
%view(-92,32);
set(l,'Position',[-1 0 1])        
elseif v=='r'
view(90, 0);
set(l,'Position',[1 0 1])        
end
% %exportfig
% exportfig(gcf, strcat(cd,'\figout.png'), 'format', 'png', 'Renderer', 'painters', 'Color', 'cmyk', 'Resolution', 600, 'Width', 4, 'Height', 3);
% disp('figure saved as "figout"');