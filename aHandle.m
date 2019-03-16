classdef aHandle < handle
    properties
        position;   % Location
        ax;         % Parent axis
        h;          % Handle
    end
    properties
        size = 20;
    end
    methods
        function this = aHandle(ax, pos)
            this.ax = ax;
            w = this.size;
            h = this.size;
            x = pos(1) - w/2;
            y = pos(2) - h/2;
            this.h = rectangle(this.ax, 'Position', [x, y, w, h]);
            this.h.EdgeColor = [0,0,1];
        end
        
        % Destructor
        function delete(this)
            delete(this.h);
        end
    end
end
