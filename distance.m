classdef distance < annotation
    methods
        function this = distance(ax, point)
            this.ax = ax;
            this.h = line(this.ax, point(1), point(2));
            this.h.Color = this.color;
            this.h.LineWidth = this.lineWidth;
            this.h.PickableParts = 'none';
            this.points = reshape(point, 1,2);
        end
        function finishLine(this, point)
            x1 = this.h.XData(1);
            y1 = this.h.YData(1);
            x2 = point(1);
            y2 = point(2);
            this.h.XData = [x1,x2];
            this.h.YData = [y1,y2];
            this.points = [x1,y1; x2,y2];
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
end
