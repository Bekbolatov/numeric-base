angular.module 'ImagePng', []

# http://en.wikipedia.org/wiki/Portable_Network_Graphics
# doesn't do indexed-color
.factory 'GenerateImagePng', [ () ->
    class Chunker # Cyclic Redundancy Check (http://www.libpng.org/pub/png/spec/1.2/PNG-Structure.html)
        constructor: (functions)->
            @_initTable()
        _initTable: ->
            @table = []
            for n in [0 ... 256]
                c = n
                for k in [0 ... 8]
                    if (c & 1)
                        c = ( 0xedb88320 ^ (c >>> 1) )
                    else
                        c = ( c >>> 1 )

                @table[n] = c
            @table

        _update_crc: (c, buf) ->
            for n in [0 ... buf.length]
                b = buf.charCodeAt(n)
                c = @table[(c ^ b) & 0xff] ^ (c >>> 8)
            c
        _crc: (buf) -> ( @_update_crc(0xffffffff, buf) ^ 0xffffffff )
        _byte: (dword, num) ->
            if num == 0
                (dword & 0xFF000000) >>> 24
            else if num == 1
                (dword & 0x00FF0000) >>> 16
            else if num == 2
                (dword & 0x0000FF00) >>> 8
            else
                (dword & 0x000000FF)
        _word: (r) -> String.fromCharCode(@_byte(r, 0), @_byte(r, 1), @_byte(r, 2), @_byte(r, 3))
        _createChunk: (type, data) -> ( @_word(data.length) + type + data + @_word(@_crc(type + data)) )

        SIGNATURE: -> String.fromCharCode(137, 80, 78, 71, 13, 10, 26, 10)  # (0x89)PNG(CR)(LF)(0x1A)(0x0A)
        IHDR: (width, height, bitDepth, colorType) ->
            IHDRdata = @_word(width) + @_word(height)
            IHDRdata += String.fromCharCode(bitDepth)          # bit depth
            IHDRdata += String.fromCharCode(colorType)          # color type: 6=truecolor with alpha; 3 (indexed color); 2 (truecolor); 0,4 (Grayscale, and with alpha)
            IHDRdata += String.fromCharCode(0)          # [compression method: 0=deflate, only allowed value]
            IHDRdata += String.fromCharCode(0)          # [filtering: 0=adaptive, only allowed value]
            IHDRdata += String.fromCharCode(0)          # interlacing: 0=none
            @_createChunk('IHDR', IHDRdata )
        PLTE: (palette) -> @_createChunk('PLTE', palette) # for indexed color type (2) - must not appear with 0 and 4
        IDAT: (compressedData) -> @_createChunk('IDAT', compressedData)
        IEND: -> @_createChunk('IEND', '')

    class Data # assuming @inputData is of the form RGBA:[ String.fromCharCode(R,G,B,A/0), ... ] or Gray:[ String.fromCharCode(Gray,0,0,A/0), ... ]
        constructor: (@bitDepth, @colorType, @lineFilter, @compression, @inputData, @width, @height) ->
            @chunker = new Chunker()
            if @colorType == 0 || @colorType == 2
                @channels = @colorType + 1
            else
                @channels = @colorType - 2
            @colorDepth = @bitDepth * @channels
            @LINE_FILTER = String.fromCharCode(lineFilter)
            if @bitDepth == 1
                @BITDEPTH = 0x00000001
            else if @bitDepth == 2
                @BITDEPTH = 0x00000003
            else if @bitDepth == 4
                @BITDEPTH = 0x0000000F
            else
                @BITDEPTH = 0x000000FF


        _getPixelChannel: (pixel, channel) ->
            CHANNEL =
                RED:
                    mask: 0xFF000000
                    shift: 24
                GREEN:
                    mask: 0x00FF0000
                    shift: 16
                BLUE:
                    mask: 0x000000FF00
                    shift: 8
                ALPHA:
                    mask: 0x00000000FF
                    shift: 0
                GRAY:
                    mask: 0xFF000000
                    shift: 24
            f = CHANNEL[channel]
            ( ( pixel & f.mask ) >>> f.shift )

        _getPixelData: (pixel) ->
            converted = 0
            bits = 0
            if @colorType == 2 || @colorType == 6
                converted = ( ( converted << @BITDEPTH ) | ( @_getPixelChannel(pixel, 'RED') & @BITDEPTH ) )
                converted = ( ( converted << @BITDEPTH ) | ( @_getPixelChannel(pixel, 'GREEN') & @BITDEPTH ) )
                converted = ( ( converted << @BITDEPTH ) | ( @_getPixelChannel(pixel, 'BLUE') & @BITDEPTH ) )
                bits += ( 3 * @bitDepth )
            else # @colorType == 0 || @colorType == 4 and fallback for other - use grayscale
                converted = ( ( converted << @BITDEPTH ) | ( @_getPixelChannel(pixel, 'GRAY') & @BITDEPTH ) )
                bits += @bitDepth
            if @colorType == 4 || @colorType == 6
                converted = ( ( converted << @BITDEPTH ) | ( @_getPixelChannel(pixel, 'ALPHA') & @BITDEPTH ) )
                bits += @bitDepth
            [converted, bits]

        _convertToByteArray: () ->
            @data = ''
            fillByte = 0
            fillByteFilled = 0
            for i in [0 ... @inputData.length]
                [newPixel, bits] = @_getPixelData(@inputData[i])
                if fillByteFilled + bits >= 8
                    remBits = fillByteFilled + bits - 8
                    takeData = (newPixel >>> remBits )
                    @data += String.fromCharCode( fillByte | takeData )
                    fillByte = (newPixel << (8 - remBits)) & 0xFF
                    fillByteFilled = remBits
                else
                    takeData = newPixel << (8 - fillByteFilled - bits)
                    fillByte = fillByte | takeData
                    fillByteFilled = fillByteFilled + bits
            if fillByteFilled > 0
                @data += String.fromCharCode( fillByte ) # ( fillByte << (8 - fillByteFilled)
            @byteArrayLineWidth = Math.ceil( @width * @colorDepth / 4)

            console.log(@data.length)
        _filter: () ->
            filteredData = ''
            console.log(@data)
            console.log(@width)
            if @lineFilter == 0 # raw
                for y in [ 0 ... @height ]
                    filteredData += @LINE_FILTER
                    filteredData += @data.substr(y * @byteArrayLineWidth, @byteArrayLineWidth)
#                    for x in [ 0 ... @width ]
#                        filteredData += @data[ y * @width + x]
#                        console.log('' + y + '/' + x)
#                        console.log(filteredData)
            filteredData
        # http://en.wikipedia.org/wiki/DEFLATE
        _adler32: (data) ->
            MOD_ADLER = 65521
            a = 1
            b = 0
            for i in [0 ... data.length]
                a = (a + data.charCodeAt(i)) % MOD_ADLER
                b = (b + a) % MOD_ADLER
            (b << 16) | a
        _byte: (dword, num) ->
            if num == 0
                (dword & 0xFF000000) >>> 24
            else if num == 1
                (dword & 0x00FF0000) >>> 16
            else if num == 2
                (dword & 0x0000FF00) >>> 8
            else
                (dword & 0x000000FF)

        _word: (r) -> String.fromCharCode(@_byte(r, 0), @_byte(r, 1), @_byte(r, 2), @_byte(r, 3))
        _reverseEndianBottom16: (r) -> String.fromCharCode(@_byte(r, 3), @_byte(r, 2))
        _deflate: (data) ->
            DATA_COMPRESSION_METHOD = String.fromCharCode(0x78, 0x01)
            MAX_STORE_LENGTH = 65535
            storeBuffer = ''
            for i in [0 ... data.length] by MAX_STORE_LENGTH
                remaining = data.length - i
                if remaining <= MAX_STORE_LENGTH
                    blockType = String.fromCharCode(0x01)
                else
                    remaining = MAX_STORE_LENGTH
                    blockType = String.fromCharCode(0x00)
                storeBuffer += blockType + @_reverseEndianBottom16(remaining) + @_reverseEndianBottom16(~remaining)
                storeBuffer += data.substring(i, i + remaining)
            DATA_COMPRESSION_METHOD + storeBuffer + @_word(@_adler32(data))

        imageData: () ->
            @_convertToByteArray()
            filteredData = @_filter()
            console.log(filteredData)
            compressedData = @_deflate(filteredData)
            console.log(compressedData)

            SIGNATURE = @chunker.SIGNATURE()
            IHDR = @chunker.IHDR(@width, @height, @bitDepth, @colorType)
            IDAT = @chunker.IDAT(compressedData)
            IEND = @chunker.IEND()
            SIGNATURE + IHDR + IDAT + IEND
#    for each line, its own type
#    Type byte	Filter name	Predicted value
#    0	None	Zero (so that the raw byte value passes through unaltered)
#    1	Sub	Byte A (to the left)
#    2	Up	Byte B (above)
#    3	Average	Mean of bytes A and B, rounded down
#    4	Paeth	A, B, or C, whichever is closest to p = A + B − C



    # PNG uses a 2-stage compression process:
    #  1. pre-compression: filtering (prediction)
    #  2. compression: DEFLATE
    class Encoder
        constructor: ->
            @Chunker = Chunker
            @Data = Data
#
#        createPng: (width, height, rgba) ->
#            DATA_COMPRESSION_METHOD = String.fromCharCode(0x78, 0x01)
#            LINE_FILTER = String.fromCharCode(0)  # 0:none, 1: left, 2:above, 3: floored avg of left and above, 4: A,B, or C, closest to (A+B-C)
#            chunker = new Chunker(@f)
#
#            filteredData = ''
#            for y in [ 0 ... rgba.length ] by (width * 4)
#                filteredData += LINE_FILTER
#                if (Array.isArray(rgba))
#                    for x in [ 0 ... (width * 4) ]
#                        filteredData += String.fromCharCode(rgba[y + x] & 0xff) # r,g,b,a, r,g,b,a,... must be array of integers with lower 8 bits repr...
#                else
#                    filteredData += rgba.substr(y, width * 4)
#
#            compressedData = DATA_COMPRESSION_METHOD + @f.deflate(filteredData) + @f.fullWord(@f.adler32(filteredData))
#
#            SIGNATURE = chunker.SIGNATURE()
#            IHDR = chunker.IHDR(width, height)
#            IDAT = chunker.IDAT(compressedData)
#            IEND = chunker.IEND()
#            SIGNATURE + IHDR + IDAT + IEND

    new Encoder()
]