angular.module('Krista')

.factory "M25", ['KristaData', 'KristaUtil', 'GraphicsManager', (KristaData, KristaUtil, GraphicsManager ) ->
    class M25
        u: KristaUtil
        generate: ->
            an = @u.random(4, 12)
            ah = Math.ceil(an/2)
            ahp = Math.floor(an * 3 / 2)

            bn = @u.random(ah + 1, ahp)

            a = an/2
            b = bn/2

            aa = 100
            K = aa/a
            bb = b * K

            cc = Math.sqrt( bb*bb - (aa*aa / 4) )

            img = GraphicsManager.newImageWhiteWithOffset(aa + cc, aa, 20 )

            dark = 'D'
            img.drawLine(0,0, 0,aa, dark)
            img.drawLine(0,aa, aa,aa, dark)
            img.drawLine(aa,aa, aa + cc, aa/2, dark)
            img.drawLine(aa + cc, aa/2, aa,0, dark)
            img.drawLine(aa,0, 0,0, dark)

            img.placeCharSequence(Math.floor(aa/2) - 4 , -11, '' + a)
            img.placeCharSequence(-19, Math.floor(aa/2), '' + a)
            img.placeCharSequence(Math.floor(aa/2) - 4 , aa + 4, '' + a)

            img.placeCharSequence(Math.floor(aa + cc/2) , (aa * 3 / 4) + 7, '' + b)
            img.placeCharSequence(Math.floor(aa + cc/2)  , (aa / 4) - 11, '' + b)

            imgdata = img.getBase64()

            [  ['The area of the rectangle shown is ' + a*b + ' centimeters squared. The length of one of the sides is ' + a + ' centimeters. What is the length of the other side?' ], b, [imgdata]]

    new M25()
]