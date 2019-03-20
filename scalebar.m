classdef scalebar < distance
    methods
        function this = scalebar(editor, ax, scale, point)
            % Call superclass constructor
            this@distance(editor, ax, scale, point);
            
            % Set the color
            this.setColor([0,1,0]);
            
            % Set horizontal constraint
            this.constraint = constraints.None;
        end
    end
end
