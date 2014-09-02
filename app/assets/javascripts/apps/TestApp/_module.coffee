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
    updateD = () ->
        $scope.dd = $sce.trustAsHtml(showIntArrayBin($scope.D))
    $scope.D = [0,1,255,256]
    updateD()

    $scope.inputData1 = "1 1 1 1 1 1"
    $scope.inputData2 = "1 1 1 1 1 1"
    $scope.inputData3 = "1 1 1 1 1 1"
    $scope.inputData4 = "1 1 1 1 1 1"
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
            $scope.D = w

            ddi = []
            for y in [ 0 .. 128 ]
                for x in [ 0 .. 128 ]
                    ddi[y * 128 + x] = ( 255 << 24 )

            $scope.DD = new p.Data(8, 0, 0, 0, ddi, 128, 128)
            $scope.DD._convertToByteArray()
            window.DD = $scope.DD
            $scope.Z = $scope.DD.data
            $scope.imgdata = 'data:image/png;base64,' + btoa($scope.DD.imageData())

#            $scope.htmldata = $sce.trustAsHtml(data)
        updateD()
        updateBin()

]