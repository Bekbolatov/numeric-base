angular.module 'ImagePng', []

# PNG uses zlib, which uses Deflate, Deflate uses Huffman coding. Deflate algorithm in js is used from rawdeflate.js - written by Masanao Izumo (1999) - thank you
.factory 'GenerateImagePng', [() ->
    class Chunker # generate chunks with cyclic redundancy check
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

    class Palette
        constructor: (@bitDepth) ->
            @sizeMaxValue = Math.pow(2, @bitDepth) - 1
            @size = 0
            @entries = {}
            @colors = []
        color: (y) ->
            value = 0
            entry = @entries[y]
            if entry != undefined
                value = entry
            else if @size <= @sizeMaxValue
                value = @size
                @entries[y] = value
                @colors.push(y)
                @size += 1
            value
        getData: ->
            s = ''
            for color in @colors
                s += String.fromCharCode(color >>> 24)
                s += String.fromCharCode((color << 8) >>> 24)
                s += String.fromCharCode((color << 16) >>> 24)
            s

    # Supported bitdepth:
    #  grayscale, indexed: 1, 2, 4, 8
    #  truecolor: 8
    #  attach alpha: 8
    class Data # assuming @inputData is of the form of int array of RGBA: [ int word(R,G,B,A/0), ], previously [ String.fromCharCode(R,G,B,A/0), ... ] or Gray:[ String.fromCharCode(Gray,0,0,A/0), ... ]
        constructor: (@bitDepth, @colorType, @filterMethod, @compressionLevel, @inputData, @width, @height) ->
            @h = new Hex()
            @chunker = new Chunker()
            @deflate = new Deflate()
            @printData = false
            COLORTYPE =
                0:
                    channels: 1
                2:
                    channels: 3
                3:
                    channels: 1
                4:
                    channels: 2
                6:
                    channels: 4
            @channels = COLORTYPE[@colorType].channels
            if @colorType == 3
                @palette = new Palette(@bitDepth)
            @colorDepth = @bitDepth * @channels
            if @bitDepth == 1
                @BITDEPTHMASK = 0x00000001
            else if @bitDepth == 2
                @BITDEPTHMASK = 0x00000003
            else if @bitDepth == 4
                @BITDEPTHMASK = 0x0000000F
            else
                @BITDEPTHMASK = 0x000000FF

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
            sample = ( ( pixel & f.mask ) >>> f.shift ) # & @BITDEPTHMASK
            sample

        _getPixelData: (pixel) ->
            converted = 0x00000000
            bits = 0
            downSampleShift = 8 - @bitDepth
            if @colorType == 2 || @colorType == 6
                converted = ( converted << @bitDepth ) | ( @_getPixelChannel(pixel, 'RED') >>> downSampleShift )
                converted = ( converted << @bitDepth ) | ( @_getPixelChannel(pixel, 'GREEN') >>> downSampleShift )
                converted = ( converted << @bitDepth ) | ( @_getPixelChannel(pixel, 'BLUE') >>> downSampleShift )
                bits += ( 3 * @bitDepth )
            else if @colorType == 3
                converted = ( converted << @bitDepth ) | @palette.color(pixel)
                bits += @bitDepth
            else
                converted = ( converted << @bitDepth ) | ( @_getPixelChannel(pixel, 'GRAY') >>> downSampleShift )
                bits += @bitDepth

            if @colorType == 4 || @colorType == 6
                converted = ( converted << @bitDepth ) | ( @_getPixelChannel(pixel, 'ALPHA') >>> downSampleShift )
                bits += @bitDepth
            [converted, bits]

        _fillBytePushLeft: (byte, index, word, bits) ->
            w = word
            []
        _convertToByteArray: () ->
            @data = ''
            for y in [0 ... @height]
                fillByte = 0x00
                fillByteFilled = 0
                for x in [0 ... @width]
                    [newPixel, bits] = @_getPixelData(@inputData[y * @width + x])
                    while fillByteFilled + bits >= 8
                        takeBits = 8 - fillByteFilled
                        bottomChop = bits - takeBits #32 - takeBits
                        takeData = (newPixel >>> bottomChop )
                        newByte = (fillByte | takeData) & 0xFF
                        if newByte > 255
                            console.log('OUT:' + x + ',' + y + ': ' + newByte)
                        @data += String.fromCharCode( newByte )
                        fillByte = 0x00
                        fillByteFilled = 0
                        bitsNow = bits - takeBits
                        bitsNowLeftSide = 32 - bitsNow
                        newPixel = ( ( newPixel << bitsNowLeftSide )  >>>  bitsNowLeftSide )
                        bits = bitsNow
                    if bits > 0
                        fillByte = 0xFF & (fillByte | (newPixel << (8 - fillByteFilled - bits) ) ) #(32 - bits))
                        fillByteFilled = fillByteFilled + bits
                if fillByteFilled > 0
                    @data += String.fromCharCode( fillByte ) # ( fillByte << (8 - fillByteFilled)
            @byteArrayLineWidth = Math.ceil( @width * @colorDepth / 8)

        _filter: () ->
            if @filterMethod > 0
                @_filterSubAndUp()
            else
                @_filterZero()

        _filterSubAndUp: () ->
            console.log('filter')
            LINE_FILTER_SUB = String.fromCharCode(1)
            LINE_FILTER_UP = String.fromCharCode(2)
            if @colorDepth < 8
                step = 1
            else
                step = @colorDepth / 8
            filteredData = LINE_FILTER_SUB + @data.substr( 0, step)
            for x in [ step ... @byteArrayLineWidth  ] by step
                for i in [ 0 ... step ]
                    index = x + i
                    cur = @data.charCodeAt(index)
                    prev = @data.charCodeAt(index - step)
                    filteredData += String.fromCharCode( ( cur - prev ) & 0xFF)
            for y in [ 1 ... @height ]
                filteredData += LINE_FILTER_UP
                for x in [ 0 ... @byteArrayLineWidth  ] by step
                    for i in [ 0 ... step ]
                        index = y * @byteArrayLineWidth + x + i
                        cur = @data.charCodeAt(index)
                        prev = @data.charCodeAt(index - @byteArrayLineWidth)
                        filteredData += String.fromCharCode( ( cur - prev ) & 0xFF)
            filteredData

        _filterZero: () ->
            LINE_FILTER = String.fromCharCode(0)
            filteredData = ''
            for y in [ 0 ... @height ]
                filteredData += LINE_FILTER + @data.substr(y * @byteArrayLineWidth, @byteArrayLineWidth)
            filteredData

        _adler32: (data) ->
            MOD_ADLER = 65521
            FLUSH = 5550 # maybe 5551 is okay: 255*(1+2+...+n) + (n+1)*(MOD_ADLER-1) <= 2^32-1
            a = 1
            b = 0
            n = 0
            for i in [0 ... data.length]
                a += data.charCodeAt(i)
                b += a
                if (n += 1) > FLUSH
                    a = a % MOD_ADLER
                    b = b % MOD_ADLER
                    n = 0
            a = a % MOD_ADLER
            b = b % MOD_ADLER
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
        _littleEndianShort: (r) -> String.fromCharCode(@_byte(r, 3), @_byte(r, 2))

        _deflate: (data) ->
            if @compressionLevel > 0
                @_deflateCompression(data, @compressionLevel)
            else
                @_deflateNoCompression(data)

        _deflateCompression: (data, level) -> # http://www.faqs.org/rfcs/rfc1950.html
            console.log('compression')
            DATA_COMPRESSION_METHOD = String.fromCharCode(0x78, 0x9c) # CINFO(n-> 2^(n+8) window size), CM(8=deflate) / FLG: 7-6 FLEVEL, 5 FDICT pres?, 4-0 FCHECK (CMF*256 + FLG % 31 = 0)
            storeBuffer = @deflate.encode(data, level) # default 6, max 9
            DATA_COMPRESSION_METHOD + storeBuffer + @_word(@_adler32(data))

        _deflateNoCompression: (data) -> # http://www.faqs.org/rfcs/rfc1950.html
            DATA_COMPRESSION_METHOD = String.fromCharCode(0x08, 0x1D) # CINFO(n-> 2^(n+8) window size), CM(8=deflate) / FLG: 7-6 FLEVEL, 5 FDICT pres?, 4-0 FCHECK (CMF*256 + FLG % 31 = 0)
            MAX_STORE_LENGTH = 65535
            storeBuffer = ''
            for i in [0 ... data.length] by MAX_STORE_LENGTH
                remaining = data.length - i
                if remaining <= MAX_STORE_LENGTH
                    blockType = String.fromCharCode(0x01)
                else
                    remaining = MAX_STORE_LENGTH
                    blockType = String.fromCharCode(0x00)
                storeBuffer += blockType + @_littleEndianShort(remaining) + @_littleEndianShort(~remaining)
                storeBuffer += data.substring(i, i + remaining)
            DATA_COMPRESSION_METHOD + storeBuffer + @_word(@_adler32(data))

        imageData: () ->
            @_convertToByteArray()
            filteredData = @_filter()
            compressedData = @_deflate(filteredData)

            SIGNATURE = @chunker.SIGNATURE()
            IHDR = @chunker.IHDR(@width, @height, @bitDepth, @colorType)
            if @colorType == 3
                PLTE = @chunker.PLTE(@palette.getData())
            else
                PLTE = ''
            IDAT = @chunker.IDAT(compressedData)
            IEND = @chunker.IEND()

            if @printData
                @h.printHexOfListOfInts(@inputData, 'inputData')
                @h.printHex(@data, 'byteData')
                @h.printHex(filteredData, 'filteredData')
                if @colorType == 3
                    @h.printHex(@palette.getData(), 'palette')
                @h.printHex(compressedData, 'compresedData', [2, 4])
                @h.printHex(IDAT, 'IDAT')

            if @colorType == 3
                @h.printHex(@palette.getData(), 'palette')

            SIGNATURE + IHDR + PLTE + IDAT + IEND

    class Deflate
        encode: (data, level) -> # stick 3rd party deflate algorithm in here
            RawDeflate.deflate(data, level)

    class Hex
        hexStringOfByte: (b) ->
            d1 = ( b & 0x000000F0 )  >>> 4
            d2 = b & 0x0000000F
            t = (d) ->
                if d < 10
                    '' + d
                else if d == 10
                    'A'
                else if d == 11
                    'B'
                else if d == 12
                    'C'
                else if d == 13
                    'D'
                else if d == 14
                    'E'
                else
                    'F'
            t(d1) + t(d2) + ' '

        hex: (ins, maybeName, hf) ->
            if hf
                header = hf[0]
                footer = hf[1]
            s = ''
            for i in [ 0 ... ins.length ]
                s += @hexStringOfByte(ins.charCodeAt(i))
                if hf && i == header - 1
                    s += '[ '
                if hf && i == ins.length - footer - 1
                    s += '] '
            s
        printHex: (ins, maybeName, hf) ->
            s = @hex(ins, maybeName, hf)
            s = '[' + maybeName + ', ' + ins.length + '] '  + s
            console.log(s)

        printHexOfListOfStrings:  (list, label) ->
            s = ''
            for w in list
                s += @hexOfString(w)
            console.log('[' + label + '] ' + s)

        printHexOfListOfInts:  (list, label) ->
            s = ''
            for w in list
                s += @hexOfInt(w)
            console.log('[' + label + '] ' + s)

        hexOfInt: (word) ->
            @hexStringOfByte(word >>> 24) + ' ' + @hexStringOfByte( (word << 8) >>> 24) + ' ' + @hexStringOfByte( (word << 16) >>> 24) + ' ' + @hexStringOfByte( (word << 24) >>> 24) + ' '

        hexOfString: (string, label) ->
            s = ''
            for i in [ 0 ... string.length ]
                word = string.charCodeAt(i)
                s += @hexOfInt(word)
            s

    class Encoder
        constructor: ->
            @Chunker = Chunker
            @Data = Data
            @hex = new Hex()

            @COLOR_GRAYSCALE = 0
            @COLOR_INDEXED = 3
            @COLOR_RGB = 2

            @COLOR = @COLOR_INDEXED
            @COMPRESSION_LEVEL = 6
            @FILTER_METHOD = 0
            @BIT_DEPTH = 2


        encode: (stringData, width, height, colorStyle, filterMethod, compressionLevel) -> # stringData is a array of String.fromCharCode( R, G, B, A)
            if compressionLevel == undefined
                compressionLevel = @COMPRESSION_LEVEL
            if filterMethod == undefined
                filterMethod = @FILTER_METHOD
            if colorStyle == undefined
                colorStyle = @COLOR_GRAYSCALE
            intData = []
            for y in [ 0 ... height ]
                for x in [ 0 ... width ]
                    s = stringData[ (height - y - 1) * width + x ]
                    r = s.charCodeAt(0)
                    g = s.charCodeAt(1)
                    b = s.charCodeAt(2)
                    a = s.charCodeAt(3)
                    intData[ width * y + x ] = (r << 24) | (g << 16) | (b << 8) | a

            image = new Data(@BIT_DEPTH, @COLOR_INDEXED, filterMethod, compressionLevel, intData, width, height)
            image.printData = false
            'data:image/png;base64,' + btoa(image.imageData())
    new Encoder()
]