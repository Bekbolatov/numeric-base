angular.module('Krista')

.factory "M09", ['KristaData', 'KristaUtil', 'GraphicsManager', (KristaData, KristaUtil, GraphicsManager ) ->
    class M09
        u: KristaUtil
        generate: ->
            a = @u.random(3, 10)
            b = @u.random(3, 10)
            if a %2 == 1 && b % 2 == 1
                a = a + 1

            K = 15
            aa = a * K
            bb = b * K

            img = GraphicsManager.newImageWhiteWithOffset(aa, bb, 20 )

            img.drawTriangle(0,0, 0,bb, aa,0, 'b')

            img.drawRectangle(0,0, 10, 10, 'r')

            img.placeCharSequence(15, 15, '102')

            imgdata = img.getBase64()

            [  ['If the area of a triangle is ½ × base × vertical height, what is the area of the triangle?', [0,0,0,a,b] ], 0, [imgdata]]

    new M09()
]