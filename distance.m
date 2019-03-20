classdef distance < annotation
    properties
        text;       % Handle to text element
        textOffset = 50;
        constraint = constraints.None;
        centerHandle;
    end
    methods
        function this = distance(editor, ax, point)
            this = this@annotation(editor, ax);
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
                'HorizontalAlignment', 'center', 'HitTest', 'off');     %#ok
            this.updateMeasurement();
        end
        
        function enableHandles(this)
            % Call parent
            enableHandles@annotation(this);
            
            % Enable center handle
            x1 = this.points(1,1);
            x2 = this.points(2,1);
            y1 = this.points(1,2);
            y2 = this.points(2,2);
            xavg = (x2+x1)/2;
            yavg = (y2+y1)/2;
            this.centerHandle = aHandle(this, this.ax, [xavg, yavg]);
            this.centerHandle.setColor([0,1,0]);
        end
        
        function disableHandles(this)
            % Call parent
            disableHandles@annotation(this);
            
            % Disable center handle
            delete(this.centerHandle);
            this.centerHandle = [];
        end
        
        function [han, dist] = getHandle(this, pos)
            % Call parent
            [han, dist] = getHandle@annotation(this, pos);
            
            % Check if the center handle beats this handle
            if(~isempty(this.centerHandle))
                cenDist = this.centerHandle.hitCheck(pos);
                if (cenDist ~= -1)
                    if (isempty(dist) || (cenDist < dist))
                        dist = cenDist;
                        han = this.centerHandle;
                    end
                end
            end
        end
        
        % Called to force a redraw of the line
        function updateLine(this)
            % Move the two points
            this.h.XData = this.points(:,1)';
            this.h.YData = this.points(:,2)';
            
            % Also update the text
            this.updateMeasurement();
            
            % Update handle positions
            this.fixHandlePositions();
        end
        
        function fixHandlePositions(this)
            % Call superclass
            fixHandlePositions@annotation(this);
            
            % Fix center handle position
            if(~isempty(this.centerHandle))
                x1 = this.points(1,1);
                x2 = this.points(2,1);
                y1 = this.points(1,2);
                y2 = this.points(2,2);
                xavg = (x2+x1)/2;
                yavg = (y2+y1)/2;
                this.centerHandle.redrawAt([xavg, yavg]);
            end
        end
        
        function scaleChanged(this)
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
            this.text.String = this.dispLen(len, 3);
            this.text.Rotation = angle;
        end
        
        function movePoint(this, handle, pos, oldPos)
            % Determine if this is the center handle. If it is, take care
            % of it and skip the rest of the function
            if (handle == this.centerHandle)
                % Calculate dx and dy
                dx = pos(1) - oldPos(1);
                dy = pos(2) - oldPos(2);
                
                % Move each point
                for i = 1:size(this.points,1)
                    this.points(i,:) = this.points(i,:) + [dx, dy];
                end
                
                % Redraw the line
                this.updateLine();
                
                % Return early, we are done
                return;
            end
            
            
            % It wasn't the center handle, must be in the array: Get handle index
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
            
            % Calculate distance to center
            pc = [(p1(1)+p2(1))/2, (p1(2)+p2(2))/2];
            distCen = this.distToPoint(pc, point);
            
            % Return min distance
            dist = min([dist1, dist2, distCen]);
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
