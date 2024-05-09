classdef ctmrGUI < handle
    properties
        mainFig
        extraFig
        controls
        settings
        alice_version
    end


    methods

        function obj = ctmrGUI
            % Create main window.
            width		= 1010; %increase
            height		= 750;
            frameheight = 200;

            global ALICE
            obj.alice_version = ALICE.version;

            %number lines in action log.
            obj.settings.NUM_LINES = 8;

            %no files loaded.
            obj.settings.loaded = [0 0 0 0];

            %initial values for 3dclustering
            obj.settings.CV = 3999;
            obj.settings.R  = 3;
            obj.settings.IS = 1;

            %empty hemisphere:
            obj.settings.Hemisphere = cell(1,3);

            %empty method:
            obj.settings.Method = cell(1,3);

            %empty subject name:
            obj.settings.subject = [];

            %empty lay9ut/grid settings:
            obj.settings.Layout  = cell(1,3);
            obj.settings.Tabnum  = 1;
            obj.settings.Grids   = [];
            obj.settings.Gridnum = 0;

            %current number lines in action log
            obj.settings.curr_num_lines = 0;

            %by default do not save nii files
            obj.settings.saveNii = 0;

            % Get screen size.
            screenSize = get(0,'ScreenSize');

            % Starting point of each frame.
            startingPointFrame = [10 round(width/3)+5 2*round(width/3)];

            % Main window
            windowPosition = [ round((screenSize(3)-width)/5), screenSize(4)-height-100, width, height+80];
            obj.mainFig = figure( 'Name', 'ALICE','OuterPosition', windowPosition, 'Menu', 'none', ...
                'NumberTitle', 'off', 'Color', get(0,'DefaultUIControlBackgroundColor'), 'Resize', 'off', 'CloseRequestFcn', @obj.figCloseRequest );

            %two buttons for create directory or locate directory:
            obj.controls.btnCreateDirectory = uicontrol( 'Parent', obj.mainFig, 'Style', 'pushbutton', 'Position', [295 718+36 200 35], ...
                'String', 'Create Directory', 'Callback', @obj.btnCreateDirectory, 'FontSize', 11 , 'FontWeight', 'bold');

            obj.controls.btnLocateDirectory = uicontrol( 'Parent', obj.mainFig, 'Style', 'pushbutton', 'Position', [505 718+36 200 35], ...
                'String', 'Locate Directory', 'Callback', @obj.btnLocateDirectory, 'FontSize', 11 , 'FontWeight', 'bold');

            %Frame 1
            obj.controls.frame1 = uipanel( 'Parent', obj.mainFig, 'Units', 'pixels', 'Position', [startingPointFrame(1) frameheight+40 round(width/3)-20 height-250], ...
                'Title', '1. CT-MR Co-registration', 'FontSize', 12,'Visible', 'off', 'FontWeight', 'bold', 'BorderType', 'line', 'HighlightColor', [.5 .5 .5] );

            %Frame 2
            obj.controls.frame2 = uipanel( 'Parent', obj.mainFig, 'Units', 'pixels', 'Position', [startingPointFrame(2) frameheight+40 round(width/3)-20 height-250], ...
                'Title', '2. Electrode Selection', 'FontSize', 12, 'Visible', 'off','FontWeight', 'bold', 'BorderType', 'line', 'HighlightColor', [.5 .5 .5] );

            %Frame 3
            obj.controls.frame3 = uipanel( 'Parent', obj.mainFig, 'Units', 'pixels', 'Position', [startingPointFrame(3) frameheight+40 round(width/3)-20 height-250], ...
                'Title', '3. Electrode Projection', 'FontSize', 12,'Visible', 'off', 'FontWeight', 'bold', 'BorderType', 'line', 'HighlightColor', [.5 .5 .5] );

            %% Inside frame 1:
            % SubFrame 1 inside frame 1
            obj.controls.subframe1 = uipanel( 'Parent', obj.controls.frame1, 'Units', 'pixels', 'Position', [10 360 293 100], ...
                'Title', 'Select MRI scan from FS folder', 'FontSize', 10, 'FontWeight', 'bold', 'BorderType', 'line', 'HighlightColor', [0.8 .8 .8] );

            % SubFrame 2 inside frame 1
            obj.controls.subframe2 = uipanel( 'Parent', obj.controls.frame1, 'Units', 'pixels', 'Position', [10 240 293 100], ...
                'Title', 'Select FreeSurfer segmentation', 'FontSize', 10, 'FontWeight', 'bold', 'BorderType', 'line', 'HighlightColor', [0.8 .8 .8] );

            % SubFrame 3 inside frame 1
            obj.controls.subframe3 = uipanel( 'Parent', obj.controls.frame1, 'Units', 'pixels', 'Position', [10 120 293 100], ...
                'Title', 'Select CT scan', 'FontSize', 10, 'FontWeight', 'bold', 'BorderType', 'line', 'HighlightColor', [0.8 .8 .8] );

            % Button 1 inside frame 1
            obj.controls.btnAlignCTtoMRI = uicontrol( 'Parent', obj.controls.frame1, 'Style', 'pushbutton', 'Position', [10 35 140 50], ...
                'String', 'Align CT to MRI', 'Callback', @obj.btnAlignCTtoMRI, 'FontSize', 9, 'FontWeight', 'bold' );


            % Button 2 inside frame 1
            obj.controls.btnAlreadyAligned = uicontrol( 'Parent', obj.controls.frame1, 'Style', 'pushbutton', 'Position', [163 35 140 50], ...
                'String', 'CT already aligned', 'Callback', @obj.btnAlreadyAligned, 'FontSize', 9, 'FontWeight', 'bold' );

            %% Inside frame 2:
            % SubFrame 1 inside frame 2
            obj.controls.subframe4 = uipanel( 'Parent', obj.controls.frame2, 'Units', 'pixels', 'Position', [10 360 293 100], ...
                'Title', 'Select file with electrode labels', 'FontSize', 10, 'FontWeight', 'bold', 'BorderType', 'line', 'HighlightColor', [0.8 .8 .8] );

            % SubFrame 2 inside frame 2
            obj.controls.subframe5 = uipanel( 'Parent', obj.controls.frame2, 'Units', 'pixels', 'Position', [10 120 293 220], ...
                'Title', '3D-Clustering settings', 'FontSize', 10, 'FontWeight', 'bold', 'BorderType', 'line', 'HighlightColor', [0.8 .8 .8] );

            % Button 1 inside frame 2
            obj.controls.btnExtractClusters = uicontrol( 'Parent', obj.controls.frame2, 'Style', 'pushbutton', 'Position', [10 35 140 50], ...
                'String', 'Extract Clusters', 'Callback', @obj.btnExtractClusters, 'FontSize', 9 , 'FontWeight', 'bold');

            % Button 2 inside frame 2
            obj.controls.btnSelectElectrodes = uicontrol( 'Parent', obj.controls.frame2, 'Style', 'pushbutton', 'Position', [163 35 140 50], ...
                'String', 'Select Electrodes', 'Callback', @obj.btnSelectElectrodes, 'FontSize', 9 , 'FontWeight', 'bold');


            %% Inside frame 3:
            % SubFrame 1 inside frame 3
            obj.controls.subframe6 = uipanel( 'Parent', obj.controls.frame3, 'Units', 'pixels', 'Position', [10 120 293 340], ...
                'Title', 'Select Projection Method', 'FontSize', 10, 'FontWeight', 'bold', 'BorderType', 'line', 'HighlightColor', [0.8 .8 .8] );

            % Checkbox inside frame 3
            obj.controls.checkBoxSaveNii = uicontrol( 'Parent', obj.controls.frame3, 'Style', 'checkbox', 'Position', [109 35+55 140 20], ...
                'String', 'Save Nifti files', 'Callback', @obj.checkBoxSaveNii, 'FontSize', 8 , 'FontWeight', 'normal');

            % Button 1 inside frame 3
            obj.controls.btnVisualize = uicontrol( 'Parent', obj.controls.frame3, 'Style', 'pushbutton', 'Position', [90 35 140 50], ...
                'String', 'Visualize!', 'Callback', @obj.btnVisualize, 'FontSize', 9 , 'FontWeight', 'bold');


            %% Inside Subframe 1 - frame 1
            % Button 1 inside subframe 1
            obj.controls.btnOpenMRI = uicontrol( 'Parent', obj.controls.subframe1, 'Style', 'pushbutton', 'Position', [10 25 100 40], ...
                'String', 'Open', 'Callback', @obj.btnOpenMRI, 'FontSize', 9 , 'FontWeight', 'bold');

            % text box inside subframe 1
            obj.controls.txtMRI = uicontrol( 'Parent', obj.controls.subframe1, 'Style', 'edit', 'Position', [115 26 168 36], ...
                'FontSize', 7, 'string', {' (.../FreeSurfer/mri/T1.mgz)'} , 'HorizontalAlignment', 'left', 'BackgroundColor', 'w' ,'enable','inactive');

            %% Inside subframe 2 - frame 1
            % Button 1 inside subframe 2
            obj.controls.btnOpenFS = uicontrol( 'Parent', obj.controls.subframe2, 'Style', 'pushbutton', 'Position', [10 25 100 40], ...
                'String', 'Open', 'Callback', @obj.btnOpenFS, 'FontSize', 9 , 'FontWeight', 'bold');

            % text box inside subframe 2
            obj.controls.txtFS= uicontrol( 'Parent', obj.controls.subframe2, 'Style', 'edit', 'Position', [115 26 168 36], ...
                'FontSize',7, 'string', {' (.../FreeSurfer/mri/ribbon.mgz)'} , 'HorizontalAlignment', 'left', 'BackgroundColor', 'w' ,'enable','inactive');


            %% Inside subframe 3 - frame 1
            % Button 1 inside subframe 3
            obj.controls.btnOpenCT1 = uicontrol( 'Parent', obj.controls.subframe3, 'Style', 'pushbutton', 'Position', [10 25 100 40], ...
                'String', 'Open', 'Callback', @obj.btnOpenCT1, 'FontSize', 9 , 'FontWeight', 'bold');

            % text box inside subframe 3
            obj.controls.txtCT1= uicontrol( 'Parent', obj.controls.subframe3, 'Style', 'edit', 'Position', [115 26 168 36], ...
                'FontSize', 7, 'string', {' (.../*.nii)'} , 'HorizontalAlignment', 'left', 'BackgroundColor', 'w' ,'enable','inactive');


            %% Inside subframe 4 - frame 2

            % text box inside subframe 4
            obj.controls.txtLabels = uicontrol( 'Parent', obj.controls.subframe4, 'Style', 'edit', 'Position', [115 26 168 36], ...
                'FontSize',7, 'string', {' (.../*.txt)'} , 'HorizontalAlignment', 'left', 'BackgroundColor', 'w' ,'enable','inactive');

            % Button 1 inside subframe 4
            obj.controls.btnOpenLabels = uicontrol( 'Parent', obj.controls.subframe4, 'Style', 'pushbutton', 'Position', [10 25 100 40], ...
                'String', 'Open', 'Callback', @obj.btnOpenLabels, 'FontSize', 9 , 'FontWeight', 'bold');

            %% Inside subframe 5 - frame 3
            %text box
            obj.controls.txtCV = uicontrol( 'Parent', obj.controls.subframe5, 'Style', 'text', 'Position', [10 145 213 25], ...
                'FontSize', 10, 'string', {'Electrode max. intensity (-5)'} , 'HorizontalAlignment', 'left','enable','inactive');

            %edit text box
            obj.controls.edtCV = uicontrol( 'Parent', obj.controls.subframe5, 'Style', 'edit', 'Position', [223 145 60 36], ...
                'FontSize', 10, 'string', {'3999'} ,'Callback', @obj.edtCV,  'HorizontalAlignment', 'center', 'BackgroundColor', 'w' ,'enable','on');

            %text box
            obj.controls.txtR = uicontrol( 'Parent', obj.controls.subframe5, 'Style', 'text', 'Position', [10 85 213 25], ...
                'FontSize', 10, 'string', {'Electrode volume (e.g., 3)'} , 'HorizontalAlignment', 'left','enable','inactive');

            %edit text box
            obj.controls.edtR = uicontrol( 'Parent', obj.controls.subframe5, 'Style', 'edit', 'Position', [223 85 60 36], ...
                'FontSize', 10, 'string', {'3'} , 'Callback', @obj.edtR, 'HorizontalAlignment', 'center', 'BackgroundColor', 'w' ,'enable','on');

            %text box
            obj.controls.txtIS = uicontrol( 'Parent', obj.controls.subframe5, 'Style', 'text', 'Position', [10 25 213 25], ...
                'FontSize', 10, 'string', {'Interelectrode space (e.g., 1)'} , 'HorizontalAlignment', 'left','enable','inactive');

            %edit text box
            obj.controls.edtIS = uicontrol( 'Parent', obj.controls.subframe5, 'Style', 'edit', 'Position', [223 25 60 36], ...
                'FontSize', 10, 'string', {'1'} , 'Callback', @obj.edtIS, 'HorizontalAlignment', 'center', 'BackgroundColor', 'w' ,'enable','on');


            %% Inside subframe 6 - frame 3
            %select a method
            obj.controls.Methods = uibuttongroup('Parent', obj.controls.subframe6, 'Visible', 'on', 'SelectionChangedFcn', @obj.radiobtnSelectionMethod, 'Position', [0 0.66 1 0.5], 'Bordertype', 'none');

            obj.controls.radiobtn1 = uicontrol( obj.controls.Methods, 'Style', 'radiobutton', 'Position', [20 75 230 25], ...
                'FontSize', 10, 'string', 'Method 1 (Hermes et al. 2010)' ,'HandleVisibility','off', 'HorizontalAlignment', 'left','enable','on');
            obj.controls.radiobtn1.Value = 0;

            obj.controls.radiobtn2 = uicontrol( obj.controls.Methods, 'Style', 'radiobutton', 'Position', [20 55 230 25], ...
                'FontSize', 10, 'string', 'Method HD' ,'HandleVisibility','off', 'HorizontalAlignment', 'left','enable','on');
            obj.controls.radiobtn2.Value = 0;

            obj.controls.radiobtn5 = uicontrol( obj.controls.Methods, 'Style', 'radiobutton', 'Position', [20 35 230 25], ...
                'FontSize', 10, 'string', 'Method sEEG or depth' ,'HandleVisibility','off', 'HorizontalAlignment', 'left','enable','on');
            obj.controls.radiobtn5.Value = 0;

            %enter subject name:
            %text box
            obj.controls.txtSbjName = uicontrol( obj.controls.subframe6, 'Style', 'text', 'Position', [10 205-10 150 40], ...
                'FontSize', 10, 'string', {'Subject Name:'} , 'FontWeight', 'bold','HorizontalAlignment', 'left','enable','inactive');
            %edit text box
            obj.controls.edtSbjName =  uicontrol( 'Parent', obj.controls.subframe6, 'Style', 'edit', 'Position', [130 224-10 155 25], ...
                'FontSize', 8, 'string','name...' , 'HorizontalAlignment', 'center', 'BackgroundColor', 'w' ,'enable','on');

            %select an hemisphere
            obj.controls.Hemisphere = uibuttongroup('Parent', obj.controls.subframe6, 'Visible', 'on', 'SelectionChangedFcn', ...
                @obj.radiobtnSelectionHemisphere,'Position', [0 0.33 1 0.33],'Bordertype', 'none');

            % text box select hemisphere
            obj.controls.txtHemisphere = uicontrol( obj.controls.Hemisphere, 'Style', 'text', 'Position', [10 60-5 150 40], ...
                'FontSize', 10, 'string', {'Implanted hemisphere:'} , 'FontWeight', 'bold','HorizontalAlignment', 'left','enable','inactive');

            %radio button 3
            obj.controls.radiobtn3 = uicontrol( obj.controls.Hemisphere, 'Style', 'radiobutton', 'Position', [120-2 75-5 230 25], ...
                'FontSize', 10, 'string', 'Left' ,'HandleVisibility','off', 'HorizontalAlignment', 'left','enable','on');
            obj.controls.radiobtn3.Value = 0;

            %radio button 4
            obj.controls.radiobtn4 = uicontrol( obj.controls.Hemisphere, 'Style', 'radiobutton', 'Position', [175-1 75-5 230 25], ...
                'FontSize', 10, 'string', 'Right' ,'HandleVisibility','off', 'HorizontalAlignment', 'left','enable','on');
            obj.controls.radiobtn4.Value = 0;

            %radio button 6
            obj.controls.radiobtn6 = uicontrol( obj.controls.Hemisphere, 'Style', 'radiobutton', 'Position', [238-2 75-5 230 25], ...
                'FontSize', 10, 'string', 'Both' ,'HandleVisibility','off', 'HorizontalAlignment', 'left','enable','on');
            obj.controls.radiobtn6.Value = 0;

            % Tab group for each scheme
            obj.controls.layout = uitabgroup('Parent', obj.controls.subframe6, 'Visible', 'on', 'SelectionChangedFcn', @obj.tabSelectScheme,...
                'Position', [0.02 0.02 0.97 0.45], 'TabLocation', 'Top');

            % Tab 1
            obj.controls.tab(1) = uitab( obj.controls.layout, 'Title', 'Layout 1', 'HandleVisibility','off');

            % Add tab
            obj.controls.addTab = uicontrol( 'Parent', obj.controls.subframe6, 'Style', 'pushbutton', 'Position', [243 132 22 22], ...
                'String', '+', 'Callback', @obj.btnAddTab, 'FontSize', 12 , 'FontWeight', 'bold','Enable', 'off');

            % remove tab
            obj.controls.removeTab = uicontrol( 'Parent', obj.controls.subframe6, 'Style', 'pushbutton', 'Position', [267 132 22 22], ...
                'String', '-', 'Callback', @obj.btnRemoveTab, 'FontSize', 16, 'Enable', 'off' );

            %% set grid settings:
            %text box
            obj.controls.txtGrid1(1) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'text', 'Position', [10 93 230 20], ...
                'FontSize', 10, 'string', {'Grid settings:'} , 'FontWeight', 'bold', 'HorizontalAlignment', 'left','enable','inactive');

            %text box label
            obj.controls.txtGrid2(1) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'text', 'Position', [10+40 70 80 15], ...
                'FontSize', 10, 'string', {'Label'} , 'HorizontalAlignment', 'center','enable','inactive');

            %edit text box label
            obj.controls.edtGrid2(1) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'edit', 'Position', [10+40 35 80 36], ...
                'FontSize', 8, 'string','e.g.: C' , 'HorizontalAlignment', 'center', 'BackgroundColor', 'w' ,'enable','on');

            %text box grid size
            obj.controls.txtGrid4(1) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'text', 'Position', [190-40 70 80 15], ...
                'FontSize', 10, 'string', {'Size'} , 'HorizontalAlignment', 'center','enable','inactive');

            %edit text box grid size
            obj.controls.edtGrid4(1) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'edit', 'Position', [190-40 35 80 36], ...
                'FontSize', 8, 'string','e.g.: 4, 8' , 'HorizontalAlignment', 'center', 'BackgroundColor', 'w' ,'enable','on');


            % Add grid
            obj.controls.addGrid(1) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'pushbutton', 'Position', [120 7 22 22], ...
                'String', '+', 'Callback', @obj.btnAddGrid, 'FontSize', 12 , 'FontWeight', 'bold');

            % remove grid
            obj.controls.removeGrid(1) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'pushbutton', 'Position', [150 7 22 22], ...
                'String', '-', 'Callback', @obj.btnRemoveGrid, 'FontSize', 16,'Enable','off' );

            % previous grid
            obj.controls.previousGrid(1) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'pushbutton', 'Position', [90 7 22 22], ...
                'String', '<', 'Callback', @obj.btnPreviousGrid, 'FontSize', 11 , 'FontWeight', 'bold', 'Enable', 'off');

            % next grid
            obj.controls.nextGrid(1) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'pushbutton', 'Position', [180 7 22 22], ...
                'String', '>', 'Callback', @obj.btnNextGrid, 'FontSize', 11 , 'FontWeight', 'bold', 'Enable', 'off');


            %% Logging frame
            obj.controls.logframe = uipanel( 'Parent', obj.mainFig, 'Units', 'pixels', 'Position', [10 10 980 frameheight-20+40], ...
                'Title', 'Action Log:', 'FontSize', 12, 'FontWeight', 'bold', 'BorderType', 'line', 'HighlightColor', [.5 .5 .5] );

            % Inside the Logging frame:
            % text box
            obj.controls.txtLog = uicontrol( 'Parent', obj.controls.logframe, 'Style', 'text','max',2, 'Position', [10 10 960 145+40], ...
                'FontSize', 10, 'string', {'> Welcome to ALICE!', '> Please create a directory to start ALICE from scratch, or locate the existing directory.'}, 'HorizontalAlignment', 'left', 'BackgroundColor', 'w' ,'enable','inactive');

        end

        function CreateDirectory( obj )

            obj.settings.originaldir = [pwd '/'];
            obj.settings.scriptspath  = [fileparts( mfilename('fullpath') ) '/'];

            if exist([pwd '/ALICE'])==7
                errordlg('A folder named ALICE already exists. Please choose another directory or rename the existing folder.');

            else
                %make panels visible
                set(obj.controls.frame1,'Visible', 'on');
                set(obj.controls.frame2,'Visible', 'on');
                set(obj.controls.frame3,'Visible', 'on');

                %create directories
                mkdir('ALICE');
                fileattrib ./ALICE +w g
                cd ./ALICE;
                obj.settings.currdir = [pwd '/'];
                mkdir('log_info');
                %data folder
                mkdir('data');
                cd ./data;
                mkdir('3Dclustering');
                mkdir('CT');
                mkdir('coregistration')
                mkdir('MRI');
                mkdir('FreeSurfer');
                cd(obj.settings.currdir);
                %locate matlab scripts
                addpath(genpath([ obj.settings.scriptspath 'MATLAB_scripts']));
                %locate afni scripts
                cd(obj.settings.currdir);
                copyfile([obj.settings.scriptspath 'AFNI_scripts' '/alignCTtoT1_shft_res.csh'], [obj.settings.currdir 'data/coregistration/']);
                copyfile([obj.settings.scriptspath 'AFNI_scripts' '/3dclustering.csh'], [obj.settings.currdir 'data/3Dclustering/']);
                copyfile([obj.settings.scriptspath 'AFNI_scripts' '/select_electrode.csh'], [obj.settings.currdir 'data/3Dclustering/']);
                copyfile([obj.settings.scriptspath 'AFNI_scripts' '/open_afni_suma.csh'], [obj.settings.currdir 'data/3Dclustering/']);
                copyfile([obj.settings.scriptspath 'AFNI_scripts' '/indexify_electrodes.csh'], [obj.settings.currdir 'data/3Dclustering/']);
                copyfile([obj.settings.scriptspath 'AFNI_scripts' '/delete_cluster.csh'], [obj.settings.currdir 'data/3Dclustering/']);

                cd(obj.settings.currdir);
                addpath(genpath(obj.settings.currdir));
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> ALICE successfully created. Please proceed to Step 1.'});
                loggingActions(obj.settings.currdir,1,' > ALICE successfully created. Please proceed to Step 1.');
            end
        end

        function LocateDirectory( obj )

            folderName = uigetdir('.', 'Please locate ALICE folder.');

            if sum(folderName)~=0 && strcmp(folderName(end-4:end), 'ALICE')

                %make panels visible
                set(obj.controls.frame1,'Visible', 'on');
                set(obj.controls.frame2,'Visible', 'on');
                set(obj.controls.frame3,'Visible', 'on');

                obj.settings.currdir = [folderName '/'];
                cd(folderName);

                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> ALICE directory located: ' obj.settings.currdir],'> Please proceed to Step 1.'});
                loggingActions(obj.settings.currdir,1,[' > ALICE directory located: ' obj.settings.currdir]);
                loggingActions(obj.settings.currdir,1,' > Please proceed to Step 1.');

                if exist([obj.settings.currdir '/log_info/settings.mat'])==2

                    oldsettings          = load([obj.settings.currdir '/log_info/settings.mat']);
                    obj.settings         = oldsettings.settings;
                    obj.settings.currdir = [folderName '/'];

                    %check for version differences:
                    if ~isfield(obj.settings,'version') || obj.settings.version < 6.5
                        obj.settings.version = obj.alice_version;
                        %add new fields
                        if ~isempty(obj.settings.Grids)
                            obj.settings.Layout{1}  = obj.settings.Grids;
                            obj.settings.Grids      = [];
                        else
                            obj.settings.Layout     = cell(1,3);
                        end
                        obj.settings.Tabnum  = 1;
                        obj.settings.Gridnum = 0;
                    end

                    %check if older version has not method/hemisphere per
                    %layout
                    %todo
                    if ~iscell(obj.settings.Hemisphere)
                        obj.settings.Hemisphere = {obj.settings.Hemisphere [] []};
                    end
                    if ~iscell(obj.settings.Method)
                        obj.settings.Method = {obj.settings.Hemisphere [] []};
                    end

                    try
                        set(obj.controls.edtCV, 'String',obj.settings.CV);
                        set(obj.controls.edtR, 'String',obj.settings.R);
                        set(obj.controls.edtIS, 'String',obj.settings.IS);
                        set(obj.controls.checkBoxSaveNii, 'value', obj.settings.saveNii);
                    end

                    try
                        set(obj.controls.edtSbjName, 'String',obj.settings.subject);
                    end

                    %delete tab if exist:
                    try
                        for t2 = length(obj.controls.tab):-1:1
                            obj.controls.tab(t2).Parent    = [];
                            obj.controls.tab(t2)           = [];
                            obj.controls.nextGrid(t2)      = [];
                            obj.controls.previousGrid(t2)  = [];
                            obj.controls.addGrid(t2)       = [];
                            obj.controls.removeGrid(t2)    = [];
                            obj.controls.edtGrid2(t2)      = [];                            
                            obj.controls.edtGrid4(t2)      = [];
                            obj.controls.txtGrid1(t2)      = [];
                            obj.controls.txtGrid2(t2)      = [];
                            obj.controls.txtGrid4(t2)      = [];
                        end
                    end

                    %add new tabs
                    for t = 1:length(obj.settings.Layout)

                        if ~isempty(obj.settings.Layout{t}) || t==1

                            obj.controls.tab(t) = uitab( obj.controls.layout, 'Title', ['Layout ' num2str(t)], 'HandleVisibility','off');

                            %add elements inside tab
                            obj.controls.txtGrid1(t) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'text', 'Position', [10 93 230 20], ...
                                'FontSize', 10, 'string', {'Grid settings:'} , 'FontWeight', 'bold', 'HorizontalAlignment', 'left','enable','inactive');

                            %text box label
                            obj.controls.txtGrid2(t) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'text', 'Position', [10+40 70 80 15], ...
                                'FontSize', 10, 'string', {'Label'} , 'HorizontalAlignment', 'center','enable','inactive');

                            %edit text box label
                            obj.controls.edtGrid2(t) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'edit', 'Position', [10+40 35 80 36], ...
                                'FontSize', 8, 'string','e.g.: C' , 'HorizontalAlignment', 'center', 'BackgroundColor', 'w' ,'enable','on');
                            
                            %text box grid size
                            obj.controls.txtGrid4(t) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'text', 'Position', [190-40 70 80 15], ...
                                'FontSize', 10, 'string', {'Size'} , 'HorizontalAlignment', 'center','enable','inactive');

                            %edit text box grid size
                            obj.controls.edtGrid4(t) = uicontrol( 'Parent', obj.controls.tab(1), 'Style', 'edit', 'Position', [190-40 35 80 36], ...
                                'FontSize', 8, 'string','e.g.: 4, 8' , 'HorizontalAlignment', 'center', 'BackgroundColor', 'w' ,'enable','on');

                            % Add grid
                            obj.controls.addGrid(t) = uicontrol( 'Parent', obj.controls.tab(t), 'Style', 'pushbutton', 'Position', [120 7 22 22], ...
                                'String', '+', 'Callback', @obj.btnAddGrid, 'FontSize', 12 , 'FontWeight', 'bold');

                            % remove grid
                            obj.controls.removeGrid(t) = uicontrol( 'Parent', obj.controls.tab(t), 'Style', 'pushbutton', 'Position', [150 7 22 22], ...
                                'String', '-', 'Callback', @obj.btnRemoveGrid, 'FontSize', 16,'Enable','off' );

                            % previous grid
                            obj.controls.previousGrid(t) = uicontrol( 'Parent', obj.controls.tab(t), 'Style', 'pushbutton', 'Position', [90 7 22 22], ...
                                'String', '<', 'Callback', @obj.btnPreviousGrid, 'FontSize', 11 , 'FontWeight', 'bold', 'Enable', 'off');

                            % next grid
                            obj.controls.nextGrid(t) = uicontrol( 'Parent', obj.controls.tab(t), 'Style', 'pushbutton', 'Position', [180 7 22 22], ...
                                'String', '>', 'Callback', @obj.btnNextGrid, 'FontSize', 11 , 'FontWeight', 'bold', 'Enable', 'off');

                            %set add and remove tab buttons
                            if t > 1
                                set(obj.controls.addTab,'enable','on');
                                set(obj.controls.removeTab,'enable','on');
                            else
                                set(obj.controls.addTab,'enable','on');
                                set(obj.controls.removeTab,'enable','off');
                            end
                        end
                    end

                    if ~isempty(obj.settings.Layout{obj.settings.Tabnum})

                        %highlight last used tab (works for Tabnum==1 and Tabnum>1)
                        set(obj.controls.layout, 'SelectedTab',obj.controls.tab(obj.settings.Tabnum));

                        obj.settings.Grids   = obj.settings.Layout{obj.settings.Tabnum};
                        obj.settings.Gridnum = length(obj.settings.Grids);

                        %display last grid settings
                        auxgrids = split(obj.settings.Grids{end}, ';');
                        set(obj.controls.edtGrid2(obj.settings.Tabnum), 'enable', 'on');
                        set(obj.controls.edtGrid2(obj.settings.Tabnum), 'String', strtrim(auxgrids{1}));
                        set(obj.controls.edtGrid4(obj.settings.Tabnum), 'enable', 'on');
                        set(obj.controls.edtGrid4(obj.settings.Tabnum), 'String', strtrim(auxgrids{2}));

                        if length(obj.settings.Grids)==1
                            set(obj.controls.removeGrid(obj.settings.Tabnum),'enable','on');
                            set(obj.controls.addGrid(obj.settings.Tabnum),'enable','on');
                            set(obj.controls.nextGrid(obj.settings.Tabnum),'enable','off');
                            set(obj.controls.previousGrid(obj.settings.Tabnum),'enable','off');

                        else %more than 1
                            set(obj.controls.removeGrid(obj.settings.Tabnum),'enable','on');
                            set(obj.controls.addGrid(obj.settings.Tabnum),'enable','on');
                            set(obj.controls.nextGrid(obj.settings.Tabnum),'enable','off'); %set to last grid, so no next grid
                            set(obj.controls.previousGrid(obj.settings.Tabnum),'enable','on');
                        end

                        %log
                        LogInfo(obj, 3);
                        set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Current grid settings: ' strjoin(obj.settings.Grids,'    ')]});
                        loggingActions(obj.settings.currdir,3,[' > Current grid settings: ' strjoin(obj.settings.Grids,'    ')]);

                    end

                    %set method
                    if strcmp(obj.settings.Method{obj.settings.Tabnum}, 'Method 1 (Hermes et al. 2010)')
                        set(obj.controls.radiobtn1,'Value', 1);
                        set(obj.controls.radiobtn2,'Value', 0);
                        set(obj.controls.radiobtn5,'Value', 0);

                    elseif  strcmp(obj.settings.Method{obj.settings.Tabnum}, 'Method HD') %if HD method
                        set(obj.controls.radiobtn1,'Value', 0);
                        set(obj.controls.radiobtn2,'Value', 1);
                        set(obj.controls.radiobtn5,'Value', 0);

                    elseif  strcmp(obj.settings.Method{obj.settings.Tabnum}, 'Method sEEG or depth') %if sEEG method
                        set(obj.controls.radiobtn1,'Value', 0);
                        set(obj.controls.radiobtn2,'Value', 0);
                        set(obj.controls.radiobtn5,'Value', 1);
                        set(obj.controls.radiobtn3, 'Value',0);
                        set(obj.controls.radiobtn3, 'Enable','off');
                        set(obj.controls.radiobtn4, 'Value',0);
                        set(obj.controls.radiobtn4, 'Enable','off');
                        set(obj.controls.radiobtn6, 'Value',1);
                        set(obj.controls.radiobtn6, 'Enable','off');
                        %disable grid size
                        set(obj.controls.edtGrid4, 'Enable', 'off');
                        set(obj.controls.edtGrid4, 'String', ' ');

                    end

                    %set hemisphere
                    if strcmp(obj.settings.Hemisphere{obj.settings.Tabnum}, 'Left')
                        set(obj.controls.radiobtn3,'Value', 1);
                        set(obj.controls.radiobtn4,'Value', 0);
                        set(obj.controls.radiobtn6,'Value', 0);

                    elseif strcmp(obj.settings.Hemisphere{obj.settings.Tabnum}, 'Right')
                        set(obj.controls.radiobtn3,'Value', 0);
                        set(obj.controls.radiobtn4,'Value', 1);
                        set(obj.controls.radiobtn6,'Value', 0);

                    elseif strcmp(obj.settings.Hemisphere{obj.settings.Tabnum}, 'Both')
                        set(obj.controls.radiobtn3,'Value', 0);
                        set(obj.controls.radiobtn4,'Value', 0);
                        set(obj.controls.radiobtn6,'Value', 1);
                    end
                end

                %log
                LogInfo(obj, 2);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Saved subject name, cluster settings and grid settings loaded.']});
                loggingActions(obj.settings.currdir,1,[' > Saved subject name, cluster settings and grid settings loaded.']);


                %if files in folder then read them:
                %MRI
                E = [obj.settings.currdir 'data/MRI/T1.nii'];
                if exist(E)~=0
                    obj.settings.MRI = [obj.settings.currdir 'data/MRI/T1.nii'];
                    set(obj.controls.txtMRI, 'string',['...' obj.settings.MRI(end-18:end)]);
                    set(obj.controls.txtMRI, 'FontSize',10);

                    %log
                    LogInfo(obj, 2);
                    try
                        set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> MRI scan selected: ',['... ', obj.settings.MRI(end-125:end)]});
                    catch
                        set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> MRI scan selected: ',[obj.settings.MRI(1:end)]});
                    end
                    loggingActions(obj.settings.currdir,1,[' > MRI scan selected: ' obj.settings.MRI]);
                end

                %FS
                E = [obj.settings.currdir 'data/FreeSurfer/t1_class.nii'];
                if exist(E)~=0
                    obj.settings.FS = [obj.settings.currdir 'data/FreeSurfer/t1_class.nii'];
                    obj.settings.loaded(2) = 1;
                    set(obj.controls.txtFS, 'string',['...' obj.settings.FS(end-18:end)]);
                    set(obj.controls.txtFS, 'FontSize',10);
                    %log
                    LogInfo(obj, 2);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> FS segmentation selected: ', obj.settings.FS});
                    loggingActions(obj.settings.currdir,1,[' > FS segmentation selected: ' obj.settings.FS]);
                end

                %CT
                E = [obj.settings.currdir 'data/CT/CT_highresRAI.nii'];
                if exist(E)~=0
                    obj.settings.CT = [obj.settings.currdir 'data/CT/CT_highresRAI.nii'];
                    obj.settings.loaded(3) = 1;
                    set(obj.controls.txtCT1, 'string',['...' obj.settings.CT(end-18:end)]);
                    set(obj.controls.txtCT1, 'FontSize',10);
                    %log
                    LogInfo(obj, 2);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> CT scan selected: ', obj.settings.CT});
                    loggingActions(obj.settings.currdir,1,[' > CT scan selected: ' obj.settings.CT]);
                end

                %LABELS
                E = [obj.settings.currdir 'data/3DClustering/electrode_labels.txt'];
                if exist(E)~=0
                    obj.settings.Labels = [obj.settings.currdir 'data/3DClustering/electrode_labels.txt'];
                    obj.settings.loaded(4) = 1;
                    set(obj.controls.txtLabels, 'string', ['...' obj.settings.Labels(end-18:end)]);
                    set(obj.controls.txtLabels, 'FontSize',10);
                    %log
                    LogInfo(obj, 2);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> Electrode labels selected: ', obj.settings.Labels});
                    loggingActions(obj.settings.currdir,1,[' > Electrode labels selected: ' obj.settings.Labels]);
                end

                %update path info
                addpath(genpath(obj.settings.currdir));
                obj.settings.scriptspath  = [fileparts( mfilename('fullpath') ) '/'];
                addpath(genpath(obj.settings.scriptspath));

                settings = obj.settings;
                save([obj.settings.currdir '/log_info/settings'], 'settings');

            else %if wrong directory is selected
                errordlg('Please select an ''ALICE'' folder.')
                disp('! ERROR: Please select an ''ALICE'' folder.');
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> ERROR: Please select an ''ALICE'' folder.'});

            end
        end

        function AlignCTtoMRI( obj )

            cd(obj.settings.currdir);

            if obj.settings.loaded(1) == 1 && obj.settings.loaded(3) == 1
                %log before
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:}, '> Aligning CT to MRI. This procedure might take several minutes. Please wait...'});
                loggingActions(obj.settings.currdir,1,' > Aligning CT to MRI... This might take several minutes. Please wait...');
                pause(1);

                cd([obj.settings.currdir '/data/coregistration/']);

                %clean directory if already run before:
                system('rm CT_highresRAI_*');
                system('rm *.1D');
                system('rm temp_*');

                %copy CT local
                copyfile('../CT/CT_highresRAI.nii','.');

                %select T1
                t1_name = dir(obj.settings.MRI);
                T1_path = ['../MRI/' t1_name.name];

                %align:
                system(['tcsh -x alignCTtoT1_shft_res.csh -CT_path CT_highresRAI.nii -T1_path ' T1_path]);
                loggingActions(obj.settings.currdir,1, [' > tcsh -x alignCTtoT1_shft_res.csh -CT_path CT_highresRAI.nii -T1_path' T1_path]);
                cd(obj.settings.currdir);

                f = fopen('./data/coregistration/status.txt');
                S = fscanf(f,'%s');

                if strcmp(S(end-20:end),'alignmentsuccessfully')

                    %log after
                    LogInfo(obj, 1);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:}, '> CT and MRI have been co-registered. Please check the results before proceeding.'});
                    loggingActions(obj.settings.currdir,1,' > CT and MRI have been co-registered. Please check the results before proceeding.');

                    %display instruction box:
                    h = msgbox({['To check whether the alignment was successful,', ' please check the overlayed files in AFNI.'],...
                        ['For that use the buttons OVERLAY and UNDERLAY ', 'to specify the CT and MRI, respectively. ', ...
                        'Use the intensity button on the volume windows,', ' to decrease/increase the intensity of the overlay.'],...
                        [' '],['- If the alignment is good, please close AFNI and proceed to Step 2.'],...
                        ['- If the alignment is NOT good, please check the if the CT and MRI where correctly',...
                        ' converted to *.nii. Check orientation and voxel sizes too.']},'How to check if alignment was successful?', 'help');
                else
                    %display instruction box:
                    h = msgbox({['Alignment failed,', ' please check the input files.'],...
                        ['Please check the if the CT and MRI where correctly',...
                        ' converted to *.nii. Check orientation and voxel sizes too.']},'Alignment failed', 'error');
                end

            else
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:}, '>! WARNING: CT and MRI scans are not loaded yet. Use the buttons in Step 1 to load them.'});
                loggingActions(obj.settings.currdir,1,' >! WARNING: CT and MRI scans are not loaded yet. Use the buttons in Step 1 to load them.');
            end

        end

        function AlreadyAligned( obj )

            %create 1D files with identity matrices
            Tmatrix = [1 0 0 0 0 1 0 0 0 0 1 0];
            fileID = fopen([obj.settings.currdir '/data/coregistration/CT_highresRAI_res_shft_al_mat.aff12.1D'],'w');
            fwrite(fileID, num2str(Tmatrix));
            fclose(fileID);

            Tmatrix2 = [1     0     0     0     0     1     0     0     0     0     1     0];
            fileID = fopen([obj.settings.currdir '/data/coregistration/CT_highresRAI_shft.1D'],'w');
            fwrite(fileID, num2str(Tmatrix2));
            fclose(fileID);

            %log
            LogInfo(obj, 1);
            set(obj.controls.txtLog, 'string',{obj.settings.str{:}, '> Open selected: CT already aligned.'});
            loggingActions(obj.settings.currdir,1,' > Open selected: CT already aligned.');


        end

        function ExtractClusters ( obj )

            cd(obj.settings.currdir);

            if obj.settings.loaded(3) == 1

                system(['rm ' obj.settings.currdir '/data/coregistration/temp_ANAT.nii']);
                system(['rm ' obj.settings.currdir '/data/coregistration/CT_highresRAI.nii']);

                %3dclustering
                cd([obj.settings.currdir '/data/3Dclustering/']);

                if exist(['3dclusters_r' num2str(obj.settings.R) '_is' num2str(obj.settings.IS) '_thr' num2str(obj.settings.CV) '.nii'])==0 && exist('../CT/CT_highresRAI.nii')==2
                    %log before 3dclustering
                    LogInfo(obj, 1);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:}, '> Extracting electrode clusters. This procedure might take some minutes. Please wait...'});
                    loggingActions(obj.settings.currdir,2,' > Extracting electrode clusters. This procedure might take some minutes. Please wait...');
                    pause(1);

                    system(['tcsh -x 3dclustering.csh -CT_path ../CT/CT_highresRAI.nii -radius ' num2str(obj.settings.R) ' -interelectrode_space ' num2str(obj.settings.IS) ' -clip_value ' num2str(obj.settings.CV)]);
                    %log after 3dclustering
                    LogInfo(obj, 1);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:}, '> Electrode clusters extracted. Please check results and then close SUMA.'});
                    loggingActions(obj.settings.currdir,2,' > Electrode cluster extracted. Please check results and then close SUMA.');

                    %message box:
                    h = msgbox({['The electrode-clusters have been extracted,', ' please check the result in SUMA.'],...
                        ['After revision, close SUMA.'],[' '], ['To extract new clusters, select new settings and click ''Extract clusters''.'], ...
                        ['Otherwise, click ''Select Electrodes'' to continue.']},'Check electrode-clusters', 'help');

                    system(['suma -i 3dclusters_r' num2str(obj.settings.R) '_is' num2str(obj.settings.IS) '_thr' num2str(obj.settings.CV) '.gii']);

                else
                    LogInfo(obj, 2);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:}, '>! ERROR: delete any 3dclusters_rX_isX_thrX.nii files in the /3Dclustering directory. This function cannot overwrite files. Check if CT_highresRAI.nii is ','inside /data/CT folder.'});
                    loggingActions(obj.settings.currdir,2,' > ! ERROR: delete any 3dclusters_rX_isX_thrX.nii files in the /3Dclustering directory. This function cannot overwrite files. Check if CT_highresRAI.nii is inside /data/CT folder.');
                end

                cd(obj.settings.currdir);

            else
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:}, '>! WARNING: CT was not loaded yet. Use the button in Step 2 to load it.'});
                loggingActions(obj.settings.currdir,2,' >! WARNING: CT was not loaded yet. Use the button in Step 2 to load it.');

                cd(obj.settings.currdir);

            end

        end

        function SelectElectrodes( obj )

            cd(obj.settings.currdir);
            if obj.settings.loaded(4)==0
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:}, ['>! WARNING: Please select a file with electrode labels first.']});
                loggingActions(obj.settings.currdir,2,[' >! WARNING: Please select a file with electrode labels first.']);
                return;
            end
            %check if file exists
            if exist([obj.settings.currdir '/data/3Dclustering/3dclusters_r' num2str(obj.settings.R) '_is' num2str(obj.settings.IS) '_thr' num2str(obj.settings.CV) '.nii']) ~=0

                %log before select electrodes
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:}, '> Time to select the electrodes! Please select them according to the leads order.'});
                loggingActions(obj.settings.currdir,2,' > Time to select the electrodes! Please select them according to the leads order.');

                %move to 3dclustering folder
                cd([obj.settings.currdir '/data/3Dclustering/']);

                %define input file
                clust_set  = ['3dclusters_r' num2str(obj.settings.R) '_is'...
                    num2str(obj.settings.IS) '_thr' num2str(obj.settings.CV) '.nii'];
                clust_surf = ['3dclusters_r' num2str(obj.settings.R) '_is' ...
                    num2str(obj.settings.IS) '_thr' num2str(obj.settings.CV) '.gii'];

                %open afni and suma:
                system(['tcsh -x open_afni_suma.csh -CT_path ../CT/CT_highresRAI.nii -clust_set ' clust_set ' -clust_surf ' clust_surf ], '-echo');

                selectElGUI( obj.settings, obj.controls );

                %display instruction box:
                h = msgbox({['Time to select the electrodes!'], ['Please have the leads order (electrode layout) at hand.'],...
                    [' '],['AFNI and SUMA interfaces will open, ', 'and you will see the electrodes clusters both in the volume and the surface spaces.'], ...
                    [' '],['With right click you can select the electrode on the surface,', ' and with the left click on the volume space.'],...
                    ['Use the click+drag to navigate in SUMA, scroll to zoom in and out and scroll-lock for panning.'],...
                    [' '],['Please use the matlab pop-up window to select the electrodes.'],...
                    },'Time to select electrodes!', 'help');

            else
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:}, ['>! WARNING: There is no 3dclusters_r' num2str(obj.settings.R) '_is' num2str(obj.settings.IS) '_thr' num2str(obj.settings.CV) '.nii file in the /3Dclustering folder. Please check the settings above or extract clusters first.']});
                loggingActions(obj.settings.currdir,2,[' >! WARNING: There is no 3dclusters_r' num2str(obj.settings.R) '_is' num2str(obj.settings.IS) '_thr' num2str(obj.settings.CV) '.nii file in the /3Dclustering folder. Please check the settings above or extract clusters first.']);
            end
        end

        function LogInfo( obj, offset )

            obj.settings.str = get(obj.controls.txtLog, 'string');
            long_sentences   = sum(cellfun(@length, obj.settings.str)>160);
            long_sentences   = long_sentences + sum(cellfun(@length, obj.settings.str)>2*160);

            if length(obj.settings.str)+long_sentences > obj.settings.NUM_LINES

                try
                    obj.settings.str = obj.settings.str( (end - (obj.settings.NUM_LINES-offset-long_sentences-1)) :end);
                catch
                    obj.settings.str = obj.settings.str(offset+1:end);
                end
            end

        end

    end

    methods % for callbacks

        % Close request function for the main dialog.
        function figCloseRequest( obj, hObject, ~ )

            %set writing permissions to all files created with alice for
            %group.
            if isfield(obj.settings,'currdir')
                cd(obj.settings.currdir);
                L = dir('../ALICE');
                if ~isempty(L)
                    listing = dir('**/*');
                    list = [{listing.folder}' {listing.name}'];
                    for k=1:length(list)
                        try
                            fileattrib([list{k,1} '/' list{k,2}],'+w','g');
                        end
                    end
                end
                %to double check permissions, since sometimes it doesnt
                %work for some files..
                try
                    system('chmod -R g+w ../ALICE');
                end
            end

            if ~isempty(obj.settings.Grids)
                %move all grids to layout for completeness
                obj.settings.Layout{obj.settings.Tabnum} = obj.settings.Grids;
                obj.settings.Grids  = [];
            end
            %save changes in settings mat file
            settings = obj.settings;
            try
                save([obj.settings.currdir '/log_info/settings'], 'settings');
            end

            delete( hObject );
            clc;
            disp('     ___    ');
            disp('    |   |   _ ');
            disp(' ___| __|__|_|__        ');
            disp('|    | |        |_          ');
            disp('|____| |________|_| |  Together everyone achieves more  |           ');
            disp(' ');



        end

        %locate directory
        function btnLocateDirectory( obj, hObject, ~ )

            obj.LocateDirectory
        end

        %create directory
        function btnCreateDirectory( obj, hObject, ~ )

            obj.CreateDirectory;

        end

        %open MRI
        function btnOpenMRI( obj, hObject, ~ )

            cd(obj.settings.currdir);

            %clean up previous MRI
            if length(dir([obj.settings.currdir '/data/MRI/']))>2
                choice = questdlg({[' '],['Other MRI scan(s) have have been found in ./data/MRI folder.'], ...
                    ['If you choose to delete file(s), the existing file(s) will be deleted and replaced by the new file!'],[' ']},...
                    'WARNING!', 'Delete old file(s)', 'Keep old file(s)', 'Delete old file(s)');

                switch choice
                    case 'Delete old file(s)'
                        delete([obj.settings.currdir '/data/MRI/*.nii']);
                        %log
                        LogInfo(obj, 1);
                        set(obj.controls.txtLog, 'string',{obj.settings.str{:}, '>! WARNING: Deleting previously loaded MRI file.'});
                        loggingActions(obj.settings.currdir,1,[' >! WARNING: Deleting previously loaded MRI file.']);
                end
            end

            [FileName, PathName] = uigetfile('../*.mgz;*.nii');

            if FileName~=0

                %if the file was already in the folder but was not loaded
                %before, then do not copy-paste, else copy-paste
                if ~strcmpi(PathName,[obj.settings.currdir 'Data/MRI/'])
                    %copy file to Alice folder
                    copyfile([PathName FileName], [obj.settings.currdir 'data/MRI/' FileName ]);
                    origdir = [PathName FileName];
                    LogInfo(obj, 2);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> MRI scan selected: ',origdir});
                    loggingActions(obj.settings.currdir,1,[' > MRI scan selected: ' origdir]);
                end

                %if mgz --> convert to nii
                if strcmpi(FileName(end-2:end), 'mgz')
                    system(['mri_convert ' obj.settings.currdir 'data/MRI/' FileName ' ' obj.settings.currdir 'data/MRI/T1.nii']);
                    FileName = [FileName(1:end-3) 'nii'];
                end

                obj.settings.MRI = [obj.settings.currdir 'data/MRI/' FileName];
                obj.settings.loaded(1) = 1;
                settings = obj.settings;
                save([obj.settings.currdir '/log_info/settings'], 'settings');

                set(obj.controls.txtMRI, 'string',['...' obj.settings.MRI(end-18:end)]);
                set(obj.controls.txtMRI, 'FontSize',10);

                %log
                
                LogInfo(obj, 2);
                try
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> MRI scan saved as: ',['... ', obj.settings.MRI(end-125:end)]});
                catch
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> MRI scan saved as: ',[obj.settings.MRI(1:end)]});
                end
                loggingActions(obj.settings.currdir,1,[' > MRI scan saved as: ' obj.settings.MRI]);

            else
                disp('! WARNING: MRI scan not selected.');
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:}, '>! WARNING: MRI scan not selected.'});
                loggingActions(obj.settings.currdir,1,' >! WARNING: MRI scan not selected.');
            end
        end

        %open FS
        function btnOpenFS( obj, hObject, ~ )

            cd(obj.settings.currdir);

            [FileName, PathName] = uigetfile('../*.mgz;*.nii');

            if FileName~=0

                %if the file was already in the folder but was not loaded
                %before, then do not copy-paste, else copy-paste
                if ~strcmpi(PathName,[obj.settings.currdir 'Data/FreeSurfer/'])
                    %Copy file to Alice folder
                    copyfile([PathName FileName], [obj.settings.currdir 'data/FreeSurfer/t1_class.nii']);
                    origdir = [PathName FileName];
                    LogInfo(obj, 2);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> FS segmentation selected: ', origdir});
                    loggingActions(obj.settings.currdir,1,[' > FS segmentation selected: ' origdir]);
                end

                %if mgz --> convert to nii
                if strcmpi(FileName(end-2:end), 'mgz')
                    system(['mri_convert ' PathName FileName ' ' obj.settings.currdir 'data/FreeSurfer/t1_class.nii']);
                    FileName = 't1_class.nii';
                end

                obj.settings.FS = [obj.settings.currdir 'data/FreeSurfer/t1_class.nii'];
                obj.settings.loaded(2) = 1;
                settings = obj.settings;
                save([obj.settings.currdir '/log_info/settings'], 'settings');

                set(obj.controls.txtFS, 'string', ['...' obj.settings.FS(end-18:end)]);
                set(obj.controls.txtFS, 'FontSize',10);

                %log
                
                LogInfo(obj, 2);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> FS segmentation saved as: ', obj.settings.FS});
                loggingActions(obj.settings.currdir,1,[' > FS segmentation saved as: ' obj.settings.FS]);
            else
                disp('! WARNING: FreeSurfer segmentation file not selected.');
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'>! WARNING: FreeSurfer segmentation file not selected.'});
                loggingActions(obj.settings.currdir,1,' >! WARNING: FreeSurfer segmentation file not selected.');
            end
        end

        %Open CT
        function btnOpenCT1( obj, hObject, ~ )

            cd(obj.settings.currdir);

            [FileName, PathName] = uigetfile('../*.nii');
            if FileName~=0

                %if the file was already in the folder but was not loaded
                %before, then do not copy-paste, else copy-paste
                if ~strcmpi(PathName,[obj.settings.currdir 'Data/CT/'])
                    %rename CT to CT_highresRAI.nii
                    copyfile([PathName FileName], [obj.settings.currdir 'data/CT/CT_highresRAI.nii']);
                    origdir = [PathName FileName];
                    LogInfo(obj, 2);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> CT scan selected: ', origdir});
                    loggingActions(obj.settings.currdir,1,[' > CT scan selected: ' origdir]);
                end

                obj.settings.CT = [obj.settings.currdir 'data/CT/CT_highresRAI.nii'];
                obj.settings.loaded(3) = 1;

                %log CT
                LogInfo(obj, 2);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> CT saved as: ', obj.settings.CT});
                loggingActions(obj.settings.currdir,1,[' > CT saved as: ' obj.settings.CT]);

                %update text boxes
                set(obj.controls.txtCT1, 'string',['...' obj.settings.CT(end-18:end)]);
                set(obj.controls.txtCT1, 'FontSize',10);

                %extract ct max value
                system(['3dBrickStat -slow ' obj.settings.currdir '/data/CT/CT_highresRAI.nii > temp_ct_val.txt']);
                Faux = fopen('temp_ct_val.txt');
                obj.settings.CV = fscanf(Faux, '%d')-5;
                set(obj.controls.edtCV, 'string', {num2str(obj.settings.CV)});
                fclose(Faux);
                delete(['temp_ct_val.txt']);

                %save settings
                settings = obj.settings;
                save([obj.settings.currdir '/log_info/settings'], 'settings');

                %log CV
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Electrode maximum intensity selected: ' num2str(obj.settings.CV)]});
                loggingActions(obj.settings.currdir,2,[' > Electrode maximum intensity selected: ' num2str(obj.settings.CV)]);

            else
                disp('! WARNING: CT scan not selected.');
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'>! WARNING: CT scan not selected.'});
                loggingActions(obj.settings.currdir,1,' >! WARNING: CT scan not selected.');
                loggingActions(obj.settings.currdir,2,' >! WARNING: CT scan not selected.');
            end
        end

        %open electrode labels
        function btnOpenLabels( obj, hObject, ~ )

            cd(obj.settings.currdir);

            [FileName, PathName] = uigetfile('../*.txt');

            if FileName~=0

                %check if unique labels in file
                labels = readcell([PathName FileName]);
                if numel(unique(labels)) ~= length(labels)
                    disp('! WARNING: Select a file with unique label per electrode.');
                    %log
                    LogInfo(obj, 1);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'>! WARNING: Select a file with unique label per electrode.'});
                    loggingActions(obj.settings.currdir,1,' >! WARNING: Select a file with unique label per electrode.');
                    return;
                end

                %if the file was already in the folder but was not loaded
                %before, then do not copy-paste but rename, else copy-paste               
                if strcmpi(PathName,[obj.settings.currdir 'data/3Dclustering/'])
                    movefile([PathName FileName],[obj.settings.currdir 'data/3Dclustering/electrode_labels.txt'])
                else 
                    %Copy file to Alice folder
                    copyfile([PathName FileName], [obj.settings.currdir 'data/3Dclustering/electrode_labels.txt']);
                    origdir = [PathName FileName];
                    LogInfo(obj, 2);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> Electrode labels selected: ', origdir});
                    loggingActions(obj.settings.currdir,1,[' > Electrode labels selected: ' origdir]);
                end

                obj.settings.Labels = [obj.settings.currdir 'data/3Dclustering/electrode_labels.txt'];
                settings = obj.settings;
                save([obj.settings.currdir '/log_info/settings'], 'settings');

                set(obj.controls.txtLabels, 'string', ['...' obj.settings.Labels(end-18:end)]);
                set(obj.controls.txtLabels, 'FontSize',10);
                obj.settings.loaded(4) = 1;

                %log
                LogInfo(obj, 2);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> Electrode labels saved as: ', obj.settings.Labels});
                loggingActions(obj.settings.currdir,1,[' > Electrode labels saved as: ' obj.settings.Labels]);
            else
                disp('! WARNING: Electrode labels not selected.');
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'>! WARNING: Electrode labels not selected.'});
                loggingActions(obj.settings.currdir,1,' >! WARNING: Electrode labels not selected.');
            end
        end

        %Align
        function btnAlignCTtoMRI( obj, hObject, ~ )

            obj.AlignCTtoMRI;

        end

        %Already aligned
        function btnAlreadyAligned( obj, hObject, ~ )

            obj.AlreadyAligned;

        end

        %enter clip value
        function edtCV( obj, hObject, ~ )

            str = get(obj.controls.edtCV, 'string');
            try
                obj.settings.CV = str2num(str{1});
            catch
                obj.settings.CV = str2num(str);
            end

            if isempty(obj.settings.CV)
                disp('! WARNING: Maximum intensity must be an integer value bigger than 0.');
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',[obj.settings.str(:)',{'>! WARNING: Maximum intensity must be an integer value bigger than 0.'}]);
                loggingActions(obj.settings.currdir,2,' >! WARNING: Maximum intensity must be an integer value bigger than 0.');
            else
                settings = obj.settings;
                save([obj.settings.currdir '/log_info/settings'], 'settings');

                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Electrode maximum intensity selected: ' num2str(obj.settings.CV)]});
                loggingActions(obj.settings.currdir,2,[' > Electrode maximum intensity selected: ' num2str(obj.settings.CV)]);
            end

        end

        %enter radius
        function edtR( obj, hObject, ~ )

            str = get(obj.controls.edtR, 'string');
            try
                obj.settings.R = str2num(str{1});
            catch
                obj.settings.R = str2num(str);
            end

            if isempty(obj.settings.R)
                disp('! WARNING: Electrode volume must be an integer value bigger than 0.');
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'>! WARNING: Electrode volume must be an integer value bigger than 0.'});
                loggingActions(obj.settings.currdir,2,' >! WARNING: Electrode volume must be an integer value bigger than 0.');
            else
                settings = obj.settings;
                save([obj.settings.currdir '/log_info/settings'], 'settings');

                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Electrode volume selected: ' num2str(obj.settings.R)]});
                loggingActions(obj.settings.currdir,2,[' > Electrode volume selected: ' num2str(obj.settings.R)]);
            end
        end

        %enter interelectrode distance
        function edtIS( obj, hObject, ~ )

            str = get(obj.controls.edtIS, 'string');
            try
                obj.settings.IS = str2num(str{1});
            catch
                obj.settings.IS = str2num(str);
            end

            if isempty(obj.settings.IS)
                disp('! WARNING: Interelectrode space must be an integer value bigger than 0.');
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'>! WARNING: Interelectrode space must be an integer value bigger than 0.'});
                loggingActions(obj.settings.currdir,2,' >! WARNING: Interelectrode space must be an integer value bigger than 0.');
            else
                settings = obj.settings;
                save([obj.settings.currdir '/log_info/settings'], 'settings');

                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Interelectrode space selected: ' num2str(obj.settings.IS)]});
                loggingActions(obj.settings.currdir,2,[' > Interelectrode space selected: ' num2str(obj.settings.IS)]);
            end

        end

        %Extract electrodes
        function btnExtractClusters( obj, hObject, ~ )

            obj.ExtractClusters;

        end

        %Select electrodes
        function btnSelectElectrodes( obj, hObject, ~ )

            obj.SelectElectrodes;

        end

        %choose method
        function radiobtnSelectionMethod( obj, hObject, callbackdata )

            obj.settings.Method{obj.settings.Tabnum} = callbackdata.NewValue.String;

            %log
            LogInfo(obj, 1);
            set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> ' obj.settings.Method{obj.settings.Tabnum} ' selected.']});
            loggingActions(obj.settings.currdir,3,[' > ' obj.settings.Method{obj.settings.Tabnum} ' selected.']);

            if strcmp(obj.settings.Method{obj.settings.Tabnum},'Method 1 (Hermes et al. 2010)')
                set(obj.controls.radiobtn3, 'Enable','on');
                set(obj.controls.radiobtn4, 'Enable','on');
                set(obj.controls.radiobtn6, 'Enable','on');
                set(obj.controls.edtGrid4, 'Enable', 'on');

            elseif strcmp(obj.settings.Method{obj.settings.Tabnum},'Method HD')
                set(obj.controls.radiobtn3, 'Enable','on');
                set(obj.controls.radiobtn4, 'Enable','on');
                set(obj.controls.radiobtn6, 'Enable','on');
                set(obj.controls.edtGrid4, 'Enable', 'on');

            elseif strcmp(obj.settings.Method{obj.settings.Tabnum},'Method sEEG or depth')
                set(obj.controls.radiobtn3, 'Value',0);
                set(obj.controls.radiobtn3, 'Enable','off');
                set(obj.controls.radiobtn4, 'Value',0);
                set(obj.controls.radiobtn4, 'Enable','off');
                set(obj.controls.radiobtn6, 'Value',1);
                set(obj.controls.radiobtn6, 'Enable','off');
                %show both hemipsheres by default (no option):
                obj.settings.Hemisphere{obj.settings.Tabnum} = 'Both';
                %disable grid size
                set(obj.controls.edtGrid4, 'Enable', 'off');
                set(obj.controls.edtGrid4, 'String', ' ');

                %show grid settings if already saved
                if ~isempty(obj.settings.Grids)
                    for gridnum=1:length(obj.settings.Grids)
                        LogInfo(obj, 1);
                        set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Grid ' num2str(gridnum) ' settings: ' obj.settings.Grids{gridnum}]});
                        loggingActions(obj.settings.currdir,3,[' > Grid ' num2str(gridnum) ' settings: ' obj.settings.Grids{gridnum}]);
                    end
                end
            end

        end

        %choose hemisphere
        function radiobtnSelectionHemisphere( obj, hObject, callbackdata )

            obj.settings.Hemisphere{obj.settings.Tabnum} = callbackdata.NewValue.String;

            %log
            LogInfo(obj, 1);
            set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> ' obj.settings.Hemisphere{obj.settings.Tabnum} ' hemisphere selected.']});
            loggingActions(obj.settings.currdir,3,[' > ' obj.settings.Hemisphere{obj.settings.Tabnum} ' hemisphere(s) selected.']);


        end

        %choose tab
        function tabSelectScheme( obj, hObject, ~ )

            auxtab = get(obj.controls.layout,'SelectedTab');
            auxtab = auxtab.Title;
            if ~isempty(obj.settings.Grids)
                %update layout
                obj.settings.Layout{obj.settings.Tabnum}  = obj.settings.Grids;
                obj.settings.Grids   = [];
                obj.settings.Gridnum = 0;
            end
            %update tab number
            obj.settings.Tabnum = str2double(auxtab(end));

            %log
            LogInfo(obj, 1);
            set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Tab ' num2str(obj.settings.Tabnum) ' selected.']});
            loggingActions(obj.settings.currdir,3,[' > Tab ' num2str(obj.settings.Tabnum) ' selected.']);

             %select the method of that tab
            if strcmp(obj.settings.Method{obj.settings.Tabnum},'Method 1 (Hermes et al. 2010)')
                set(obj.controls.radiobtn1, 'Value',1);
                set(obj.controls.radiobtn2, 'Value',0);
                set(obj.controls.radiobtn5, 'Value',0);

                set(obj.controls.radiobtn3, 'Enable','on');                
                set(obj.controls.radiobtn4, 'Enable','on');                
                set(obj.controls.radiobtn6, 'Enable','on');
                set(obj.controls.edtGrid4, 'Enable', 'on');
                set(obj.controls.edtGrid4(obj.settings.Tabnum), 'String', ' ');
                
            elseif strcmp(obj.settings.Method{obj.settings.Tabnum},'Method HD')
                set(obj.controls.radiobtn1, 'Value',0);
                set(obj.controls.radiobtn2, 'Value',1);
                set(obj.controls.radiobtn5, 'Value',0);

                set(obj.controls.radiobtn3, 'Enable','on');                
                set(obj.controls.radiobtn4, 'Enable','on');                
                set(obj.controls.radiobtn6, 'Enable','on');
                set(obj.controls.edtGrid4, 'Enable', 'on');
                set(obj.controls.edtGrid4(obj.settings.Tabnum), 'String', ' ');
                
            elseif strcmp(obj.settings.Method{obj.settings.Tabnum},'Method sEEG or depth')
                set(obj.controls.radiobtn1, 'Value',0);
                set(obj.controls.radiobtn2, 'Value',0);
                set(obj.controls.radiobtn5, 'Value',1);

                set(obj.controls.radiobtn3, 'Value',0);
                set(obj.controls.radiobtn3, 'Enable','off');
                set(obj.controls.radiobtn4, 'Value',0);
                set(obj.controls.radiobtn4, 'Enable','off');
                set(obj.controls.radiobtn6, 'Value',1);
                set(obj.controls.radiobtn6, 'Enable','off');
                %show both hemipsheres by default (no option):
                obj.settings.Hemisphere{obj.settings.Tabnum} = 'Both';
                %disable grid size
                set(obj.controls.edtGrid4(obj.settings.Tabnum), 'Enable', 'off');
                set(obj.controls.edtGrid4(obj.settings.Tabnum), 'String', ' ');

            end
           
            %select hemisphere of that tab
            if strcmp(obj.settings.Hemisphere{obj.settings.Tabnum}, 'Left')
                set(obj.controls.radiobtn3,'Value', 1);
                set(obj.controls.radiobtn4,'Value', 0);
                set(obj.controls.radiobtn6,'Value', 0);

            elseif strcmp(obj.settings.Hemisphere{obj.settings.Tabnum}, 'Right')
                set(obj.controls.radiobtn3,'Value', 0);
                set(obj.controls.radiobtn4,'Value', 1);
                set(obj.controls.radiobtn6,'Value', 0);

            elseif strcmp(obj.settings.Hemisphere{obj.settings.Tabnum}, 'Both')
                set(obj.controls.radiobtn3,'Value', 0);
                set(obj.controls.radiobtn4,'Value', 0);
                set(obj.controls.radiobtn6,'Value', 1);
            end

            %show grids in current tab in log
            if ~isempty(obj.settings.Layout{obj.settings.Tabnum})

                obj.settings.Grids = obj.settings.Layout{obj.settings.Tabnum};

                for gridnum = 1:length(obj.settings.Grids)
                    LogInfo(obj, 1);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Grid ' num2str(gridnum) ' settings: ' obj.settings.Grids{gridnum}]});
                    loggingActions(obj.settings.currdir,3,[' > Grid ' num2str(gridnum) ' settings: ' obj.settings.Grids{gridnum}]);
                end

                %show last grid when moving between tabs
                gridInfo = split(strtrim(obj.settings.Grids{end}),';');
                set(obj.controls.edtGrid2(obj.settings.Tabnum),'string',gridInfo{1});
                set(obj.controls.edtGrid4(obj.settings.Tabnum),'string',gridInfo{2});
                obj.settings.Gridnum = length(obj.settings.Grids);

                %set add/remove/previous/next grid buttons (selected grid always
                %last)
                if length(obj.settings.Grids) > 1
                    % remove grid
                    obj.controls.removeGrid(obj.settings.Tabnum) = uicontrol( 'Parent', obj.controls.tab(obj.settings.Tabnum ), 'Style', 'pushbutton', 'Position', [150 7 22 22], ...
                        'String', '-', 'Callback', @obj.btnRemoveGrid, 'FontSize', 16,'Enable','on' );
                    % previous grid
                    obj.controls.previousGrid(obj.settings.Tabnum) = uicontrol( 'Parent', obj.controls.tab(obj.settings.Tabnum ), 'Style', 'pushbutton', 'Position', [90 7 22 22], ...
                        'String', '<', 'Callback', @obj.btnPreviousGrid, 'FontSize', 11 , 'FontWeight', 'bold', 'Enable', 'on');
                    % next grid
                    obj.controls.nextGrid(obj.settings.Tabnum) = uicontrol( 'Parent', obj.controls.tab(obj.settings.Tabnum ), 'Style', 'pushbutton', 'Position', [180 7 22 22], ...
                        'String', '>', 'Callback', @obj.btnNextGrid, 'FontSize', 11 , 'FontWeight', 'bold', 'Enable', 'off');
                    % Add grid
                    obj.controls.addGrid(obj.settings.Tabnum) = uicontrol( 'Parent', obj.controls.tab(obj.settings.Tabnum ), 'Style', 'pushbutton', 'Position', [120 7 22 22], ...
                        'String', '+', 'Callback', @obj.btnAddGrid, 'FontSize', 12 , 'FontWeight', 'bold', 'Enable', 'on');
                end

                if length(obj.settings.Grids) == 1
                    % remove grid
                    obj.controls.removeGrid(obj.settings.Tabnum) = uicontrol( 'Parent', obj.controls.tab(obj.settings.Tabnum ), 'Style', 'pushbutton', 'Position', [150 7 22 22], ...
                        'String', '-', 'Callback', @obj.btnRemoveGrid, 'FontSize', 16,'Enable','on' );
                    % previous grid
                    obj.controls.previousGrid(obj.settings.Tabnum) = uicontrol( 'Parent', obj.controls.tab(obj.settings.Tabnum ), 'Style', 'pushbutton', 'Position', [90 7 22 22], ...
                        'String', '<', 'Callback', @obj.btnPreviousGrid, 'FontSize', 11 , 'FontWeight', 'bold', 'Enable', 'off');
                    % next grid
                    obj.controls.nextGrid(obj.settings.Tabnum) = uicontrol( 'Parent', obj.controls.tab(obj.settings.Tabnum ), 'Style', 'pushbutton', 'Position', [180 7 22 22], ...
                        'String', '>', 'Callback', @obj.btnNextGrid, 'FontSize', 11 , 'FontWeight', 'bold', 'Enable', 'off');
                    % Add grid
                    obj.controls.addGrid(obj.settings.Tabnum) = uicontrol( 'Parent', obj.controls.tab(obj.settings.Tabnum ), 'Style', 'pushbutton', 'Position', [120 7 22 22], ...
                        'String', '+', 'Callback', @obj.btnAddGrid, 'FontSize', 12 , 'FontWeight', 'bold', 'Enable', 'on');
                end
            end

           
            settings = obj.settings;
            save([obj.settings.currdir '/log_info/settings'], 'settings');

        end

        %add tab
        function btnAddTab( obj, hObject, ~ )

            cd(obj.settings.currdir);

            %if tab is added
            auxtab = get(obj.controls.layout,'SelectedTab');
            auxtab = auxtab.Title;
            obj.settings.Tabnum = str2double(auxtab(end));

            if obj.settings.Tabnum == 3

                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['>! WARNING: Maximum number of Layouts reached!']});
                loggingActions(obj.settings.currdir,3,['>! WARNING: Maximum number of Layouts reached!']);

            else

                if isempty(obj.settings.Grids) %only allow new tab if there are grids in layout previous

                    LogInfo(obj, 1);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},['>! WARNING: Please complete current Layout before creating a new layout.']});
                    loggingActions(obj.settings.currdir,3,['>! WARNING: Please complete current Layout before creating a new layout.']);

                else %create tab

                    numberTabs                    = length(obj.controls.tab) +1;
                    obj.controls.tab(numberTabs)  = uitab( obj.controls.layout, 'Title', ['Layout ' num2str(numberTabs)], 'HandleVisibility','off');
                    %select new tab
                    set(obj.controls.layout,'SelectedTab',obj.controls.tab(numberTabs));

                    %update layout
                    obj.settings.Layout{obj.settings.Tabnum}  = obj.settings.Grids;
                    obj.settings.Tabnum  = numberTabs;
                    %empty grids
                    obj.settings.Grids   = [];
                    obj.settings.Gridnum = 0;
                    %empty hemipshere
                    obj.settings.Hemisphere = cell(1,3);
                    obj.controls.radiobtn3.Value = 0;
                    obj.controls.radiobtn5.Value = 0;
                    obj.controls.radiobtn6.Value = 0;
                    
                    %set remove tab button on
                    set(obj.controls.removeTab,'enable', 'on');

                    %text box
                    obj.controls.txtGrid1(numberTabs) = uicontrol( 'Parent', obj.controls.tab(numberTabs), 'Style', 'text', 'Position', [10 93 230 20], ...
                        'FontSize', 10, 'string', {'Grid settings:'} , 'FontWeight', 'bold', 'HorizontalAlignment', 'left','enable','inactive');

                    %text box label
                    obj.controls.txtGrid2(numberTabs) = uicontrol( 'Parent', obj.controls.tab(numberTabs), 'Style', 'text', 'Position', [10+40 70 80 15], ...
                        'FontSize', 10, 'string', {'Label'} , 'HorizontalAlignment', 'center','enable','inactive');

                    %edit text box label
                    obj.controls.edtGrid2(numberTabs) = uicontrol( 'Parent', obj.controls.tab(numberTabs), 'Style', 'edit', 'Position', [10+40 35 80 36], ...
                        'FontSize', 8, 'string','e.g.: C' , 'HorizontalAlignment', 'center', 'BackgroundColor', 'w' ,'enable','on');

                    %text box grid size
                    obj.controls.txtGrid4(numberTabs) = uicontrol( 'Parent', obj.controls.tab(numberTabs), 'Style', 'text', 'Position', [190-40 70 80 15], ...
                        'FontSize', 10, 'string', {'Size'} , 'HorizontalAlignment', 'center','enable','inactive');

                    %edit text box grid size
                    obj.controls.edtGrid4(numberTabs) = uicontrol( 'Parent', obj.controls.tab(numberTabs), 'Style', 'edit', 'Position', [190-40 35 80 36], ...
                        'FontSize', 8, 'string','e.g.: 4, 8' , 'HorizontalAlignment', 'center', 'BackgroundColor', 'w' ,'enable','on');

                    % Add grid
                    obj.controls.addGrid(numberTabs) = uicontrol( 'Parent', obj.controls.tab(numberTabs), 'Style', 'pushbutton', 'Position', [120 7 22 22], ...
                        'String', '+', 'Callback', @obj.btnAddGrid, 'FontSize', 12 , 'FontWeight', 'bold');

                    % remove grid
                    obj.controls.removeGrid(numberTabs) = uicontrol( 'Parent', obj.controls.tab(numberTabs), 'Style', 'pushbutton', 'Position', [150 7 22 22], ...
                        'String', '-', 'Callback', @obj.btnRemoveGrid, 'FontSize', 16,'Enable','off' );

                    % previous grid
                    obj.controls.previousGrid(numberTabs) = uicontrol( 'Parent', obj.controls.tab(numberTabs), 'Style', 'pushbutton', 'Position', [90 7 22 22], ...
                        'String', '<', 'Callback', @obj.btnPreviousGrid, 'FontSize', 11 , 'FontWeight', 'bold', 'Enable', 'off');

                    % next grid
                    obj.controls.nextGrid(numberTabs) = uicontrol( 'Parent', obj.controls.tab(numberTabs), 'Style', 'pushbutton', 'Position', [180 7 22 22], ...
                        'String', '>', 'Callback', @obj.btnNextGrid, 'FontSize', 11 , 'FontWeight', 'bold', 'Enable', 'off');

                    %log action
                    LogInfo(obj, 1);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> New Layout added. Please add a grid.']});
                    loggingActions(obj.settings.currdir,3,['> New Layout added. Please add a grid.']);

                    settings = obj.settings;
                    save([obj.settings.currdir '/log_info/settings'], 'settings');
                end
            end

            settings = obj.settings;
            save([obj.settings.currdir '/log_info/settings'], 'settings');
        end

        %remove tab
        function btnRemoveTab( obj, hObject, ~ )

            cd(obj.settings.currdir);

            %update layout
            if ~isempty(obj.settings.Grids)
                obj.settings.Layout{obj.settings.Tabnum} = obj.settings.Grids;
                obj.settings.Grids                       = [];
                obj.settings.Gridnum                     = 0;
            end

            %extract tabnum
            auxtab = get(obj.controls.layout,'SelectedTab');
            auxtab = auxtab.Title;
            obj.settings.Tabnum = str2double(auxtab(end));

            if length(obj.controls.tab) > 1 && obj.settings.Tabnum > 1

                %delete last layout saved
                obj.settings.Layout{obj.settings.Tabnum} = [];

                %delete tab and tab object
                obj.controls.tab(obj.settings.Tabnum).Parent    = [];
                obj.controls.tab(obj.settings.Tabnum)           = [];
                obj.controls.edtGrid2(obj.settings.Tabnum)      = [];
                obj.controls.edtGrid4(obj.settings.Tabnum)      = [];
                obj.controls.nextGrid(obj.settings.Tabnum)      = [];
                obj.controls.previousGrid(obj.settings.Tabnum)  = [];
                obj.controls.addGrid(obj.settings.Tabnum)       = [];
                obj.controls.removeGrid(obj.settings.Tabnum)    = [];
                obj.controls.txtGrid1(obj.settings.Tabnum)      = [];
                obj.controls.txtGrid2(obj.settings.Tabnum)      = [];
                obj.controls.txtGrid4(obj.settings.Tabnum)      = [];

                %log action
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Layout ' num2str(obj.settings.Tabnum) ' removed.']});
                loggingActions(obj.settings.currdir,3,['> Layout ' num2str(obj.settings.Tabnum) ' removed.']);

                %update tabnum: select last available tab
                obj.settings.Tabnum = length(obj.controls.tab); %return to last tab as default
                set(obj.controls.layout, 'SelectedTab',obj.controls.tab(end));

            else

                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Layout cannot be removed. Remove grids instead.']});
                loggingActions(obj.settings.currdir,3,['> Layout cannot be removed. Remove grids instead.']);

            end

            %reset layout to the last opened
            if ~isempty(obj.settings.Layout{obj.settings.Tabnum})

                obj.settings.Grids   = obj.settings.Layout{obj.settings.Tabnum}; %set to last by default
                obj.settings.Gridnum = length(obj.settings.Grids);
                gridInfo = split(strtrim(obj.settings.Grids{obj.settings.Gridnum}), ';');
                set(obj.controls.edtGrid2(end),'string', gridInfo{1});
                set(obj.controls.edtGrid4(end),'string', gridInfo{2});
                set(obj.controls.nextGrid(end), 'enable','off');

                if length(obj.settings.Grids)<=1
                    set(obj.controls.previousGrid(end), 'enable','off');
                end

            end

            %disable removeTab if only one exists
            if length(obj.controls.tab) == 1
                set(obj.controls.removeTab, 'Enable', 'off');
            end

            settings = obj.settings;
            save([obj.settings.currdir '/log_info/settings'], 'settings');
        end

        %add grid
        function btnAddGrid( obj, hObject, ~ )

            cd(obj.settings.currdir);

            auxGrid = [get(obj.controls.edtGrid2(obj.settings.Tabnum), 'string') '; '...
                get(obj.controls.edtGrid4(obj.settings.Tabnum), 'string')] ;
            auxGrid = ['    ' auxGrid]; %4 spaces

            %extract tabnum
            auxtab = get(obj.controls.layout,'SelectedTab');
            auxtab = auxtab.Title;
            obj.settings.Tabnum = str2double(auxtab(end));

            if isempty(strtrim(auxGrid)) || strcmp(auxGrid,'    e.g.: C; 4; 8') || strcmp(strtrim(auxGrid), ';')

                set(obj.controls.nextGrid(obj.settings.Tabnum), 'enable', 'off');
                set(obj.controls.edtGrid2(obj.settings.Tabnum), 'string', '  ');
                set(obj.controls.edtGrid4(obj.settings.Tabnum), 'string', '  ');
                disp('! WARNING: Please enter grid settings.');
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'>! WARNING: Please enter grid settings.'});
                loggingActions(obj.settings.currdir,3,' >! WARNING: Please enter grid settings.');

            else

                obj.settings.Gridnum = obj.settings.Gridnum + 1;
                obj.settings.Grids = [obj.settings.Grids, {auxGrid}];
                gridnum = length(obj.settings.Grids);

                set(obj.controls.removeGrid(obj.settings.Tabnum), 'enable', 'on');
                set(obj.controls.nextGrid(obj.settings.Tabnum), 'enable', 'off');
                set(obj.controls.addTab, 'enable','on');

                if length(obj.settings.Grids) < 2
                    set(obj.controls.previousGrid(obj.settings.Tabnum), 'enable', 'off');
                else
                    set(obj.controls.previousGrid(obj.settings.Tabnum), 'enable', 'on');
                end

                settings = obj.settings;
                save([obj.settings.currdir '/log_info/settings'], 'settings');

                %log
                LogInfo(obj,1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Grid ' num2str(gridnum) ' settings: ' obj.settings.Grids{end}]});
                loggingActions(obj.settings.currdir,3,[' > Grid ' num2str(gridnum) ' settings: ' obj.settings.Grids{end}]);
            end

        end

        %remove grid
        function btnRemoveGrid( obj, hObject, ~)

            cd(obj.settings.currdir);

            %remove grid
            if ~isempty(obj.settings.Grids)

                %extract tabnum
                auxtab = get(obj.controls.layout,'SelectedTab');
                auxtab = auxtab.Title;
                obj.settings.Tabnum = str2double(auxtab(end));

                %if only one grid available
                if length(obj.settings.Grids)==1

                    obj.settings.Gridnum                     = 0;
                    obj.settings.Grids                       = [];
                    obj.settings.Layout{obj.settings.Tabnum} = obj.settings.Grids;

                    set(obj.controls.removeGrid(obj.settings.Tabnum), 'enable', 'off');
                    set(obj.controls.nextGrid(obj.settings.Tabnum), 'enable', 'off');
                    set(obj.controls.previousGrid(obj.settings.Tabnum), 'enable', 'off');

                    %log
                    LogInfo(obj, 1);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> All grid settings have been removed.']});
                    loggingActions(obj.settings.currdir,3,[' > All grid settings have been removed.']);
                    set(obj.controls.edtGrid2(obj.settings.Tabnum), 'string', ' ');
                    set(obj.controls.edtGrid4(obj.settings.Tabnum), 'string', ' ');
                    set(obj.controls.addTab, 'enable','off');

                else %multiple grids available: delete the currently selected one

                    auxGrid                                  = obj.settings.Grids(obj.settings.Gridnum);
                    obj.settings.Grids(obj.settings.Gridnum) = []; %shifted all grids to left
                    obj.settings.Layout{obj.settings.Tabnum} = obj.settings.Grids;

                    %if last grid then update gridnum to last
                    if obj.settings.Gridnum > length(obj.settings.Grids)
                        obj.settings.Gridnum = length(obj.settings.Grids);
                    end

                    %set to next grid settings by default
                    gridInfo = split(strtrim(obj.settings.Grids{obj.settings.Gridnum}), ';');
                    set(obj.controls.edtGrid2(obj.settings.Tabnum), 'String', gridInfo{1});
                    set(obj.controls.edtGrid4(obj.settings.Tabnum), 'String', gridInfo{2});

                    %update next/previousGrid buttons
                    if obj.settings.Gridnum == length(obj.settings.Grids) && obj.settings.Gridnum > 1
                        set(obj.controls.nextGrid(obj.settings.Tabnum), 'enable', 'off');
                        set(obj.controls.previousGrid(obj.settings.Tabnum), 'enable', 'on');
                    elseif obj.settings.Gridnum > 1
                        set(obj.controls.nextGrid(obj.settings.Tabnum), 'enable', 'on');
                        set(obj.controls.previousGrid(obj.settings.Tabnum), 'enable', 'on');
                    elseif obj.settings.Gridnum == 1 && length(obj.settings.Grids) > obj.settings.Gridnum
                        set(obj.controls.nextGrid(obj.settings.Tabnum), 'enable', 'on');
                        set(obj.controls.previousGrid(obj.settings.Tabnum), 'enable', 'off');
                    else
                        set(obj.controls.nextGrid(obj.settings.Tabnum), 'enable', 'off');
                        set(obj.controls.previousGrid(obj.settings.Tabnum), 'enable', 'off');
                    end

                    %log
                    LogInfo(obj,1+floor(length(obj.settings.Grids)/4));
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Grid "' auxGrid{1} '" removed. Current grid settings: ' strjoin(obj.settings.Grids,'   ')]});
                    loggingActions(obj.settings.currdir,3,[' > Grid "' auxGrid{1} '" removed. Current grid settings: ' strjoin(obj.settings.Grids,'   ')]);
                end
            end
        end

        %previous grid
        function btnPreviousGrid( obj, hObject, ~)

            if obj.settings.Gridnum > 0

                obj.settings.Gridnum = obj.settings.Gridnum - 1;

                %extract tabnum
                auxtab = get(obj.controls.layout,'SelectedTab');
                auxtab = auxtab.Title;
                obj.settings.Tabnum = str2double(auxtab(end));

                if length(obj.settings.Grids) > 1
                    set(obj.controls.nextGrid(obj.settings.Tabnum), 'enable','on');
                else
                    set(obj.controls.nextGrid(obj.settings.Tabnum), 'enable','off');
                end

                if obj.settings.Gridnum == 1
                    set(obj.controls.previousGrid(obj.settings.Tabnum),'enable','off');
                else
                    set(obj.controls.previousGrid(obj.settings.Tabnum),'enable','on');
                end

                gridInfo = split(strtrim(obj.settings.Grids{obj.settings.Gridnum}),';');
                set(obj.controls.edtGrid2(obj.settings.Tabnum),'string', gridInfo{1});
                set(obj.controls.edtGrid4(obj.settings.Tabnum),'string', gridInfo{2});

                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Grid ' num2str(obj.settings.Gridnum) ' selected: ' obj.settings.Grids{obj.settings.Gridnum}]});
                loggingActions(obj.settings.currdir,3,['> Grid ' num2str(obj.settings.Gridnum) ' selected: ' obj.settings.Grids{obj.settings.Gridnum}]);

            end
        end

        %next grids
        function btnNextGrid( obj, hObject, ~)

            %extract tabnum
            auxtab = get(obj.controls.layout,'SelectedTab');
            auxtab = auxtab.Title;
            obj.settings.Tabnum = str2double(auxtab(end));

            obj.settings.Gridnum = obj.settings.Gridnum + 1;
            gridInfo = split(strtrim(obj.settings.Grids{obj.settings.Gridnum}),';');
            set(obj.controls.edtGrid2(obj.settings.Tabnum),'string', gridInfo{1});
            set(obj.controls.edtGrid4(obj.settings.Tabnum),'string', gridInfo{2});

            if length(obj.settings.Grids) > 1
                set(obj.controls.previousGrid(obj.settings.Tabnum), 'enable','on');
            else
                set(obj.controls.previousGrid(obj.settings.Tabnum), 'enable','off');
            end

            if obj.settings.Gridnum == length(obj.settings.Grids)
                set(obj.controls.previousGrid(obj.settings.Tabnum), 'enable','on');
                set(obj.controls.nextGrid(obj.settings.Tabnum), 'enable','off');
            end

            %log
            LogInfo(obj, 1);
            set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Grid ' num2str(obj.settings.Gridnum) ' selected: ' obj.settings.Grids{obj.settings.Gridnum}]});
            loggingActions(obj.settings.currdir,3,['> Grid ' num2str(obj.settings.Gridnum) ' selected: ' obj.settings.Grids{obj.settings.Gridnum}]);

        end

        %save nifti files
        function checkBoxSaveNii( obj, hObject, ~ )

            cd(obj.settings.currdir);

            obj.settings.saveNii = get(obj.controls.checkBoxSaveNii, 'value');

            %log
            if obj.settings.saveNii
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Save Nifti files selected.']});
                loggingActions(obj.settings.currdir,3,[' > Save Nifti files selected.']);

            else
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Save Nifti files deselected.']});
                loggingActions(obj.settings.currdir,3,[' > Save Nifti files deselected.']);
            end

        end

        %visualize results
        function btnVisualize( obj, hObject, ~ )

            cd(obj.settings.currdir);

            %if no FS
            if ~isfield(obj.settings, 'FS')
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'>! WARNING: Please load a FreeSurfer segmentation!'});
                loggingActions(obj.settings.currdir,3,' >! WARNING: Please load a FreeSurfer segmentation!');
                return;
            end

            %if no hemisphere
            if isempty(obj.settings.Hemisphere{obj.settings.Tabnum})
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'>! WARNING: Please select an Hemisphere!'});
                loggingActions(obj.settings.currdir,3,' >! WARNING: Please select an Hemisphere!');
                return;
            end

            subject = get(obj.controls.edtSbjName, 'String');

            %if subject name is empty
            if isempty(subject) || strcmp(subject,'') || strcmp(subject, 'name...')
                obj.settings.subject = ' ';
                disp('>! WARNING: No name entered.');
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},'>! WARNING: No name entered. Try again!'});
                loggingActions(obj.settings.currdir,3,' >! WARNING: No name entered. Try again!');
                return;

            else
                obj.settings.subject = subject;
                settings = obj.settings;
                save([obj.settings.currdir '/log_info/settings'], 'settings');
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Name entered: ' subject]});
                loggingActions(obj.settings.currdir,3, [ ' > Name entered: ' subject]);
            end

            %check if grid settings were well input
            for g = 1:size(obj.settings.Grids,2)
                grid = obj.settings.Grids{g};
                comas = strfind(grid,';');
                labels = readcell(obj.settings.Labels);
                if isempty(comas)
                    disp(['>! WARNING: Please separate arguments with ; ']);
                    %log
                    LogInfo(obj, 1);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},['>! WARNING: Please separate arguments with ; ']});
                    loggingActions(obj.settings.currdir,3,[' >! WARNING: Please separate arguments with ;  ']);
                    return;

                    %check if grid in the list label
                elseif ~contains( labels, strtrim( grid(1:comas(1)-1) ))

                end
            end

            %apply method
            if strcmp(obj.settings.Method{obj.settings.Tabnum}, 'Method 1 (Hermes et al. 2010)')

                disp(['> Applying ' obj.settings.Method{obj.settings.Tabnum} '... Please wait until a figure with the projected electrodes appears.']);
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Applying ' obj.settings.Method{obj.settings.Tabnum} '... Please wait until a figure with the projected electrodes appears.']});
                loggingActions(obj.settings.currdir,3,[' > Applying ' obj.settings.Method{obj.settings.Tabnum} '... Please wait until a figure with the projected electrodes appears.']);
                pause(1);

                status = runHermes(obj);

                if status==1
                    disp('> Electrode projection completed. Please find the results in ./results/projected_electrodes_coord/.');
                    %log
                    LogInfo(obj, 1);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> Electrode projection completed. Please find the results in ./results/method/hemisphere.'});
                    loggingActions(obj.settings.currdir,3,' > Electrode projection completed. Please find the results in ./results/method/hemisphere.');

                end

            elseif strcmp(obj.settings.Method{obj.settings.Tabnum}, 'Method HD')

                disp(['> Applying ' obj.settings.Method{obj.settings.Tabnum} '... Please wait until a figure with the projected electrodes appears.']);
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Applying ' obj.settings.Method{obj.settings.Tabnum} '... Please wait until a figure with the projected electrodes appears.']});
                loggingActions(obj.settings.currdir,3,[' > Applying ' obj.settings.Method{obj.settings.Tabnum} '... Please wait until a figure with the projected electrodes appears.']);
                pause(1);

                status = runHD(obj);

                if status==1
                    disp('> Electrode projection completed. Please find the results in ./results/method/hemisphere/.');
                    %log
                    LogInfo(obj, 1);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> Electrode projection completed. Please find the results in ./results_HD/projected_electrodes_coord/.'});
                    loggingActions(obj.settings.currdir,3,' > Electrode projection completed. Please find the results in ./results_HD/projected_electrodes_coord/.');

                end

            elseif strcmp(obj.settings.Method{obj.settings.Tabnum}, 'Method sEEG or depth')

                disp(['> Applying ' obj.settings.Method{obj.settings.Tabnum} '... Please wait until a figure with the projected electrodes appears.']);
                %log
                LogInfo(obj, 1);
                set(obj.controls.txtLog, 'string',{obj.settings.str{:},['> Applying ' obj.settings.Method{obj.settings.Tabnum} '... Please wait until a figure with the projected electrodes appears.']});
                loggingActions(obj.settings.currdir,3,[' > Applying ' obj.settings.Method{obj.settings.Tabnum} '... Please wait until a figure with the projected electrodes appears.']);
                pause(1);

                status = runsEEG(obj);

                if status==1
                    disp('> Electrode projection completed. Please find the results in ./results/method/hemisphere/.');
                    %log
                    LogInfo(obj, 1);
                    set(obj.controls.txtLog, 'string',{obj.settings.str{:},'> Electrode projection completed. Please find the results in ./results/method/hemisphere/.'});
                    loggingActions(obj.settings.currdir,3,' > Electrode projection completed. Please find the results in ./results/method/hemisphere/.');

                end

            end

            %save changes in settings mat file
            settings = obj.settings;
            save([obj.settings.currdir '/log_info/settings'], 'settings');

        end

    end
end
