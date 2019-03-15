classdef fileList < handle
    properties
        % UI Elements
        parent;
        panel;
        list;
        openButton;
        filterBox;
        
        % Data
        currentDir;
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
            this.openButton = uicontrol('Parent', this.panel, 'String', 'Open', 'Callback', @(src, eventdata) this.openDir());
            this.filterBox = uicontrol('Parent', this.panel, 'Style', 'edit', 'String', '.+\..+');
            this.list = uicontrol('Parent', this.panel, 'Style', 'listbox');
        end
        
        function setPosition(this, pos)
            width = pos(3);
            height = pos(4);
            
            set(this.panel, 'Position', pos);
            set(this.openButton, 'Position', [0, height-this.buttonHeight, width-3, this.buttonHeight-2]);
            set(this.filterBox, 'Position', [1, height-this.buttonHeight-this.textHeight, width-5, this.buttonHeight]);
            set(this.list, 'Position', [0, 0, width, height - this.buttonHeight*2 - 3]);
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
            end
        end
    end
end
