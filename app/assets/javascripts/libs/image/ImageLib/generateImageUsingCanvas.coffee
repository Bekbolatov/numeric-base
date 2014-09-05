angular.module 'ImageLib'

.factory 'GenerateImageUsingCanvas', [() ->
    class CanvasWrapper
        getCanvas: () ->
            if @canvas == undefined
                @canvas = document.createElement('canvas')
            @canvas
        getContext: () ->
            if @context == undefined
                @context = @getCanvas().getContext('2d')
            @context

        encode: (stringData, width, height) ->
            canvas = @getCanvas()
            canvas.setAttribute('width', width)
            canvas.setAttribute('height', height)

            context = @getContext()
            canvasData = context.getImageData(0, 0, width, height);

            if canvasData
                for y in [ 0 ... height ]
                    for x in [ 0 ... width ]
                        s = stringData[ (height - y - 1) * width + x ]
                        r = s.charCodeAt(0)
                        g = s.charCodeAt(1)
                        b = s.charCodeAt(2)
                        a = s.charCodeAt(3)

                        index = (x + y * width) * 4;
                        canvasData.data[index] = r
                        canvasData.data[index + 1] = g
                        canvasData.data[index + 2] = b
                        canvasData.data[index + 3] = 255 - a
                context.putImageData(canvasData, 0, 0)
                canvas.toDataURL("image/png")
            else
                'error'
    new CanvasWrapper()
]