classdef fileList < handle
    properties
        parent;
        panel;
        list;
        openButton;
        filterBox;
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
            this.openButton = uicontrol('Parent', this.panel, 'String', 'Open');
            this.filterBox = uicontrol('Parent', this.panel, 'Style', 'edit', 'String', '*.*');
        end
        
        function setPosition(this, pos)
            X = pos(1);
            Y = pos(2);
            width = pos(3);
            height = pos(4);
            
            set(this.panel, 'Position', pos);
            set(this.openButton, 'Position', [0, height-this.buttonHeight, width-3, this.buttonHeight-2]);
            set(this.filterBox, 'Position', [1, height-this.buttonHeight-this.textHeight, width-5, this.buttonHeight]);
        end
    end
end
