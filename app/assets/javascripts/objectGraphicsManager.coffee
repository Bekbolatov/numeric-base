angular.module('AppOne')

.factory("GraphicsManager", [ () ->
    class Image
        constructor: (@width, @height, backgroundColor, offset) ->
            @width = Math.round(@width)
            @height = Math.round(@height)
            offset = Math.round(offset)

            @data = []
            @colors =
                'B': String.fromCharCode(0, 0, 0, 0)
                'w': String.fromCharCode(255, 255, 255, 0)
                'r': String.fromCharCode(255, 0, 0, 0)
                'g': String.fromCharCode(0, 255, 0, 0)
                'b': String.fromCharCode(0, 0, 255, 0)
            @chars =
                '0': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0 ]]
                '1': [5, 7, [0,0,1,0,0, 0,1,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 1,1,1,1,1 ]]
                '2': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 1,1,1,1,1 ]]
                '3': [5, 7, [1,1,1,1,1, 0,0,0,1,0, 0,0,1,0,0, 0,0,0,1,0, 0,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0 ]]
                '4': [5, 7, [0,0,0,1,0, 0,0,1,1,0, 0,1,0,1,0, 1,0,0,1,0, 1,1,1,1,1, 0,0,0,1,0, 0,0,0,1,0 ]]
                '5': [5, 7, [1,1,1,1,1, 1,0,0,0,0, 1,1,1,1,0, 0,0,0,0,1, 0,0,0,0,1, 0,0,0,0,1, 1,1,1,1,0 ]]
                '6': [5, 7, [0,0,1,1,0, 0,1,0,0,0, 1,0,0,0,0, 1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0 ]]
                '7': [5, 7, [1,1,1,1,1, 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 0,1,0,0,0, 0,1,0,0,0 ]]
                '8': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0 ]]
                '9': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,1, 0,0,0,0,1, 0,0,0,1,0, 0,1,1,0,0 ]]
                '?': [5, 7, [0,1,1,1,0, 1,0,0,0,1, 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,0,0,0,0, 0,0,1,0,0 ]]
            if offset != undefined
                @offset = offset
            else
                @offset = 0
            @width = @width + 2 * @offset
            @height = @height + 2 * @offset
            @_setImageHeader()

            if backgroundColor != undefined
                color = @colors[backgroundColor]
                if color == undefined
                    color = @colors['w']
                for i in [ 0 .. ( @width *  @height - 1) ]
                    @data[i] = color

        colorOrBlack: (colorLetter) ->
            if colorLetter == undefined || @colors[colorLetter]
                color = @colors['B']
            else @colors[colorLetter]

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
            outputData = @header + @data.join('')
            if window.btoa
                encodedData = window.btoa(outputData)
            else
                encodedData = $.base64.encode(outputData)
            'data:image/bmp;base64,' + encodedData


    class GraphicsManager
        newImage: (width, height, backgroundColor) -> new Image(width, height, backgroundColor)
        newImageWhite: (width, height) -> new Image(width, height, 'w')
        newImageWhiteWithOffset: (width, height, offset) -> new Image(width, height, 'w', offset)
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
