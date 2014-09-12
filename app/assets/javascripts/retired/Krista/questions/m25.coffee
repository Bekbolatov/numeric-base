angular.module('Krista')

.factory "M25", ['RandomFunctions', 'GraphicsManager', 'HyperTextManager', (RandomFunctions, GraphicsManager, HyperTextManager ) ->
    class M25
        u: RandomFunctions
        h: HyperTextManager
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

            correct = a * 3 + b * 2
            inc = [
                correct + a
                correct - a
                correct - 2 * b
                correct + @u.random(1, 3)
            ]

            [answers, index] = @u.shuffleAnswers4(inc, correct)

            [  ['What is the perimeter of the shape shown below?' + @h.graphic(imgdata), answers], index]

    new M25()
]