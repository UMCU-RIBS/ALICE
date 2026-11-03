%DEMO   NeuralAct demo

%%
%   See also PROJECTELECTRODES, ELECTRODESCONTRIBUTIONS, ACTIVATEBRAIN, COARSERMODEL, SMOOTHMODEL, HULLMODEL, DEMRECORDBRAIN, RECORDBRAIN.
%
%
%% The NeuralAct demo
% This demo shows how to use the NeuralAct package functions to display neural activations on a brain model.
% To display activations, the following data are needed:
%
% * brain model (in this demo - |pial_talairach.mat|)
%
% * electrode locations for desired subjects (|DEMOsubj.mat|)
%
% * activation data for these electrodes (|DEMOsubj.mat|)
%
%Briefly, this demo proceeds as follows:
%
% * flatten the brain model (|coarserModel, smoothModel, hullModel|)
%
% * project the electrodes on the flattened model (|projectElectrodes|)
%
% * reload the dense brain model (|pial_talairach.mat|)
%
% * compute the electrode contributions ("impact multipliers") to the associated brain's surface areas (|electrodesContributions|)
%
% * display the activations (|NeuralAct|)
%
% * capture a demo activation sequence into an .avi file (|recordBrain|)
%
%   Author: Jan Kubanek
%   Institution: Wadsworth Center, NYSDOH, Albany, NY
%   Date: August 2005
%   This procedure is a part of the NeuralAct Matlab package.



%Set path:
addpath(genpath(cd));

%% Preprocess the brain model
%A brain model must be first flattened, i.e. deprived of its sulci;
%otherwise, some electrodes of subjects' electrode grids would project into
%the sulci - which would create an uneven distribution of the electrodes;
%thus, the electrode grid would be deformed by the projection, creating
%artifacts when visualizing the activations.
%A brain model is first made coarser by using the |coarserModel| function.
%It is to be used for the computation of the electrode projections; there
%will be almost no difference in respect of the projected electrodes
%between a very dense or a coarse brain model; however, the desired shape of the model
%should be maintained (if the reduction is excessive, the model "shrinks").
%Further, the brain model might or might not be smoothed by using the
%|smoothModel| function.
%Finally, the brain model should be flattened by |hullModel|.

%Thus, two major approaches are used to flatten a brain model:
%
% * make the model coarser and compute its convex hull (approach A)
% * make the model coarser, smooth it and compute its convex hull (approach B)
% 
%Which of the two approaches should be used depends on the location
%of the electrodes - i.e. on the way they are implanted and on subjective
%brain proportions.
%The approach B maintains a better shape of the brain but the electrodes
%are projected slightly underneath the convex hull (not exactly on the level
%of sulci but a little underneath) - it is because the smoothing slightly
%shrinks the model used for the projection.
%
%In both cases:
% * reduce the model to about 10000 triangles
%(the reduction is also
% necessary for |smoothModel|(approach B) so that it can terminate in a
% reasonable amount of time)

%load the SUMA talairach brain:
load pial_talairach;
%this creates a variable cortex

%make the model coarser:
cortexcoarser = coarserModel(cortex, 10000);

%*Approach A*
%compute the convex hull:
cortex = hullModel(cortexcoarser);
%this deprives the brain model of its sulci

%Forget the results of Approach A and use the results of
%*Approach B*
%use the coarse model and make it smoother:
origin = [0 20 40];
smoothrad = 25;
mult = 0.5;
%(see also |smoothModel| for further information on the arguments used)
[cortexsmoothed] = smoothModel(cortexcoarser, smoothrad, origin, mult);

%compute the convex hull:
cortex = hullModel(cortexsmoothed);
%this deprives the brain model of the sulci

%% Specify the electrode grids
%The electrode grids for each subject are specified by the structure
%|struct('electrodes', Nsubjx3matrix)|

%load a subject with 32 electrode positions and some activations
load DEMOsubj;

%DEMOtwosubjs loads a structure field (two subjects) with similar overlaying
%electrode grids in 
%order to explore the averaging capability of NeuralAct.
%This is used in the movie-capturing part invoked at the very bottom of this
%script

