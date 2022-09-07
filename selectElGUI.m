classdef selectElGUI < handle
    properties
        extraFig
        controls
        settings
        labels
    end
    
    methods
        
        function obj = selectElGUI( varargin )
            
            obj.settings = varargin{1};
            obj.controls = varargin{2};
            
            obj.settings.electrode_i = 1;
           
            if ~isfield(obj.settings, 'Labels') || isempty(obj.settings.Labels)
                errordlg('Please enter *.txt file with electrode labels in Step 2!');
                close(f);
                return;
            else
                obj.labels = readcell(obj.settings.Labels);
            end

            %get user input
            screenSize = get(0,'ScreenSize');
            width		= 500;
            height		= 950;
            windowPosition2 = [ round((screenSize(3)-width)), screenSize(4)-height-100, 250, 420];
            
            obj.extraFig = figure( 'Name', 'Select electrodes','OuterPosition', windowPosition2, 'Menu', 'none', ...
                'NumberTitle', 'off', 'Color', get(0,'DefaultUIControlBackgroundColor'), 'Resize', 'off', 'CloseRequestFcn', @obj.figCloseRequest);
            
            %button 1: select electrode
            obj.controls.btnSelectEl = uicontrol( 'Parent', obj.extraFig, 'Style', 'pushbutton', 'Position', [50 290 150 50], ...
                'String', 'Select electrode', 'Callback', @obj.btnSelectEl, 'FontSize', 11 , 'FontWeight', 'bold');
            
            %button 2: select sphere
            obj.controls.btnSelectSphere = uicontrol( 'Parent', obj.extraFig, 'Style', 'pushbutton', 'Position', [50 230 150 50 ], ...
                'String', 'Set sphere', 'Callback', @obj.btnSelectSphere, 'FontSize', 11 , 'FontWeight', 'bold');
            
            %edit box: goto electrode
            obj.controls.edtGotoEl = uicontrol( 'Parent', obj.extraFig, 'Style', 'edit', 'Position', [125 185 60 30], ...
                'FontSize', 11, 'string', {' '} ,'Callback', @obj.edtGotoEl,  'HorizontalAlignment', 'center', 'BackgroundColor', 'w' ,'enable','on');
            
            %text box goto electrode
            obj.controls.txtGotoEl = uicontrol( 'Parent', obj.extraFig, 'Style', 'text', 'Position', [30 157 90 60], ...
                'FontSize', 11, 'string', {'Go to electrode:'} , 'HorizontalAlignment', 'left','enable','inactive','FontWeight', 'bold');
            
            %button goto electrode
            obj.controls.btnGotoEl = uicontrol( 'Parent', obj.extraFig, 'Style', 'pushbutton', 'Position', [190 185 30 30 ], ...
                'String', '>>','Callback', @obj.edtGotoEl, 'FontSize', 11 , 'FontWeight', 'bold');
            
            %text current electrode
            obj.controls.txtCurrentEl = uicontrol( 'Parent', obj.extraFig, 'Style', 'text', 'Position', [45 335 223 35], ...
                'FontSize', 13, 'string', ['Select: ' obj.labels{1}] , 'HorizontalAlignment', 'left','enable','inactive','FontWeight', 'bold');
            
            %button delete cluster
            obj.controls.btnDeleteCluster = uicontrol( 'Parent', obj.extraFig, 'Style', 'pushbutton', 'Position', [50 110 150 50 ], ...
                'String', 'Delete Cluster', 'Callback', @obj.btnDeleteCluster, 'FontSize', 11 , 'FontWeight', 'bold', 'ForegroundColor', [0.7 0 0]);
            
            %button 3: quit
            obj.controls.btnQuit = uicontrol( 'Parent', obj.extraFig, 'Style', 'pushbutton', 'Position', [50 30 150 50 ], ...
                'String', 'Finished!', 'Callback', @obj.btnQuit, 'FontSize', 18 , 'FontWeight', 'bold', 'ForegroundColor', [0 0.6 0]);
                    
        end
         
    end
    
    %callbacks
    methods
        
        % Close request function for the extra dialog.
        function figCloseRequest( obj, hObject, ~ )
            delete( hObject );
        end
                
        %Select one electrode
        function btnSelectEl( obj, hObject, ~ )
            
            %for just return, advance to next entry
            electrode_i = obj.settings.electrode_i;
            system(['tcsh select_electrode.csh -electrode_i ' num2str(electrode_i) ' -afni_sphere "" ']);
            
            if obj.settings.electrode_i > length(obj.labels) %if list completed
                obj.settings.electrode_i = obj.settings.electrode_i - 1;
                set(obj.controls.txtCurrentEl, 'String','Select: complete!');

                %log after select electrodes
                str = get(obj.controls.txtLog, 'string');
                if length(str)>=obj.settings.NUM_LINES
                    str = str( (end - (obj.settings.NUM_LINES-1)) :end);
                end
                set(obj.controls.txtLog, 'string',{str{:}, '> Electrode list completed!'});
                loggingActions(obj.settings.currdir,2,' > Electrode list completed!');

            else
                obj.settings.electrode_i = obj.settings.electrode_i + 1;
                set(obj.controls.txtCurrentEl, 'String',['Select: ' obj.labels{obj.settings.electrode_i}]);

                %log after select electrodes
                str = get(obj.controls.txtLog, 'string');
                if length(str)>=obj.settings.NUM_LINES
                    str = str( (end - (obj.settings.NUM_LINES-1)) :end);
                end
                set(obj.controls.txtLog, 'string',{str{:}, ['> Electrode ' obj.labels{obj.settings.electrode_i} ' selected.']});
                loggingActions(obj.settings.currdir,2,[' > Electrode ' obj.labels{obj.settings.electrode_i} ' selected.']);
            end            
            
        end
        
        %Select one electrode
        function btnDeleteCluster( obj, hObject, ~ )
            
            %for just return, advance to next entry
            system(['tcsh delete_cluster.csh']);
                        
            str = get(obj.controls.txtLog, 'string');
            if length(str)>=obj.settings.NUM_LINES
                str = str( (end - (obj.settings.NUM_LINES-1)) :end);
            end
            set(obj.controls.txtLog, 'string',{str{:}, ['> Cluster deleted...']});
            loggingActions(obj.settings.currdir,2,[' > Cluster deleted...']);
            
        end
        
        %Select one electrode with sphere
        function btnSelectSphere( obj, hObject, ~ )
        
            afni_sphere = 'A';
            electrode_i = obj.settings.electrode_i;
            system(['tcsh select_electrode.csh -electrode_i ' num2str(electrode_i) ' -afni_sphere ' afni_sphere]);
            
            
            if obj.settings.electrode_i > length(obj.labels) %if list completed
                obj.settings.electrode_i = obj.settings.electrode_i - 1;
                set(obj.controls.txtCurrentEl, 'String','Select: complete!');

                %log after select electrodes
                str = get(obj.controls.txtLog, 'string');
                if length(str)>=obj.settings.NUM_LINES
                    str = str( (end - (obj.settings.NUM_LINES-1)) :end);
                end
                set(obj.controls.txtLog, 'string',{str{:}, '> Electrode list completed!'});
                loggingActions(obj.settings.currdir,2,' > Electrode list completed!');

            else
                obj.settings.electrode_i = obj.settings.electrode_i + 1;
                set(obj.controls.txtCurrentEl, 'String',['Select: ' obj.labels{obj.settings.electrode_i}]);

                %log after select electrodes
                str = get(obj.controls.txtLog, 'string');
                if length(str)>=obj.settings.NUM_LINES
                    str = str( (end - (obj.settings.NUM_LINES-1)) :end);
                end
                set(obj.controls.txtLog, 'string',{str{:}, ['> Electrode ' obj.labels{obj.settings.electrode_i-1} ' selected.']});
                loggingActions(obj.settings.currdir,2,[' > Electrode ' obj.labels{obj.settings.electrode_i-1} ' selected.']);
            end
        end
        
        %Go to electrode #
        function edtGotoEl( obj, hObject, ~ )
            
            Labelstr = get(obj.controls.edtGotoEl, 'string');
            
            if  Labelstr~= " " && ~isempty(Labelstr) && ~isempty(find(contains(obj.labels,strtrim(Labelstr)) == 1))
                
                obj.settings.electrode_i = find(contains(obj.labels,strtrim(Labelstr)) == 1, 1,'first');
                set(obj.controls.txtCurrentEl, 'String',['Select: ' obj.labels{obj.settings.electrode_i}]);
                
                %log after select electrodes
                str = get(obj.controls.txtLog, 'string');
                if length(str)>=obj.settings.NUM_LINES
                    str = str( (end - (obj.settings.NUM_LINES-1)) :end);
                end
                set(obj.controls.txtLog, 'string',{str{:}, ['> Go to electrode ' obj.labels{obj.settings.electrode_i} '.']});
                loggingActions(obj.settings.currdir,2,[' > Go to electrode ' obj.labels{obj.settings.electrode_i} '.']);
            
            else
                set(obj.controls.txtCurrentEl, 'String','Select: ...' );
                set(obj.controls.edtGotoEl, 'String',[' ']);
                %log after select electrodes
                str = get(obj.controls.txtLog, 'string');
                if length(str) >= obj.settings.NUM_LINES
                    str = str( (end - (obj.settings.NUM_LINES-1)) :end);
                end
                set(obj.controls.txtLog, 'string',{str{:}, ['> ! ERROR: Invalid electrode label.']});
                loggingActions(obj.settings.currdir,2,[' > ! ERROR: Invalid electrode label.']);
            end
            
        end
        
        %quit program
        function btnQuit(obj, hObject, ~ )
            
            %log after select electrodes
            str = get(obj.controls.txtLog, 'string');
            if length(str)>=obj.settings.NUM_LINES
                str = str( (end - (obj.settings.NUM_LINES-1)) :end);
            end
            set(obj.controls.txtLog, 'string',{str{:}, '> Centers-of-mass extracted. Quitting program now...Please wait until AFNI and SUMA close.'});
            loggingActions(obj.settings.currdir,2,' > Centers-of-mass extracted. Quitting program now...Please wait until AFNI and SUMA close.');

            delete( obj.extraFig );
            
            system(['tcsh indexify_electrodes.csh ./surf_ixyz.1D 3dclusters_r' num2str(obj.settings.R) '_is' num2str(obj.settings.IS) '_thr' num2str(obj.settings.CV) '.nii']);
            
            system(['@Quiet_Talkers']);

            clc;
            
            %move back to main folder
            cd(obj.settings.currdir);
            
            
        end
        
    end
    
end