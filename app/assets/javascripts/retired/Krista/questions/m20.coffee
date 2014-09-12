angular.module('Krista')

.factory "M20", ['RandomFunctions', 'GraphicsManager', 'HyperTextManager', (RandomFunctions, GraphicsManager, HyperTextManager ) ->
    class M20
        u: RandomFunctions
        h: HyperTextManager
        generate: ->
            a = @u.random(3, 9)
            b = @u.random(4, 10)
            if a %2 == 1 && b % 2 == 1
                a = a + 1

            bb = 110
            K = bb/b
            aa = a * K

            img = GraphicsManager.newImageWhiteWithOffset(aa + bb, bb, 20 )

            img.drawTriangle(bb,0, bb,bb, bb + aa,0, 'B')

            img.drawRectangle(0,0, bb, bb, 'B')

            img.placeCharSequence(Math.floor(bb/2) - 4 , -11, '' + b)
            img.placeCharSequence(bb - 10, Math.floor(bb/2), '' + b)
            img.placeCharSequence(bb + Math.floor(aa/2) - 4 , -11, '' + a)

            imgdata = img.getBase64()

            [  ['If the area of a triangle is ½ × base × vertical height, what is the combined area of the square and triangle below?' + @h.graphic(imgdata) ], b*b + Math.round(a * b / 2)]

    new M20()
]