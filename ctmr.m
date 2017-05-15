%% 3D-CTMR pipeline
% paper name here
%
% (C) Mariana P. Branco, 
%     May 2017



%%%% Set paths:
close all; clear all; clc;

thisDirectory = pwd;
addpath( genpath( thisDirectory ) );

addpath( '/home/mariana/Documents/MATLAB/Toolboxes/' );

disp('                                         ');
disp(' ****** Welcome to 3D-CTMR ******           ');
disp('         Version May 2017'                 );
disp('   A UMCU and NIH collaboration. ')
disp('                                         ');


%%%% Some global GUI layout settings.
if ispc
	Settings.FontSize		= 8;
	Settings.GridFontSize	= 8;
elseif isunix
	Settings.FontSize		= 7.5;
	Settings.GridFontSize	= 7;
else
	Settings.FontSize		= 8;
	Settings.GridFontSize	= 8;
end


%%%% Run program:
gui = ctmrGUI;





