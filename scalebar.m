classdef scalebar < distance
    methods
        function this = scalebar(ax, point)
            % Call superclass constructor
            this@distance(ax, point);
            
            % Set the color
            this.color = [0,1,0];
            this.h.Color = [0,1,0];
        end
    end
end
