%% ALICE
% MP Branco et al. 2017
%
% (C) Mariana P. Branco, 
%     November 2020



%%%% Set paths:
close all; clearvars; clc;
global ALICE

ALICE.version = 8.1;
ALICE.date    = ' (September 2023)';

disp('                                 ');
disp('  ****** Welcome to ALICE ****** ');
disp(['      Version ' num2str(ALICE.version)  ALICE.date]);
disp('   A UMCU and NIH collaboration ');
disp('                                 ');

%Check dependencies:
spmpath = which('spm');
system('afni -help > afnipath.txt');

f = fopen('afnipath.txt');
S = fscanf(f,'%s');

if isempty(spmpath)
    errordlg( 'Please add first SPM 12 to your path.','ERROR!');

elseif isempty(S)
    errordlg( 'Please make sure to add AFNI and SUMA to your bash.','ERROR!');
    
else
    
    delete('afnipath.txt');
    clear f S spmpath ans;
    
    %%%% Run program:
    gui = ctmrGUI;

end




