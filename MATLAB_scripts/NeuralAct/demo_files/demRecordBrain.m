%DEMRECORDBRAIN    This script demonstrates how recordBrain can be called.
%
%   See also DEMO, RECORDBRAIN, ACTIVATEBRAIN.

%   Author: Jan Kubanek
%   Institution: Wadsworth Center, NYSDOH, Albany, NY
%   Date: August 2005
%   This procedure is a part of the NeuralAct Matlab package.

load pial_talairach; %the brain model
load DEMOtwosubjs; %two subjects with two different grids
load DEMOtwosubjsvcontribs; %precomputed contribs so that we don't have to wait for this to proceed

viewstruct.what2view = {'brain', 'activations'};
viewstruct.viewvect = [90, 0];
viewstruct.material = 'dull';
viewstruct.enablelight = true;
viewstruct.enablecolormap = true;
viewstruct.lightpos = [200, 0, 0];
viewstruct.lightingtype = 'gouraud';
viewstruct.enableaxis = false;

cmapstruct.cmap = colormap('Jet'); close(gcf); %because colormap creates a figure
cmapstruct.basecol = [0.7, 0.7, 0.7];
cmapstruct.fading = true;
cmapstruct.ixg2 = floor(length(cmapstruct.cmap) * 0.15);
cmapstruct.ixg1 = -cmapstruct.ixg2;
cmapstruct.enablecolormap = true;
cmapstruct.enablecolorbar = false;

%load some interesting activities belonging to the same subject as stored
%in DEMOsubj:
load DEMOactivs; %some demo activations
%use two subjects (this will produce a subject-average activation);
subj(1).activations = activations;
subj(2).activations = 1.7 * activations; %not very creative here: using just scaled activations of the first subject in the second subject

%further possible decoration: to display labels, load also a stimuluscode (see also recordBrain help):
load DEMOstimuluscode;
stimulusstrcell = {'Hand'; 'Shoulder'};

%capture the movie:
cmapstruct.cmin = 0; %colormap ranges
cmapstruct.cmax = 1;
pos = [1, 50]; %position
%pause(5) %might need to be used for switching between Matlab instances if capturing in multiple open Matlab instances
%let's capture frames (vectors) 280 through 310 of the activations matrix
mov = recordBrain( cortex, vcontribs, subj, stimuluscode, stimulusstrcell, 280 : 310, cmapstruct, viewstruct, 'DEMO', pos );
%save mov; %save mov if desired