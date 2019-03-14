classdef editor < handle
    properties
        title = 'Unnamed Micrograph';
    end
    properties
        parent;
        image;
        imageFilename;
        
    end
    methods
        function h = editor(parent)
            h.parent = parent;
        end
        function delete(h)
            % Clean up any annotations
        end
    end
    events
        Zoom
        ChangeScale
    end
end