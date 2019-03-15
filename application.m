classdef application < handle
    properties
        % UI elements
        window;         % Main UI figure
        fileList;       % fileList object
        tabGroup;       % Tab group for each image
        tabs;           % Each tab
        buttonPanel;    % Image editor buttons
        editors;        % Each editor object, one per tab
        buttons = [];   % Buttons in the button panel, listed from top down
        
        % Data
        currentDir;     % Current directory
    end
    properties
        buttonHeight = 25;
        buttonVStep = 25;
        fileListWidth = 250;
        buttonPanelWidth = 150;
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
            
            % Create UI Elements
            this.window = figure('Position', [X, Y, width, height], 'MenuBar', 'none', ...
                'ResizeFcn', @(src,eventdata) this.redrawWindow());
            this.fileList = fileList(this.window);
            this.tabGroup = uitabgroup(this.window, 'Units', 'pixels');
            this.tabs = uitab(this.tabGroup, 'Title', 'aoeu');
            this.buttonPanel = uipanel(this.window, 'Units', 'pixels');
            
            % Button panel buttons
            this.buttons(end+1) = uicontrol('Parent', this.buttonPanel, 'Style', 'pushbutton', 'String', 'Distance');
            this.buttons(end+1) = uicontrol('Parent', this.buttonPanel, 'Style', 'pushbutton', 'String', 'Rectangle');
            this.buttons(end+1) = uicontrol('Parent', this.buttonPanel, 'Style', 'pushbutton', 'String', 'Polygon');
            this.buttons(end+1) = uicontrol('Parent', this.buttonPanel, 'Style', 'pushbutton', 'String', 'Angle');
            
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
                set(this.tabGroup, 'Position', [this.fileListWidth, 0, width-this.fileListWidth-this.buttonPanelWidth, height]);
                set(this.buttonPanel, 'Position', [width-this.buttonPanelWidth,0,this.buttonPanelWidth, height]);
                
                % Position button panel buttons
                for i = 1:length(this.buttons)
                    button = this.buttons(i);
                    set(button, 'Position', [0, height-this.buttonHeight-this.buttonVStep*(i-1)-2, this.buttonPanelWidth-3, this.buttonHeight]);
                end
            end
        end
        
        function openDirectory(this)
            newDir = uigetdir(this.currentDir, 'Select Working Directory');
            if (newDir)
                this.currentDir = newDir;
            end
        end
        
        function h = newButton(this, parent, pos, label)
            h = uicontrol('Parent', parent, 'String', label, 'Style', 'pushbutton', ...
                'Position', [pos, this.buttonWidth, this.buttonHeight]);
        end
    end
end
