classdef colorButton < handle
    properties (Access = protected)
        parent;
        button;
        size = 25;
        color = [0.3,0.3,0.3];
    end
    methods
        % Constructor
        function this = colorButton(parent, position)
            this.parent = parent;
            this.button = uicontrol(parent, 'Position', position);
            this.setColor(this.color);
        end
        
        % Destructor
        function delete(this)
            delete(this.button);
        end
        
        function setPosition(this, position)
            this.button.Position = position;
            
            this.setColor(this.color);
        end
        
        function setColor(this, color)
            this.color = color;
            w = this.button.Position(3);
            h = this.button.Position(4);
            m = 8;
            
            color = [color(1)*ones(h-m,w-m), color(2)*ones(h-m,w-m), color(3)*ones(h-m,w-m)];
            color = reshape(color, h-m,w-m,3);
            
            this.button.CData = color;
        end
    end
end
