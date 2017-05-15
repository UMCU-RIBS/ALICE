classdef selectElGUI < handle
    properties
        extraFig
        controls
        settings
    end
    
    methods
        
        function obj = selectElGUI( varargin )
            
            obj.settings = varargin{1};
            obj.controls = varargin{2};
            
            obj.settings.electrode_i = 1;
            
            %get user input
            screenSize = get(0,'ScreenSize');
            width		= 500;
            height		= 950;
            windowPosition2 = [ round((screenSize(3)-width)), screenSize(4)-height-100, 250, 320];
            
            obj.extraFig = figure( 'Name', 'Select electrodes','OuterPosition', windowPosition2, 'Menu', 'none', ...
                'NumberTitle', 'off', 'Color', get(0,'DefaultUIControlBackgroundColor'), 'Resize', 'off', 'CloseRequestFcn', @obj.figCloseRequest );
            
            %button 1: select electrode
            obj.controls.btnSelectEl = uicontrol( 'Parent', obj.extraFig, 'Style', 'pushbutton', 'Position', [50 190 150 50], ...
                'String', 'Select electrode', 'Callback', @obj.btnSelectEl, 'FontSize', 11 , 'FontWeight', 'bold');
            %button 2: select sphere
            obj.controls.btnSelectSphere = uicontrol( 'Parent', obj.extraFig, 'Style', 'pushbutton', 'Position', [50 130 150 50 ], ...
                'String', 'Set sphere', 'Callback', @obj.btnSelectSphere, 'FontSize', 11 , 'FontWeight', 'bold');
            %edit box: goto electrode
            obj.controls.edtGotoEl = uicontrol( 'Parent', obj.extraFig, 'Style', 'edit', 'Position', [125 85 60 30], ...
                'FontSize', 11, 'string', {' '} ,'Callback', @obj.edtGotoEl,  'HorizontalAlignment', 'center', 'BackgroundColor', 'w' ,'enable','on');
            %text box goto electrode
            obj.controls.txtGotoEl = uicontrol( 'Parent', obj.extraFig, 'Style', 'text', 'Position', [30 57 90 60], ...
                'FontSize', 11, 'string', {'Go to electrode:'} , 'HorizontalAlignment', 'left','enable','inactive','FontWeight', 'bold');
            %button goto electrode
            obj.controls.btnGotoEl = uicontrol( 'Parent', obj.extraFig, 'Style', 'pushbutton', 'Position', [190 85 30 30 ], ...
                'String', '>>','Callback', @obj.edtGotoEl, 'FontSize', 11 , 'FontWeight', 'bold');
            %text current electrode
            obj.controls.txtCurrentEl = uicontrol( 'Parent', obj.extraFig, 'Style', 'text', 'Position', [20 245 200 30], ...
                'FontSize', 13, 'string', {'Select electrode: 1'} , 'HorizontalAlignment', 'left','enable','inactive','FontWeight', 'bold');
            %button 3: quit
            obj.controls.btnQuit = uicontrol( 'Parent', obj.extraFig, 'Style', 'pushbutton', 'Position', [50 10 150 50 ], ...
                'String', 'Quit', 'Callback', @obj.btnQuit, 'FontSize', 18 , 'FontWeight', 'bold', 'ForegroundColor', [0.5 0 0]);
                    
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
            
            obj.settings.electrode_i = obj.settings.electrode_i +1;
            set(obj.controls.txtCurrentEl, 'String',['Select electrode: ' num2str(obj.settings.electrode_i)]);
            
            %log after select electrodes
            str = get(obj.controls.txtLog, 'string');
            if length(str)>=obj.settings.NUM_LINES
                str = str( (end - (obj.settings.NUM_LINES-1)) :end);
            end
            set(obj.controls.txtLog, 'string',{str{:}, ['> Electrode ' num2str(obj.settings.electrode_i-1) ' selected.']});
            loggingActions(obj.settings.currdir,2,[' > Electrode ' num2str(obj.settings.electrode_i-1) ' selected.']);
            
        end
        
        %Select one electrode with sphere
        function btnSelectSphere( obj, hObject, ~ )
        
            afni_sphere = 'A';
            electrode_i = obj.settings.electrode_i;
            system(['tcsh select_electrode.csh -electrode_i ' num2str(electrode_i) ' -afni_sphere ' afni_sphere]);
            
            obj.settings.electrode_i = obj.settings.electrode_i +1;
            set(obj.controls.txtCurrentEl, 'String',['Select electrode: ' num2str(obj.settings.electrode_i)]);
            
            %log after select electrodes
            str = get(obj.controls.txtLog, 'string');
            if length(str)>=obj.settings.NUM_LINES
                str = str( (end - (obj.settings.NUM_LINES-1)) :end);
            end
            set(obj.controls.txtLog, 'string',{str{:}, ['> Electrode ' num2str(obj.settings.electrode_i-1) ' selected.']});
            loggingActions(obj.settings.currdir,2,[' > Electrode ' num2str(obj.settings.electrode_i-1) ' selected.']);

        end
        
        %Go to electrode #
        function edtGotoEl( obj, hObject, ~ )
            
            str = get(obj.controls.edtGotoEl, 'string');
            
            if isinteger(uint8(str2num(str{1}))) && ~isempty(str2num(str{1}))
                obj.settings.electrode_i = str2num(str{1});
                set(obj.controls.txtCurrentEl, 'String',['Select electrode: ' num2str(obj.settings.electrode_i)]);
                
                %log after select electrodes
                str = get(obj.controls.txtLog, 'string');
                if length(str)>=obj.settings.NUM_LINES
                    str = str( (end - (obj.settings.NUM_LINES-1)) :end);
                end
                set(obj.controls.txtLog, 'string',{str{:}, ['> Go to electrode ' num2str(obj.settings.electrode_i) '.']});
                loggingActions(obj.settings.currdir,2,[' > Go to electrode ' num2str(obj.settings.electrode_i) '.']);
            else
                set(obj.controls.edtGotoEl, 'String',[' ']);
                %log after select electrodes
                str = get(obj.controls.txtLog, 'string');
                if length(str)>=obj.settings.NUM_LINES
                    str = str( (end - (obj.settings.NUM_LINES-1)) :end);
                end
                set(obj.controls.txtLog, 'string',{str{:}, ['> ! ERROR: Invalid electrode number. Integer values only.']});
                loggingActions(obj.settings.currdir,2,[' > ! ERROR: Invalid electrode number. Integer values only.']);
            end
            
        end
        
        %quit program
        function btnQuit(obj, hObject, ~ )
            
            %log after select electrodes
            str = get(obj.controls.txtLog, 'string');
            if length(str)>=obj.settings.NUM_LINES
                str = str( (end - (obj.settings.NUM_LINES-1)) :end);
            end
            set(obj.controls.txtLog, 'string',{str{:}, '> Centers-of-masses extracted. Quitting program now...Please wait until AFNI and SUMA close.'});
            loggingActions(obj.settings.currdir,2,' > Centers-of-masses extracted. Quitting program now...Please wait until AFNI and SUMA close.');

            delete( obj.extraFig );
            
            system(['tcsh indexify_electrodes.csh ./surf_ixyz.1D 3dclusters_r' num2str(obj.settings.R) '_is' num2str(obj.settings.IS) '_thr' num2str(obj.settings.CV) '.nii']);
            
            system(['@Quiet_Talkers']);

            clc;
            
            %move back to main folder
            cd(obj.settings.currdir);
            
            
        end
        
    end
    
end