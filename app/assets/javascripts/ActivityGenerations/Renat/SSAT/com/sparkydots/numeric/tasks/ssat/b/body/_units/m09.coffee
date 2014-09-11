class M09
    u: document.numeric.modules.RandomFunctions
    h: document.numeric.modules.HyperTextManager
    g: document.numeric.modules.GraphicsManager

    generate: ->
        a = @u.random(3, 9)
        b = @u.random(4, 10)
        if a %2 == 1 && b % 2 == 1
            a = a + 1

        bb = 110
        K = bb/b
        aa = a * K

        img = @g.newImageWhiteWithOffset(aa, bb, 20 )

        img.drawTriangle(0,0, 0,bb, aa,0, 'B')

        img.drawRectangle(0,0, 10, 10, 'B')

        img.placeCharSequence(Math.floor(aa/2) - 4 , -11, '' + a)
        img.placeCharSequence(-10, Math.floor(bb/2), '' + b)

        imgdata = img.getBase64()

        [  ['If the area of a triangle is ½ × base × vertical height, what is the area of the triangle?' + @h.graphic(imgdata) ], Math.round(a * b / 2) ]

