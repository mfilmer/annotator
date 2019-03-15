classdef fileList < handle
    properties (Access = protected)
        % UI Elements
        parent;
        panel;
        list;
        dirSelectButton;
        upDirButton;
        openFileButton;
        closeFileButton;
        filterBox;
        
        % Data
        currentDir;
    end
    properties    
        % User callbacks
        fileSelectCB;
        fileOpenCB;     % Takes 2 parameters: Selected file index, and selected file name
        fileCloseCB;    % Takes 2 parameters: Selected file index, and selected file name
    end
    properties
        buttonHeight = 25;
        textHeight = 25;
    end
    methods
        function this = fileList(parent)
            this.parent = parent;
            
            % Create UI elements
            this.panel = uipanel(parent, 'Units', 'pixels');
            this.dirSelectButton = uicontrol('Parent', this.panel, 'String', 'Directory', 'Callback', @(src, eventdata) this.openDir());
            this.upDirButton = uicontrol('Parent', this.panel, 'String', 'Up', 'Callback', @(src, eventdata) this.upDir());
            this.openFileButton = uicontrol('Parent', this.panel, 'String', 'Open', 'Callback', @(src, eventdata) this.fileOpenCB(this.list.Value, this.list.String{this.list.Value}));
            this.closeFileButton = uicontrol('Parent', this.panel, 'String', 'Close', 'Callback', @(src, eventdata) this.fileCloseCB(this.list.Value, this.list.String{this.list.Value}));
            this.filterBox = uicontrol('Parent', this.panel, 'Style', 'edit', 'String', '.+\..+');
            this.list = uicontrol('Parent', this.panel, 'Style', 'listbox', 'Callback', @(~, ~) this.listItemClick_CB());
        end
        
        function listItemClick_CB(this)
            value = this.list.Value;
            selType = get(gcf, 'selectiontype');
            switch selType
                case 'normal'
                    this.fileSelectCB(value, this.list.String{value});
                case 'open'
                    this.fileOpenCB(value, this.list.String{value});
            end
        end
        
        function setPosition(this, pos)
            width = pos(3);
            height = pos(4);
            
            set(this.panel, 'Position', pos);
            set(this.dirSelectButton, 'Position', [0, height-this.buttonHeight, width/2-2, this.buttonHeight-2]);
            set(this.upDirButton, 'Position', [width/2-1, height-this.buttonHeight, width/2-2, this.buttonHeight-2]);
            set(this.openFileButton, 'Position', [0, height-this.buttonHeight*2, width/2-2, this.buttonHeight-2]);
            set(this.closeFileButton, 'Position', [width/2-1, height-this.buttonHeight*2, width/2-2, this.buttonHeight-2]);
            set(this.filterBox, 'Position', [1, height-this.buttonHeight*2-this.textHeight, width-5, this.buttonHeight]);
            set(this.list, 'Position', [0, 0, width, height-this.buttonHeight*2-this.textHeight-3]);
        end
        
        function openDir(this)
            newDir = uigetdir(this.currentDir, 'Select Working Directory');
            if (newDir)
                % Update directory
                this.currentDir = newDir;
                
                % Get regex pattern
                pattern = this.filterBox.String;
                allFiles = dir(this.currentDir);
                
                % Populate list
                names = {};
                % Include '..' manually
                for i = 1:length(allFiles)
                    file = allFiles(i);
                    
                    % Exclude '.' and '..'
                    if(strcmp('.', file.name))
                        continue;
                    end
                    if(strcmp('..', file.name))
                        continue;
                    end
                    
                    index = regexp(file.name, pattern, 'once');
                    
                    if(~isempty(index))
                        names{end+1} = file.name;
                    end
                end
                this.list.String = names;
                this.list.Value = 1;
            end
        end
        
        function this.upDir()
        end
        
        function this.openFile()
        end
        
        function this.closeFile()
        end
    end
end
