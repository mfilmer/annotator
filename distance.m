classdef distance < annotation
    properties
        text;       % Handle to text element
        textOffset = 50;
        constraint = constraints.None;
    end
    methods
        function this = distance(editor, ax, point)
            this.editor = editor;
            this.ax = ax;
            this.h = line(this.ax, point(1), point(2));
            this.h.Color = this.color;
            this.h.LineWidth = this.lineWidth;
            this.h.PickableParts = 'none';
            this.points = reshape(point, 1,2);
        end
        
        % Destructor
        function delete(this)
            delete(this.text);
        end
        
        function finishLine(this, point)
            x1 = this.h.XData(1);
            y1 = this.h.YData(1);
            x2 = point(1);
            y2 = point(2);
            
            % Handle horizontal and vertical constraints
            switch (this.constraint)
                case constraints.Horizontal
                    y2 = y1;
                case constraints.Vertical
                    x2 = x1;
            end
            
            this.h.XData = [x1,x2];
            this.h.YData = [y1,y2];
            this.points = [x1,y1; x2,y2];
            this.text = text('Color', this.color, 'FontSize', this.fontSize, ...
                'HorizontalAlignment', 'center');     %#ok
            this.updateMeasurement();
        end
        
        % Called to force a redraw of the line
        function updateLine(this)
            % Just move the two points
            this.h.XData = this.points(:,1)';
            this.h.YData = this.points(:,2)';
            
            % Also update the text
            this.updateMeasurement();
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
            [str, factor] = annotation.num2str(len);
            prefix = annotation.getPrefix(factor);
            if (isempty(prefix))
                this.text.String = str;
            else
                this.text.String = [str ' ' prefix];
            end
            
            this.text.Rotation = angle;
        end
        
        function movePoint(this, handle, pos)
            % Get handle index
            thisHandleInd = find(this.handles == handle);
            otherHandleInd = 3 - thisHandleInd;
            
            % Determine if shift key is up or down
            shiftState = this.editor.application.keyStatus.shift;
            if shiftState
                % Determine if we are closer to a horizontal or vertical
                dx = this.points(otherHandleInd, 1) - this.points(thisHandleInd, 1);
                dy = this.points(otherHandleInd, 2) - this.points(thisHandleInd, 2);
                
                if abs(dx) < abs(dy)
                    con = constraints.Vertical;
                else
                    con = constraints.Horizontal;
                end
                
                % Handle horizontal or vertical constraints
                % We check if the point is invalid. If is is, we snap it to a
                % valid location.
                switch (con)
                    case constraints.Horizontal
                        if pos(2) ~= this.points(otherHandleInd,2)
                            handle.move([pos(1), this.points(otherHandleInd,2)]);
                            return;
                        end
                    case constraints.Vertical
                        if pos(1) ~= this.points(otherHandleInd,1)
                            handle.move([this.points(otherHandleInd,1), pos(2)]);
                            return;
                        end
                end
            end
            
            this.points(thisHandleInd,:) = reshape(pos, 1, 2);
            
            % Update the line display
            this.updateLine();
        end
        
        function dist = getDist(this, point)
            % Extract some data
            xs = this.points(:,1);
            ys = this.points(:,2);
            p1 = [xs(1), ys(1)];
            p2 = [xs(2), ys(2)];
            
            % Calculate distance to each node
            dist1 = this.distToPoint(p1, point);
            dist2 = this.distToPoint(p2, point);
            
            % Return min distance
            dist = min(dist1, dist2);
        end
    end
    
    % Settings functions
    methods
        function setColor(this, color)
            this.setColor@annotation(color);
            
            this.h.Color = this.color;
            if(~isempty(this.text))
                this.text.Color = this.color;
            end
        end
    end
end
