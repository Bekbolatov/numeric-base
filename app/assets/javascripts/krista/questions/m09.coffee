angular.module('Krista')

.factory "M09", ['KristaData', 'KristaUtil', 'GraphicsManager', (KristaData, KristaUtil, GraphicsManager ) ->
    class M09
        u: KristaUtil
        generate: ->
            a = @u.random(3, 10)
            b = @u.random(3, 10)
            if a %2 == 1 && b % 2 == 1
                a = a + 1

            img = GraphicsManager.newImageWhite(300, 200)
            img.drawLine(0,0, a*10, b*10)
            imgdata = img.getBase64()

            [  ['If the area of a triangle is ½ × base × vertical height, what is the area of the triangle?', [0,0,0,a,b] ], 0, [imgdata]]

    new M09()
]