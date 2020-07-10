%% ALICE pipeline
% MP Branco et al. 2017
%
% (C) Mariana P. Branco, 
%     June 2019



%%%% Set paths:
close all; clearvars; clc;

thisDirectory = pwd;

disp('                                 ');
disp('  ****** Welcome to ALICE ****** ');
disp('       Version 7 July 2020      ');
disp('   A UMCU and NIH collaboration. ')
disp('                                 ');

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




