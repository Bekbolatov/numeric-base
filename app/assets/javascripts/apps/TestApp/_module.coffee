angular.module 'TestApp', ['ImagePng']

.controller 'TestCtrl', [ '$scope', '$sce', 'GenerateImagePng', ($scope, $sce, GenerateImagePng ) ->
    showBit = (integer, i) -> ( (integer >>> i) & 0x01 )  # i = 31, 30, ..., 1, 0
    showByte = (integer) ->
        out = ''
        for i in [ 7 .. 0 ]
            out += showBit(integer, i)
            if i % 8 == 0
                out += ' '
        out
    showBinary = (integer) ->
        out = ''
        for i in [ 31 .. 0 ]
            out += showBit(integer, i)
            if i % 8 == 0
                out += ' '
        out
    stringBinary = (s) ->
        if s == undefined
            return ''
        o = ''
        for i in [0 ... s.length]
            o += showByte(s.charCodeAt(i))
        o
    updateBin = () ->
        $scope.bA = showBinary($scope.A)
        $scope.bB = showBinary($scope.B)
        $scope.bC = showBinary($scope.C)
        $scope.zz = stringBinary($scope.Z)
        $scope.Y = btoa($scope.Z)

    $scope.clicked = (letter) ->
        if letter == 'Z'
            $scope.Z = $scope.inputData
        $scope[letter] = $scope.inputData
        updateBin()

    $scope.A = 0
    $scope.B = 0
    $scope.C = 0
    updateBin()

    $scope.oper = (o) ->
        a = $scope.A
        b = $scope.B
        c = $scope.C
        if o == '<<'
            a = a << 1
        else if o == '>>'
            a = a >> 1
        else if o == '>>>'
            a = a >>> 1
        else if o == '~'
            c = ~a
        else if o == '&'
            c = a & b
        else if o == '|'
            c = a | b
        else if o == '^'
            c = a ^ b
        else if o == '0x0F'
            a = 0x0F
        else if o == '0xF0'
            a = 0xF0
        else if o == '0xFF'
            a = 0xFF
        else if o == '0xFF00'
            a = 0xFF00
        else if o == '0xFF0F00'
            a = 0xFF0F00
        else if o == '0xFF000000'
            a = 0xFF000000
        else if o == '0xF0000000'
            a = 0xF0000000
        else if o == '0x0F000000'
            a = 0x0F000000
        else if o == '0x1000100F'
            a = 0x1000100F
        else if o == 'B'
            b = a

        $scope.A = a
        $scope.B = b
        $scope.C = c
        updateBin()



    p = GenerateImagePng
#    Chunker = p.Chunker
#    Data = p.Data
#    Functions = p.Functions

    showIntArrayBin = (ar) ->
        o = ''
        for n in ar
            o += showBinary(n) + '<br>'
        o


    showStringBin = (str) ->
        o = ''
        for i in [0 ... str.length ]
            o += showBinary(str.charCodeAt(i)) + ' '
        o

    updateD = () ->
        $scope.dd = $sce.trustAsHtml(showStringBin($scope.D))
    $scope.D = [0,1,255,256]

    $scope.inputData1 = "1 1 1 1 1 1"
    $scope.inputData2 = "1 1 1 1 1 1"
    $scope.inputData3 = "1 1 1 1 1 1"
    $scope.inputData4 = "1 1 1 1 1 1"
    $scope.bitDepth = 8
    $scope.width = 2
    $scope.height = 3
    $scope.imgSize = 0
    $scope.color = 0
    $scope.printLogs = false
    $scope.compress = false
    $scope.filterMethod = 0

    $scope.opera = (o) ->
        if o == 'in'
            r = $scope.inputData.split(' ')
            $scope.D = ( (parseInt(n)) for n in r when r.length > 0 )
        else if o == 'inn'
            r1 = ( (parseInt(n)) for n in $scope.inputData1.split(' ') when n.length > 0 )
            r2 = ( (parseInt(n)) for n in $scope.inputData2.split(' ') when n.length > 0 )
            r3 = ( (parseInt(n)) for n in $scope.inputData3.split(' ') when n.length > 0 )
            r4 = ( (parseInt(n)) for n in $scope.inputData4.split(' ') when n.length > 0 )
            w = []
            s = ''
            for i in [0 ... r1.length]
                s += String.fromCharCode(r1[i], r2[i], r3[i], r4[i])
                w[i] = r1[i] << 24 | r2[i] << 16 | r3[i] << 8  | r4[i]



            if $scope.imgSize == 0
                $scope.width = 2
                $scope.height = 3
            else if $scope.imgSize == 1
                $scope.width = 30
                $scope.height = 30
            else if $scope.imgSize == 2
                $scope.width = 100
                $scope.height = 101
            else if $scope.imgSize == 3
                $scope.width = 230
                $scope.height = 230
            else
                $scope.width = 2
                $scope.height = 3

            if $scope.imgSize > 0
                $scope.printLogs = false


#            ddi = []
#            for y in [ 0 .. 128 ]
#                for x in [ 0 .. 128 ]
#                    ddi[y * 128 + x] = ( 255 << 24 )



 #               color type: 6=truecolor with alpha; 3 (indexed color); 2 (truecolor); 0,4 (Grayscale, and with alpha)

            ddi = []
            [thiswidth, thisheight] = [$scope.width, $scope.height]



            bell = (x,y) ->
                r = ( 1.0 * Math.sqrt(Math.pow( (y - thisheight/2), 2) +  Math.pow( (x - thiswidth/2), 2)) ) / thisheight
                M = 255 #Math.pow(2,$scope.bitDepth ) - 1

                v = Math.min 0.999, (Math.max 0,  1 - Math.exp(- 100*r * r))

                V = Math.round(M*v)

                (V << 24) | (V << 16) | (V << 8) | M

            f = (x,y) ->
                r = ( 1.0 * Math.sqrt(Math.pow( (y - thisheight/2), 2) +  Math.pow( (x - thiswidth/2), 2)) ) / thisheight
                M = 255 #Math.pow(2,$scope.bitDepth ) - 1
                #############

                #  distant star
#                r = Math.max(0.02, r)
#                v = Math.max 0,  (1.0 / r    + 1)
                # dark spot
#                r = Math.max(0.02, r)
#                v = Math.max 0,  ( 1 - (100.0 / (r * r)) )
                # bell
                v = Math.min 0.999, (Math.max 0,  1 - Math.exp(- 100*r * r))

                #v in [0, 1)
                V = Math.round(M*v)
                (V << 24) | (V << 16) | (V << 8) | M
                (V << 16)*(x / thiswidth) | (V << 8) |  M
                (V << 24) | M


            for y in [ 0 ... thisheight ]
                for x in [ 0 ... thiswidth ]
                    ddi[y * thiswidth + x] = bell x, y

            DD = new p.Data(Number($scope.bitDepth), Number($scope.color), $scope.filterMethod, $scope.compress, ddi, thiswidth, thisheight)
            DD.printData = $scope.printLogs
            window.DD = DD

            $scope.imgdata = 'data:image/png;base64,' + btoa(DD.imageData())
            $scope.imgdatasize = ((0.75 * $scope.imgdata.length) / 1024).toFixed(3)
            #$scope.D = RawDeflate.deflate("as", 6)
            #$scope.dhex = $sce.trustAsHtml(DD.h.hex($scope.D))
#        updateD()
        updateBin()

]