function ctmr_gauss_plot_seeg(cortexL, cortexR,electrodes,weights)
% function [electrodes]=ctmr_gauss_plot(cortex,electrodes,weights)
% projects electrode locations onto their cortical spots in the 
% left hemisphere and plots about them using a gaussian kernel
% for only cortex use: 
% ctmr_gauss_plot(cortex,[0 0 0],0)
% rel_dir=which('loc_plot');
% rel_dir((length(rel_dir)-10):length(rel_dir))=[];
% addpath(rel_dir)

%     Copyright (C) 2009  K.J. Miller & D. Hermes, Dept of Neurology and Neurosurgery, University Medical Center Utrecht
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
    
%   Version 1.1.0, released 26-11-2009



%load in colormap
load('loc_colormap');

if length(weights)~=length(electrodes(:,1))
    error('you sent a different number of weights than electrodes (perhaps a whole matrix instead of vector)')
end
%gaussian "cortical" spreading parameter - in mm, so if set at 10, its 1 cm
%- distance between adjacent electrodes
gsp=50;

cL = zeros(1,length(cortexL.vert(:,1)));
cR = zeros(1,length(cortexR.vert(:,1)));

a = tripatch_seeg(cortexL, cortexR, '', cL', cR');
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

