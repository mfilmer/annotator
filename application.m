classdef application < handle
    properties
        window;         % Main UI figure
        fileList;       % fileList object
        tabGroup;       % Tab group for each image
        tabs;           % Each tab
        buttonPanel;    % Image editor buttons
        editors;        % Each editor object, one per tab
    end
    properties
        buttonWidth = 75;
        buttonHeight = 20;
        fileListWidth = 250;
        buttonPanelWidth = 150;
        minWidth = 600;
        minHeight = 300;
    end
    methods
        function this = application()
            % Set window dimensions
            X = 400;
            Y = 100;
            width = 1024;
            height = 760;
            
            % Create UI Elements
            this.window = figure('Position', [X, Y, width, height], 'ResizeFcn', @(src,eventdata) this.redrawWindow());
            this.fileList = fileList(this.window);
            this.tabGroup = uitabgroup(this.window, 'Units', 'pixels');
            this.tabs = uitab(this.tabGroup, 'Title', 'aoeu');
            this.buttonPanel = uipanel(this.window, 'Units', 'pixels');
            uicontrol('Parent', this.buttonPanel, 'Style', 'pushbutton', 'String', 'aoeu');
            
            % Position UI elements
            this.redrawWindow();
        end
        
        function redrawWindow(this)
            if(~isempty(this.window))
                % Get window location and dimensions
                pos = get(this.window, 'Position');
                X = pos(1);
                Y = pos(2);
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
                %set(this.window, 'Position', [X, Y, width, height]);
                this.fileList.setPosition([0, 0, this.fileListWidth, height]);
                set(this.tabGroup, 'Position', [this.fileListWidth, 0, width-this.fileListWidth-this.buttonPanelWidth, height]);
                set(this.buttonPanel, 'Position', [width-this.buttonPanelWidth,0,this.buttonPanelWidth, height]);
            end
        end
        
        function h = newButton(this, parent, pos, label)
            h = uicontrol('Parent', parent, 'String', label, ...
                'Style', 'pushbutton', ...
                'Position', [pos, this.buttonWidth, this.buttonHeight]);
        end
    end
end
