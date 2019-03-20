classdef scalebar < distance
    properties
        updateCallback;
        pixlen;
    end
    methods
        function this = scalebar(editor, ax, point)
            % Call superclass constructor
            this@distance(editor, ax, point);
            
            % Set the color
            this.setColor([0,1,0]);
        end
        
        % Called to force a redraw of the text measurement
        function updateMeasurement(this)
            % Calculate angle of the line
            x0 = this.points(1,1);
            x1 = this.points(2,1);
            y0 = this.points(1,2);
            y1 = this.points(2,2);
            dy = y1-y0;
            dx = x1-x0;
            angle = atan(-dy/dx);
            angle = angle * 180 / pi;
            
            % Calculate midpoint of the line
            xm = (x1-x0)/2 + x0;
            ym = (y1-y0)/2 + y0;
            
            % Calculate length of the line
            len = sqrt((x1-x0)^2 + (y1-y0)^2);
            
            % Calculate text offset
            dx = this.textOffset * sin(angle * pi/180);
            dy = this.textOffset * cos(angle * pi/180);
            
            this.text.Position = [xm-dx, ym-dy, 0];
            this.text.String = num2str(len, 3);
            this.text.Rotation = angle;
        end
        
        function movePoint(this, handle, pos)
            % Call superclass function
            movePoint@distance(this, handle, pos);
            
            % Update scale settings
            x1 = this.h.XData(1);
            x2 = this.h.XData(2);
            y1 = this.h.YData(1);
            y2 = this.h.YData(2);
            this.editor.imageScale.pixelLength = sqrt((x2-x1)^2 + (y2-y1)^2);
            this.editor.updateScale();
        end
    end
end
