function ctmr_vox_plot(cortex,xyz,weights)
% function [xyz]=ctmr_gauss_plot(cortex,xyz,weights)
% projects electrode locations onto their cortical spots in the 
% left hemisphere and plots about them using a gaussian kernel
% for only cortex use: 
% ctmr_gauss_plot(cortex,[0 0 0],0)
% rel_dir=which('loc_plot');
% rel_dir((length(rel_dir)-10):length(rel_dir))=[];
% addpath(rel_dir)

%load in colormap
%load('loc_colormap')
cm1=hot(31);
cm2=cool(31);
%cm=[cm2;[0.7 0.7 0.7]; [0.7 0.7 0.7]; cm1];
cm=[cm2;[0.65 0.65 0.65]; [0.65 0.65 0.65]; cm1];

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
gsp=2;%50

c=zeros(length(cortex.vert),1);
for i=1:length(xyz(:,1))
% circles, gsp to 5
%     b_z=abs(brain(:,3)-xyz(i,3));
%     b_y=abs(brain(:,2)-xyz(i,2));
%     b_x=abs(brain(:,1)-xyz(i,1));
%     d=weights(i)*exp((-(b_x.^2+b_z.^2+b_y.^2).^.5)/gsp^.5); %exponential fall off 
%     d=weights(i)*exp((-(b_x.^2+b_z.^2+b_y.^2))/gsp); % gaussian smoothing
% squares, no smoothing
    ssize=2;
    b_z=abs(brain(:,3)-xyz(i,3));
    b_y=abs(brain(:,2)-xyz(i,2));
    b_x=abs(brain(:,1)-xyz(i,1));
    d=b_z<ssize & b_y<ssize & b_x<ssize;
    d=d*weights(i);
    %d=weights(i)*exp((-d)/gsp); % gaussian smoothing
    c=c+d;
end
%%%%%%%%% remove gaussian smoothing?

% c=(c/max(c));
a=tripatch(cortex, '', c);
shading interp;
a=get(gca);
%%NOTE: MAY WANT TO MAKE AXIS THE SAME MAGNITUDE ACROSS ALL COMPONENTS TO REFLECT
%%RELEVANCE OF CHANNEL FOR COMPARISON's ACROSS CORTICES
d=a.CLim;
set(gca,'CLim',[-max(abs(d)) max(abs(d))])
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