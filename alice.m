%% ALICE pipeline
% MP Branco et al. 2017
%
% (C) Mariana P. Branco, 
%     July 2017



%%%% Set paths:
close all; clear all; clc;

thisDirectory = pwd;

disp('                                         ');
disp('  ****** Welcome to ALICE ******          ');
disp('         Version July 2017 '                 );
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

%Check dependencies:
spmpath = which('spm');
system(['afni -help > afnipath.txt']);

f = fopen('afnipath.txt');
S = fscanf(f,'%s');

if isempty(spmpath)
    errordlg( 'Please add first SPM 12 to your path.','ERROR!');

elseif isempty(S)
    errordlg( 'Please make sure to add AFNI and SUMA to your bash.','ERROR!');
    
else
    
    delete('afnipath.txt');
    
    %%%% Run program:
    gui = ctmrGUI;
    
end




