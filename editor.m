classdef editor < handle
    properties
        title = 'Unnamed Micrograph';
    end
    properties
        activeTool = tools.None;        % Which tool is currently in use
        activeAnnotation;       % Currently active annotation
        mouseoverAnnotation;    % Currently moused-over annotation
        dragStartPos = [];      % Starting position of a drag operation
        annotations;            % List of all the annotations
    end
    properties
        parent;         % Direct parent
        ax;             % Axes for displaying image
        image;          % Image data
        filename;       % Image file name
        width;          % Image width
        height;         % Image height
    end
    properties
        zoomStep = 0.1; % How far to zoom on each scroll step (fraction of 1)
        hitDist = 25;   % How far away a mouseover hit is registered
    end
    
    % Constructors, destructors, etc.
    methods
        function this = editor(parent, filename)
            this.parent = parent;
            this.filename = filename;
            this.image = imread(this.filename);
            this.width = size(this.image, 2);
            this.height = size(this.image, 1);
            
            this.ax = axes(this.parent, 'Position', [0 0 1 1]);
            imshow(this.image, 'Parent', this.ax);
            for child = this.ax.Children
                child.HitTest = 'off';
            end
            this.ax.ButtonDownFcn = @(~,eventdata) this.buttonDown_CB(eventdata);    %# This must come after imshow()
            this.ax.PickableParts = 'all';
        end
        function delete(~)
            % Clean up annotations
        end
    end
    
    methods (Access = protected)
        % Checks for, and returns if found, the mouseed over annotation
        function h = mouseoverCheck(this, pos)
            h = [];
            minDist = [];
            for annotation = this.annotations
                dist = annotation.getDist(pos);
                if (dist < this.hitDist)
                    if (isempty(minDist))
                        minDist = dist;
                        h = annotation;
                    else
                        if (dist < minDist)
                            minDist = dist;
                            h = annotation;
                        end
                    end
                end
            end
        end
    end
    
    % Individual mouse movement handling functions
    methods (Access = protected)
        % The None tool handles image panning and annotation selecting
        function noneMoveOperation(this)
            pos = this.ax.CurrentPoint;
            pos = [pos(1), pos(3)];
            xpos = pos(1);
            ypos = pos(2);
            
            % If this.dragStartPos is empty, we are not in a drag and drop
            % operation. If it isn't empty, we are, which means we are
            % panning the image
            if(isempty(this.dragStartPos))
                % Hover select operation
                h = this.mouseoverCheck(pos);
                if(~isempty(h))
                    this.setMouseOver(h);
                else
                    this.clearMouseOver();
                end
            else
                % Pan operation
                delta = this.dragStartPos - [xpos, ypos];
                
                % Stop at the edge of the image
                xrange = this.ax.XLim + delta(1);
                yrange = this.ax.YLim + delta(2);
                
                if(xrange(2) > this.width)
                    xrange = xrange - (xrange(2) - this.width);
                end
                if(xrange(1) < 0)
                    xrange = xrange - xrange(1);
                end
                if(yrange(2) > this.height)
                    yrange = yrange - (yrange(2) - this.height);
                end
                if(yrange(1) < 0)
                    yrange = yrange - yrange(1);
                end
                
                this.ax.XLim = xrange;
                this.ax.YLim = yrange;
            end
        end
        function noneClickOperation(this)
            pos = this.ax.CurrentPoint;
            pos = [pos(1), pos(3)];
            
            % If we click on an annotation, do something. Otherwise we
            % start an image pan operation
            h = this.mouseoverCheck(pos);
            if(isempty(h))
                % Start pan operation
                this.dragStartPos = pos;
            end
        end
        function noneReleaseOperation(this)
            % Finish our pan operation
            this.dragStartPos = [];
        end
        
        % Set the moused-over annotation to the specified one
        function setMouseOver(this, annotation)
            % Is there currently a moused-over annotation
            if(~isempty(this.mouseoverAnnotation))
                % Only do something if the correct annotation isn't already
                % enabled
                if (this.mouseoverAnnotation ~= annotation)
                    this.mouseoverAnnotation.disableHandles();
                    this.mouseoverAnnotation = annotation;
                    this.mouseoverAnnotation.enableHandles();
                end  
            else
                this.mouseoverAnnotation = annotation;
                this.mouseoverAnnotation.enableHandles();
            end
        end
        
        % Clear any currently moused-over annotation
        function clearMouseOver(this)
            if(~isempty(this.mouseoverAnnotation))
                this.mouseoverAnnotation.disableHandles();
                this.mouseoverAnnotation = [];
            end
        end
        
        
        % The distance tool
        function distanceClickOperation(this, point)
            % Determine if we are creating the first point or the second
            if(isempty(this.activeAnnotation))
                % First point: create a new distance annotation
                this.activeAnnotation = distance(this.ax, point);
                if(isempty(this.annotations))
                    this.annotations = this.activeAnnotation;
                else
                    this.annotations(end+1) = this.activeAnnotation;
                end
            else
                % Second point: set second point
                this.activeAnnotation.finishLine(point);
                this.activeAnnotation = [];
            end
        end
        
    end
    
    % External event callback-type functions
    methods
        % This function should be called from the parent whenever the mouse
        % moves within the window.
        function mouseMove(this)
            % Find mouse position on axis
            switch(this.activeTool)
                case tools.Pan
                    pos = this.ax.CurrentPoint;
                    pos = [pos(1), pos(3)];
                    for annotation = this.annotations()
                        annotation.getDist(pos);
                    end
                case tools.Zoom
                case tools.Crop
                case tools.Distance
                case tools.Rectangle
                case tools.Polygon
                case tools.Angle
                case tools.SetScale
                case tools.Scalebar
                case tools.None
                    this.noneMoveOperation();
            end
        end
        
        % Call this function in response to a ButtonDownFcn on the axis
        function buttonDown_CB(this, eventdata)
            switch(this.activeTool)
                case tools.Pan
                case tools.Zoom
                case tools.Crop
                case tools.Distance
                    this.distanceClickOperation(eventdata.IntersectionPoint(1:2));
                case tools.Rectangle
                case tools.Polygon
                case tools.Angle
                case tools.SetScale
                case tools.Scalebar
                case tools.None
                    this.noneClickOperation();
            end
        end
        
        % Called from parent when mouse button goes up
        function buttonUp_CB(this)
            % We only care if we were in a drag and drop operation. So we
            % return early if we were not
            if(isempty(this.dragStartPos))
                return;
            end
            
            % Process end of drag operation
            switch(this.activeTool)
                case tools.Pan
                case tools.Zoom
                case tools.Crop
                case tools.Distance
                case tools.Rectangle
                case tools.Polygon
                case tools.Angle
                case tools.SetScale
                case tools.Scalebar
                case tools.None
                    this.noneReleaseOperation();
            end
        end
        
        % Called by parent whenever a mouse scroll event is detected
        function scrollZoom(this, scrollCount)
            % Find zoom center
            pos = this.ax.CurrentPoint;
            xpos = pos(1);
            ypos = pos(3);
            xrange = this.ax.XLim;
            yrange = this.ax.YLim;
            
            % Check if we are outside the range, return if we are
            if((xpos < xrange(1)) || (xpos > xrange(2)) || (ypos < yrange(1)) || (ypos > yrange(2)))
                return;
            end
            
            % How scroll zomming should behave:
            % Zoom should occur around mouse location
            % Point at mouse location should not move
            
            % Distances from mouse to edges
            left = xrange(1) - xpos;
            right = xrange(2) - xpos;
            bottom = yrange(1) - ypos;
            top = yrange(2) - ypos;
            
            % Update distances
            left = left * (1 + this.zoomStep * scrollCount);
            right = right * (1 + this.zoomStep * scrollCount);
            bottom = bottom * (1 + this.zoomStep * scrollCount);
            top = top * (1 + this.zoomStep * scrollCount);
            
            xrange(1) = left + xpos;
            xrange(2) = right + xpos;
            yrange(1) = bottom + ypos;
            yrange(2) = top + ypos;
            
            % Limit the x and y ranges to the dimensions of the image
            if (xrange(1) < 0)
                xrange(1) = 0;
            end
            if (xrange(2) > this.width)
                xrange(2) = this.width;
            end
            if (yrange(1) < 0)
                yrange(1) = 0;
            end
            if (yrange(2) > this.height)
                yrange(2) = this.height;
            end
            
            % Update axis limits and linewidths
            this.ax.XLim = xrange;
            this.ax.YLim = yrange;
        end
        
        % Called to cancel any current tool operation
        % Does not change the active tool
        function cancel(this)
            % Clear the active annotation
            this.activeAnnotation = [];
        end
        
        % Called to select the active tool
        function activateTool(this, tool)
            % Cancel whatever we are currently doing
            this.cancel();
            
            % Set the new tool
            this.activeTool = tool;
        end
    end
    
    %events
    %    Zoom
    %    ChangeScale
    %end
end
