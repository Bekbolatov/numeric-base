angular.module('Krista')

.factory "M12", ['KristaData', 'KristaUtil', 'GraphicsManager', (KristaData, KristaUtil, GraphicsManager ) ->
    class M12
        u: KristaUtil
        generate: ->
            a = @u.random(3, 9)
            b = @u.random(4, 10)

            bb = 110
            K = bb/b
            aa = a * K

            img = GraphicsManager.newImageWhiteWithOffset(aa, bb, 20 )

            img.drawRectangle(0,0, aa, bb, 'B')

            img.placeCharSequence(Math.floor(aa/2) - 4 , -11, '' + a)
            img.placeCharSequence(-10, Math.floor(bb/2), '?')

            imgdata = img.getBase64()

            [  ['The area of the rectangle shown is ' + a*b + ' centimeters squared. The length of one of the sides is ' + a + ' centimeters. What is the length of the other side?' ], b, [imgdata]]

    new M12()
]