angular.module 'ImageLib'

.factory("GraphicsManager", [ 'ImageData', 'GenerateImagePng', 'GenerateImageUsingCanvas', (ImageData, GenerateImagePng, GenerateImageUsingCanvas ) ->
    class Image
        constructor: (@imageData, @width, @height, backgroundColor, offset) ->
            @width = Math.round(@width)
            @height = Math.round(@height)
            offset = Math.round(offset)

            @colors = @imageData.colors[0]
            @chars = @imageData.chars[0]

            @data = []
            if offset != undefined
                @offset = offset
            else
                @offset = 0
            @width = @width + 2 * @offset
            @height = @height + 2 * @offset

            if backgroundColor != undefined
                color = @colors[backgroundColor]
                if color == undefined
                    color = @colors['w']
                for i in [ 0 .. ( @width *  @height - 1) ]
                    @data[i] = color

        colorOrBlack: (colorLetter) ->
            if colorLetter == undefined || @colors[colorLetter] == undefined
                color = @colors['B']
            else @colors[colorLetter]

        ############################################################
        placeChar: (x,y,c, colorLetter) ->
            x = Math.round(x)
            y = Math.round(y)
            color = @colorOrBlack(colorLetter)
            char = @chars[c]
            if char == undefined
                char = @chars['?']
            i = 0
            for yy in [ (y + char[1] - 1) .. y ]
                for xx in [ x .. (x + char[0] - 1) ]
                    if char[2][i] > 0
                        @setPoint(xx, yy, color)
                    i = i + 1
        placeCharSequence: (x,y,cc, colorLetter) ->
            if cc == undefined || cc.length < 1
                return
            w = 6
            for i in [ 0 .. (cc.length - 1) ]
                @placeChar(x + i*w, y, cc[i], colorLetter)
        placeCharSequenceCentered: (x,y,cc, colorLetter) ->
            if cc == undefined || cc.length < 1
                return
            @placeCharSequence(x - 3*cc.length, y - 4, cc, colorLetter )
        ############################################################
        setPoint: (x, y, color) ->
            x = Math.round(x + @offset)
            y = Math.round(y + @offset)
            @data[y * @width + x] = color
            @
        getPoint: (x, y) -> @data[y * @width + x]
        ############################################################
        drawLine: (x1, y1, x2, y2, colorLetter) ->
            color = @colorOrBlack(colorLetter)
            if y2 == y1 && x2 == x1
                 @setPoint(x1, y1, color)
                 return @
            if Math.abs(y2 - y1) > Math.abs (x2 - x1)
                k = (x2 - x1) / (y2 - y1)
                fy2x = (y) -> Math.round(k*(y - y1)) + x1
                for y in [y1 .. y2]
                    @setPoint(fy2x(y), y, color)
            else
                k = (y2 - y1) / (x2 - x1)
                fx2y = (x) -> Math.round(k*(x - x1)) + y1
                for x in [x1 .. x2]
                    @setPoint(x, fx2y(x), color)
            @
        ############################################################
        drawRectangle: (x, y, w, h, colorLetter) ->
            @drawLine(x, y, x + w, y, colorLetter)
            @drawLine(x, y, x, y + h, colorLetter)
            @drawLine(x, y + h, x + w, y + h, colorLetter)
            @drawLine(x + w, y, x + w, y + h, colorLetter)
        drawTriangle: (x1, y1, x2, y2, x3, y3, colorLetter) ->
            @drawLine(x1, y1, x2, y2, colorLetter)
            @drawLine(x1, y1, x3, y3, colorLetter)
            @drawLine(x2, y2, x3, y3, colorLetter)
        ############################################################
        fillRectangle: (x, y, w, h, colorLetter) ->
            x = Math.round(x)
            y = Math.round(y)
            w = Math.round(w)
            h = Math.round(h)
            color = @colorOrBlack(colorLetter)
            for ny in [ y .. (y + h - 1) ]
                for nx in [ x .. (x + w - 1) ]
                    @setPoint(nx, ny, color)
            @
        fillRectangleCoords: (x1, y1, x2, y2, colorLetter) -> @fillRectangle(x1, y1, x2 - x1, y2 - y1, colorLetter )
        ############################################################
        transform: (fxy) ->
            @buffer = []
            for x in [ 0 .. (@width - 1) ]
                for y in [ 0 .. (@height - 1) ]
                    [nx, ny] = fxy(x, y)
                    @buffer[ny * @width + nx] = @data[y * @width + x]
            @data = @buffer
            @buffer = undefined
            @
        ############################################################
        flipImage: () => @transform( (x,y) => [x, ( @height - 1 - y ) ] )
        ############################################################
        ############################################################

        getBase64: () ->
            @getBase64Png()
            #@getBase64Canvas() #alternative - simpler, maybe more reliable, but generates images 10x larger 6.5KB vs 730B avgs


        getBase64Png: () -> GenerateImagePng.encode(@data, @width, @height) #0 grayscale, 1 filter, 6 compression zlib med
        #getBase64Bmp: () -> GenerateImageBmp.encode(@data, @width, @height)
        getBase64Canvas: () -> GenerateImageUsingCanvas.encode(@data, @width, @height)


    class GraphicsManager
        constructor: () ->
            @imageData = ImageData
        newImage: (width, height, backgroundColor) -> new Image(@imageData, width, height, backgroundColor)
        newImageWhite: (width, height) -> new Image(@imageData, width, height, 'w')
        newImageWhiteWithOffset: (width, height, offset) -> new Image(@imageData, width, height, 'w', offset)

        getColor: (r ,g, b, a) -> String.fromCharCode(r, g, b, a)

        test: () ->
            img = @newImage(210, 210)
            img.fillRectangle(0, 0, 210, 210, 'w')
            img.fillRectangle(10, 10, 90, 90, 'r')
            img.fillRectangle(110, 10, 90, 90, 'g')
            img.fillRectangle(10, 110, 90, 90, 'b')
            img.flipImage()
            img.getBase64()

    graphicsManager = new GraphicsManager()
    document.numeric.modules.Graphics = graphicsManager
    graphicsManager
])
