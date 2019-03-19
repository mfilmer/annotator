classdef application < handle
    properties
        % UI elements
        window;         % Main UI figure
        fileList;       % fileList object
        tabGroup;       % Tab group for each image
        tabs;           % Each tab
        buttonPanel;    % Image editor buttons
        editors;        % Each editor object, one per tab
        buttons = [];   % Annotation buttons in the annotation panel, listed from top down
        scalePanel;     % Panel holding scale setting controls
        scaleControls;  % Struct of controls on the scale panel
        keyStatus;      % Struct containing desired modifier key states
    end
    properties
        buttonHeight = 25;
        buttonWidth = 75;
        editHeight = 22;
        buttonVStep = 25;
        fileListWidth = 250;
        buttonPanelWidth = 150;
        buttonPanelHeight = 300;
        scalePanelHeight = 100;
        minWidth = 600;
        minHeight = 300;
    end
    methods
        function this = application()
            % Set window dimensions
            X = 200;
            Y = 30;
            width = 1024;
            height = 600;
            
            % Initialize key states
            this.keyStatus.shift = 0;
            
            % Determine screen size so our window is positioned in the
            % center of the screen
            scr = get(0, 'ScreenSize');
            sWidth = scr(3);
            sHeight = scr(4);
            Y = (sHeight - height)/2;
            X = (sWidth - width)/2;
            
            % Create UI Elements
            this.window = figure('Position', [X, Y, width, height], 'MenuBar', 'none', ...
                'ResizeFcn', @(src,eventdata) this.redrawWindow(), ...
                'WindowButtonMotionFcn', @(~,~) this.mouseMove_CB(), ...
                'WindowScrollWheelFcn', @(~,eventdata) this.mouseScroll_CB(eventdata), ...
                'WindowButtonUpFcn', @(~,~) this.mouseUp_CB(), ...
                'WindowKeyPressFcn', @(~,eventdata) this.keyChange_CB(eventdata.Key, 1), ...
                'WindowKeyReleaseFcn', @(~,eventdata) this.keyChange_CB(eventdata.Key, 0));
            this.fileList = fileList(this.window);
            this.fileList.fileOpenCB = @this.openFile_CB;
            this.tabGroup = uitabgroup(this.window, 'Units', 'pixels');
            this.buttonPanel = uipanel(this.window, 'Units', 'pixels');
            this.scalePanel = uipanel(this.window, 'Units', 'pixels');
            
            % Annotation panel buttons
            this.buttons = uicontrol('Parent', this.buttonPanel, 'Style', 'togglebutton', 'String', 'Distance', 'Callback', @(src,~) this.selectTool_CB(src, tools.Distance));
            this.buttons(end+1) = uicontrol('Parent', this.buttonPanel, 'Style', 'togglebutton', 'String', 'Set Scale', 'Callback', @(src,~) this.selectTool_CB(src, tools.SetScale));
            this.buttons(end+1) = uicontrol('Parent', this.buttonPanel, 'Style', 'togglebutton', 'String', 'Scalebar', 'Callback', @(src,~) this.selectTool_CB(src, tools.Scalebar));
            
            % Scale panel controls. These don't move
            this.scaleControls.lengthLabel = uicontrol('Parent', this.scalePanel, 'Style', 'text', 'String', 'Length', 'HorizontalAlignment', 'left', 'Position', [2,this.editHeight-6, this.buttonWidth, this.editHeight]);
            this.scaleControls.lengthBox = uicontrol('Parent', this.scalePanel, 'Style', 'edit', 'String', '500', 'HorizontalAlignment', 'right', 'Position', [2,2,92,this.editHeight]);
            this.scaleControls.unitRing = uicontrol('Parent', this.scalePanel, 'Style', 'popupmenu', 'String', {'km', 'm', 'mm', 'um', 'nm'}, 'Value', 5, 'Position', [2+92+1,2,50,this.editHeight]);
            
            % Position UI elements
            this.redrawWindow();
        end
        
        function redrawWindow(this)
            if(~isempty(this.window))
                % Get window location and dimensions
                pos = get(this.window, 'Position');
                width = pos(3);
                height = pos(4);
                
                % Enforce minimum window size
                if width < this.minWidth
                    width = this.minWidth;
                end
                if height < this.minHeight
                    height = this.minHeight;
                end
                
                % Move elements
                this.fileList.setPosition([0, 0, this.fileListWidth, height]);
                this.tabGroup.Position = [this.fileListWidth, 0, width-this.fileListWidth-this.buttonPanelWidth, height];
                this.buttonPanel.Position = [width-this.buttonPanelWidth,height-this.buttonPanelHeight,this.buttonPanelWidth, this.buttonPanelHeight];
                this.scalePanel.Position = [width-this.buttonPanelWidth,0,this.buttonPanelWidth, this.scalePanelHeight];
                
                % Position button panel buttons
                for i = 1:length(this.buttons)
                    button = this.buttons(i);
                    button.Position = [0, this.buttonPanelHeight-this.buttonHeight-this.buttonVStep*(i-1)-2, this.buttonPanelWidth-3, this.buttonHeight];
                end
                
                % Scale panel controls
                % These remain in a constant position on their panel so
                % there positions are given at creation
            end
        end
        
        function keyChange_CB(this, key, state)
            switch key
                case 'shift'
                    this.keyStatus.shift = state;
            end
        end
        
        % Called when the tab changes
        function tabChange_CB(this)
            % Update scale bar settings panel
        end
        
        function selectTool_CB(this, src, tool)
            % Check if button is up or down
            if(src.Value)
                % Button is down: reset all other buttons
                for button = this.buttons
                    if (button ~= src)
                        button.Value = 0;
                    end
                end
            else
                % Button is up: we selected the None tool
                tool = tools.None;
            end
            
            % Call the editor tool selection callback
           editor = this.getCurrentEditor();
           if(~isempty(editor))
               editor.activateTool(tool);
           end
        end
        
        function mouseMove_CB(this)
            editor = this.getCurrentEditor();
            if(~isempty(editor))
                editor.mouseMove();
            end
        end
        
        function mouseUp_CB(this)
            editor = this.getCurrentEditor();
            if(~isempty(editor))
                editor.buttonUp_CB();
            end
        end
        
        function mouseScroll_CB(this, eventdata)
            editor = this.getCurrentEditor();
            if(~isempty(editor))
                editor.scrollZoom(eventdata.VerticalScrollCount);
            end
        end
        
        function openFile_CB(this, name)
            this.openFile(name)
        end
        
        % Open a file in a new editor tab
        function openFile(this, fullname)
            [~, name, ext] = fileparts(fullname);
            
            % Create new tab
            t = uitab(this.tabGroup, 'Title', [name, ext]);
            
            % Create new editor for the tab
            if(isempty(this.editors))
                this.editors = editor(this, t, fullname);
            else
                this.editors(end+1) = editor(this, t, fullname);
            end
        end
    end
    
    methods (Access = private)
        function editor = getCurrentEditor(this)
            editor = [];
            numTabs = length(this.tabGroup.Children);
            if(numTabs)
                selTabIndex = this.tabGroup.SelectedTab == this.tabGroup.Children;
                editor = this.editors(selTabIndex);
            end
        end
    end
end
