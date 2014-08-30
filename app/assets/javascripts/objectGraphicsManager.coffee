angular.module('AppOne')

.factory("GraphicsManager", [ () ->
    class Image
        constructor: (@width, @height, backgroundColor) ->
            @_setImageHeader()
            @data = []
            @colors =
                'b': String.fromCharCode(0, 0, 0, 0)
                'w': String.fromCharCode(255, 255, 255, 0)
                'r': String.fromCharCode(255, 0, 0, 0)
                'g': String.fromCharCode(0, 255, 0, 0)
                'b': String.fromCharCode(0, 0, 255, 0)
            if backgroundColor != undefined
                @fillRectangle(0, 0, @width, @height, backgroundColor)
        _getLittleEndianHex: (value) ->
            result = []
            for bytes in [4 .. 1]
                result.push(String.fromCharCode(value & 255))
                value >>= 8
            result.join('')

        _setImageHeader: () ->
            numFileBytes = @_getLittleEndianHex(@width * @height)
            w = @_getLittleEndianHex(@width)
            h = @_getLittleEndianHex(@height)

            @header = '' +
            'BM' +                    # Signature
            numFileBytes +            # size of the file (bytes)*
            '\x00\x00' +              # reserved
            '\x00\x00' +              # reserved
            '\x36\x00\x00\x00' +      # offset of where BMP data lives (54 bytes)
            '\x28\x00\x00\x00' +      # number of remaining bytes in header from here (40 bytes)
            w +                       # the width of the bitmap in pixels*
            h +                       # the height of the bitmap in pixels*
            '\x01\x00' +              # the number of color planes (1)
            '\x20\x00' +              # 32 bits / pixel
            '\x00\x00\x00\x00' +      # No compression (0)
            '\x00\x00\x00\x00' +      # size of the BMP data (bytes)*
            '\x13\x0B\x00\x00' +      # 2835 pixels/meter - horizontal resolution
            '\x13\x0B\x00\x00' +      # 2835 pixels/meter - the vertical resolution
            '\x00\x00\x00\x00' +      # Number of colors in the palette (keep 0 for 32-bit)
            '\x00\x00\x00\x00'       # 0 important colors (means all colors are important)

        ############################################################
        ############################################################
        setPoint: (x, y, color) ->
            @data[y * @width + x] = color
            @
        getPoint: (x, y) -> @data[y * @width + x]
        fillRectangle: (x, y, w, h, colorLetter) ->
            if colorLetter == undefined
                colorLetter = 'b'
            color = @colors[colorLetter]
            if color == undefined
                color = @colors['b']
            for ny in [ y .. (y + h - 1) ]
                for nx in [ x .. (x + w - 1) ]
                    @setPoint(nx, ny, color)
            @
        drawLine: (x1, y1, x2, y2, colorLetter) ->
            if colorLetter == undefined
                colorLetter = 'b'
            color = @colors[colorLetter]
            if color == undefined
                color = @colors['b']
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
        transform: (fxy) ->
            @buffer = []
            for x in [ 0 .. (@width - 1) ]
                for y in [ 0 .. (@height - 1) ]
                    [nx, ny] = fxy(x, y)
                    @buffer[ny * @width + nx] = @data[y * @width + x]
            @data = @buffer
            @buffer = undefined
            @
        flipImage: () => @transform( (x,y) => [x, ( @height - 1 - y ) ] )
        ############################################################
        ############################################################

        getBase64: () ->
            outputData = @header + @data.join('')
            if window.btoa
                encodedData = window.btoa(outputData)
            else
                encodedData = $.base64.encode(outputData)
            'data:image/bmp;base64,' + encodedData


    class GraphicsManager
        newImage: (width, height, backgroundColor) -> new Image(width, height, backgroundColor)
        newImageWhite: (width, height) -> new Image(width, height, 'w')
        test: () ->
            img = @newImage(210, 210)
            img.fillRectangle(0, 0, 210, 210, 'w')
            img.fillRectangle(10, 10, 90, 90, 'r')
            img.fillRectangle(110, 10, 90, 90, 'g')
            img.fillRectangle(10, 110, 90, 90, 'b')
            img.flipImage()
            img.getBase64()

    new GraphicsManager()
])
