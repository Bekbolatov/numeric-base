angular.module 'ImagePng', []

.factory 'GenerateImageBmp', [ () ->
    class Encoder
        _getLittleEndianHex: (value) ->
            result = []
            for bytes in [4 .. 1]
                result.push(String.fromCharCode(value & 255))
                value >>= 8
            result.join('')

        _header: (width, height) ->
            numFileBytes = @_getLittleEndianHex(width * height)
            w = @_getLittleEndianHex(width)
            h = @_getLittleEndianHex(height)

            header = '' +
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
            header

        encode: (stringData, width, height) -> # stringData is a array of String.fromCharCode( R, G, B, A)
            header = @_header(width, height)
            outputData = header + stringData.join('')
            if window.btoa
                encodedData = window.btoa(outputData)
            else
                encodedData = $.base64.encode(outputData)
            'data:image/bmp;base64,' + encodedData

    new Encoder()
]