%% View the brain and electrode locations
%look at that brain and the electrode grids, using viewBrain:
%(see also |viewBrain|)
clf; set(gca, 'Color', 'none'); set(gcf, 'Color', 'w'); grid on;
viewBrain(cortex, subj, {'brain', 'electrodes'}, 0.7, 32, [110,20]);
title('Flattened brain model and electrode locations');


%% Project the electrodes
%project the electrodes onto the surface of the brain:
normdist = 25;
%(using the normal vector projection; the normal vector is computed by
%averaging the normal vectors at the electrode distance normdist and less;
%see also |projectElectrodes| for a more thorough information on its arguments)
[ subj ] = projectElectrodes( cortex, subj, normdist);


%You might want to save the computed electrodes projections so that this
%does need to be done again in the future - so that you do not need to
%recompute the electrode positions each time you want to change the
%|electrodesContributions| contribution kernel function or its parameters.
%save DEMOsubj.mat subj;

%look at that brain and the projected electrode grids, using viewBrain again:
figure; set(gca, 'Color', 'none'); set(gcf, 'Color', 'w'); grid on;
viewBrain(cortex, subj, {'brain', 'electrodes', 'trielectrodes'}, 0.7, 32, [190,0]);
title('Flattened brain model, original electrodes and projected electrodes');


%% Compute the electrode contributions
%One should be using the fine brain again for the computation of the
%electrode contribution (because the final visualization |NeuralAct|
%will be using this model).

%reload the original SUMA talairach brain:
load pial_talairach;
%pial_talairachRED would also do (uses half of triangles - which is usefull
%when visualizing the brain or capturing an .avi movie

%compute the contributions of the given electrodes:
kernel = 'linear';
param = 10;
cutoff = 10;
%see also |electrodesContributions| for a more thorough information on its arguments)
[ vcontribs ] = electrodesContributions( cortex, subj, kernel, param, cutoff);
%param should be set to the interelectrode distance
%cut-off: only those vertices vert whose distance(vert, electrode) < cuf-off are considered to be altered by a near electrode (the more distant ones will not be displayed by NeuralAct)
%   if you want to define a value of 0 for all vertices spanned by the
%   electode grid, then use a larger cutoff (the triangles will be taken into
%   account and so displayed but their value will be 0 since param for the
%   linear kernel specifies the distance at which the activations falls to
%   zero)

%Can save the contributions for this subject and brain so that this
%doesn't need to be done gain (but remember to use the according subj structure and
%brain model when visualizing the data).

%save DEMOvcontribs.mat vcontribs;

%% Visualize the activations
%Set what you want to see:
%(consult |NeuralAct| for further information)
viewstruct.what2view = {'brain', 'activations'};
viewstruct.viewvect = [120, 10];
viewstruct.material = 'dull';
viewstruct.enablelight = 1;
viewstruct.enableaxis = 0;
viewstruct.lightpos = [200, 0, 0];
viewstruct.lightingtype = 'gouraud';

%... and how you want to see it:
cmapstruct.cmap = colormap('Jet'); close(gcf); %because colormap creates a figure
cmapstruct.basecol = [0.7, 0.7, 0.7];
cmapstruct.fading = true;
cmapstruct.ixg2 = floor(length(cmapstruct.cmap) * 0.15);
cmapstruct.ixg1 = -cmapstruct.ixg2;
cmapstruct.enablecolormap = true;
cmapstruct.enablecolorbar = true;

%Run |NeuralAct|:
%NOTE:
%Use the same brain model as the one used for the computation of the contributions (i.e., a fine one).
%Also, use the subj variable that is the output of |projectElectrodes|).

%visualize:
cmapstruct.fading = true;
cmapstruct.cmin = 0;
cmapstruct.cmax = 1;
clf; set(gca, 'Color', 'none'); set(gcf, 'Color', 'w'); grid off;
NeuralAct( cortex, vcontribs, subj, 1, cmapstruct, viewstruct );
title('DEMO activations');

%can also add electrode locations, and electrode numbers
%plotSpheres(subj.electrodes, 'r');
%plotElNums(subj.electrodes);



%% Capture a movie
%Capture activations into an .avi file, using
%the |recordBrain| function. This function is called by the script |demRecordBrain|.
pause(5);
figure;
demRecordBrain;