classdef annotation < handle
    properties
        points;     % List of manipulation points
        h;          % Primary object
        ax;         % Parent axis
        handles;    % Array of manipulation handles
    end
    properties
        color = [1,0,0];
        fontSize = 20;
        lineWidth = 3;
        arrowLength = 10;
    end
    methods (Abstract)
        % Returns the distance from the specified point to the annotation.
        % Annotations can determine what this means, but it should usually
        % mean the distance to the closest point of the annotation, or
        % maybe a center point
        getDist(this, point)
    end
    
    methods
        function enableHandles(this)
            % Check that we aren't already enabled, otherwise do nothing
            if (isempty(this.handles))
                this.handles = aHandle(this.ax, this.points(1,:));
                for i = 2:size(this.points,1)
                    point = this.points(i,:);
                    this.handles(end+1) = aHandle(this.ax, point);
                end
            end
        end
        
        function disableHandles(this)
            for handle = this.handles
                delete(handle);
            end
            this.handles = [];
        end
    end
    
    methods (Access = protected)
        % Distance from a point to a line that goes through the two points
        % specified in xs and ys
        function dist = distToLine(xs, ys, point)
            % Extract some data
            x0 = xs(1);
            x1 = xs(2);
            y0 = ys(1);
            y1 = ys(2);
            px = point(1);
            py = point(2);
            
            % Calculate intermediate values
            m = (y1-y0)/(x1-x0);
            a = m;
            b = -1;
            c = -m*x0 + y0;
            
            % Calculate distance to full line
            dist = abs(a*px + b*py + c) / sqrt(a^2 + b^2);
        end
        
        % Distance between two pointsn
        function dist = distToPoint(~, p1, p2)
            dist = sqrt((p2(1) - p1(1))^2 + (p2(2) - p1(2))^2);
        end
    end
    
    methods (Static)
        % Converts a number into a string in engineering notation
        function [str,factor] = num2str(dist)
            factor = 0;
            while(dist >= 1000)
                factor = factor + 3;
                dist = dist / 1000;
            end
            while(dist < 1)
                factor = factor - 3;
                dist = dist * 1000;
            end
            
            if (dist >= 100)
                str = num2str(dist, '%0.0f');
            elseif (dist >= 10)
                str = num2str(dist, '%0.1f');
            else
                str = num2str(dist, '%0.2f');
            end
        end
        
        function prefix = getPrefix(factor)
            switch factor
                case 3
                    prefix = 'k';
                case -3
                    prefix = 'm';
                case -6
                    prefix = 'u';
                case -9
                    prefix = 'n';
                case -12
                    prefix = 'p';
                otherwise
                    prefix = '';
            end
        end
    end
end
