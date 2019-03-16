classdef aHandle < handle
    properties
        position;   % Location
        ax;         % Parent axis
        rect;       % Rectangle handle
        parent;     % Parent annotation
    end
    properties
        size = 40;
    end
    methods
        function this = aHandle(parent, ax, pos)
            this.parent = parent;
            this.ax = ax;
            this.position = pos;
            w = this.size;
            h = this.size;
            x = pos(1) - w/2;
            y = pos(2) - h/2;
            this.rect = rectangle(this.ax, 'Position', [x, y, w, h], 'HitTest', 'off');
            this.rect.EdgeColor = [0,0,1];
        end
        
        % Destructor
        function delete(this)
            delete(this.rect);
        end
        
        % Return distance to a hit, or empty if not a hit
        function hit = hitCheck(this, pos)
            % Default return value: no hit
            hit = -1;

            % Check if outside box, with circle method because its easier
            % and can give us a distance
            dist = sqrt((this.position(1) - pos(1))^2 + (this.position(2) - pos(2))^2);
            if dist <= this.size/2.2
                hit = dist;
            end
        end
        
        % Called when a user moves the handle
        function move(this, pos)
            % Update our position
            this.position = pos;
            
            % Redraw the handle
            w = this.size;
            h = this.size;
            x = pos(1) - w/2;
            y = pos(2) - h/2;
            this.rect.Position = [x, y, w, h];
            
            % Tell the parent this handle moved
            this.parent.movePoint(this, pos);
        end
    end
end
