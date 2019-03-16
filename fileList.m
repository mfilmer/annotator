classdef fileList < handle
    properties
        % User callbacks
        fileSelectCB;
        fileOpenCB;
        fileCloseCB;
    end
    properties (Access = protected)
        % UI Elements
        parent;
        panel;
        dirSelectButton;
        upDirButton;
        openFileButton;
        closeFileButton;
        filterBox;
        dirListbox;
        fileListbox;
        
        % Data
        currentDir;
    end
    properties (Access = private)
        buttonHeight = 25;
        textHeight = 25;
        dirListHeight = 150;
    end
    methods
        function this = fileList(parent)
            this.parent = parent;
            
            % Create UI elements
            this.panel = uipanel(parent, 'Units', 'pixels');
            this.dirSelectButton = uicontrol('Parent', this.panel, 'String', 'Directory', 'Callback', @(src, eventdata) this.openDir_UI());
            this.upDirButton = uicontrol('Parent', this.panel, 'String', 'Up', 'Callback', @(src, eventdata) this.upDir());
            this.openFileButton = uicontrol('Parent', this.panel, 'String', 'Open', 'Callback', @(~, ~) this.openFile());
            this.closeFileButton = uicontrol('Parent', this.panel, 'String', 'Close', 'Callback', @(~, ~) this.closeFile());
            this.filterBox = uicontrol('Parent', this.panel, 'Style', 'edit', 'String', '.+\..+', 'Callback', @(~, ~) this.refreshLists());
            this.dirListbox = uicontrol('Parent', this.panel, 'Style', 'listbox', 'Callback', @(~, ~) this.dirItemClick_CB());
            this.fileListbox = uicontrol('Parent', this.panel, 'Style', 'listbox', 'Callback', @(~, ~) this.fileItemClick_CB());
        end
        
        function dirItemClick_CB(this)
            value = this.dirListbox.Value;
            name = this.dirListbox.String{value};
            selType = get(gcf, 'selectiontype');
            switch selType
                case 'normal'   % Single click
                case 'open'     % Double click
                    this.openDir(fullfile(this.currentDir, name));
            end
        end
        
        function fileItemClick_CB(this)
            selType = get(gcf, 'selectiontype');
            switch selType
                case 'normal'   % Single click
                    this.selectFile();
                case 'open'     % Double click
                    this.openFile();
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
            set(this.dirListbox, 'Position', [0, height-this.buttonHeight*2-this.textHeight-this.dirListHeight-2, width, this.dirListHeight]);
            set(this.fileListbox, 'Position', [0, 0, width, height-this.buttonHeight*2-this.textHeight-this.dirListHeight-3]);
        end
        
        % Call to change the working directory
        % This will also update the file and dir listings
        % Therefore, also call to refresh dir listings on the current dir
        function openDir(this, newDir)
            % Update directory
            this.currentDir = newDir;
            
            this.refreshLists();
        end
        
        
        function openDir_UI(this)
            newDir = uigetdir(this.currentDir, 'Select Working Directory');
            if (newDir)
                this.openDir(newDir);
            end
        end
        
        function upDir(this)
            this.openDir(fullfile(this.currentDir, '..'));
        end
    end
    
    methods (Access = private)
        % Call to re-populate the dir and file lists
        function refreshLists(this)
            % Get regex pattern, default to .*
            pattern = this.filterBox.String;
            if(isempty(pattern))
                pattern = '.*';
            end
            allFiles = dir(this.currentDir);
            
            % Populate directory list
            names = {};
            for i = 1:length(allFiles)
                file = allFiles(i);
                
                % Exclude files and '.'
                if(file.isdir && ~strcmp(file.name, '.'))
                    names{end+1} = file.name;       %#ok
                end
            end
            this.dirListbox.String = names;
            this.dirListbox.Value = 1;
            
            % Populate file list
            names = {};
            for i = 1:length(allFiles)
                file = allFiles(i);
                
                % Exclude directories
                if(file.isdir)
                    continue;
                end
                
                index = regexp(file.name, pattern, 'once');
                
                if(~isempty(index))
                    names{end+1} = file.name;       %#ok
                end
            end
            this.fileListbox.String = names;
            this.fileListbox.Value = 1;
        end
        
        % Safely call user specified fileSelectCB function
        function selectFile(this)
            this.safeCB(this.fileSelectCB);
        end
        
        % Safely call user specified fileOpenCB function
        function openFile(this)
            this.safeCB(this.fileOpenCB);
        end
        
        % Safely call user specified fileCloseCB function
        function closeFile(this)
            this.safeCB(this.fileCloseCB);
        end
        
        % General function to safely call certain user specified callbacks
        function safeCB(this, fcn)
            if(~isempty(fcn))
                value = this.fileListbox.Value;
                name = fullfile(this.currentDir, this.fileListbox.String{value});
                fcn(name);
            end
        end
    end
end
