function [] = loggingActions(currdir,stepNumber, ActionString)
%This fucntion logs the the action ActionString in a ActionLog.txt file 
% with time stamps of the action ActionString.
%
% (C) MP Branco, jan2017
%

fID = fopen([currdir 'log_info/Step' num2str(stepNumber) '_log.txt']);

if fID == -1
    % create file if it doesn-t exist
    fID = fopen([currdir 'log_info/Step' num2str(stepNumber) '_log.txt'], 'a');
    % give it a title
    fprintf(fID, '\nAction log of ALICE\n\n');
    fprintf(fID, '---------------------------------------------------------\n\n');
else
    fID = fopen([currdir 'log_info/Step' num2str(stepNumber) '_log.txt'], 'a');
end


% add time stamp
date =  datestr(datetime('now'));

fprintf(fID,date);

% log the action here
fprintf(fID, [ActionString '\n']);

fclose(fID);

end