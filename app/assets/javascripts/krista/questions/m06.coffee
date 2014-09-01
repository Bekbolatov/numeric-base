angular.module('Krista')

.factory "M06", ['KristaData', 'KristaUtil', 'GraphicsManager', (KristaData, KristaUtil, GraphicsManager ) ->
    class M06
        u: KristaUtil
        generate: ->
            _activity = 'the scores that 5 students earned on a quiz'
            _scores = 'scores'

            [mina, maxa] = [50, 92]
            as = []
            for i in [1 .. 5]
                as.push @u.random(mina, maxa + 1)
            names = @u.randomNames(5)

            pickedIndices = @u.randomNonRepeating([0 .. 4], 2)

            correct = ( as[pickedIndices[0]] + as[pickedIndices[1]] ) / 2
            inc = [
                correct + @u.randomFromList([-2.5, 2.5, -5, 5])
                correct + @u.randomFromList([-7.5, 7.5, -10, 10, -10.5, 10.5])
                correct + @u.randomFromList([-15.5, 15.5, -15, 15, -20.5, 20.5, -20, 20])
                correct + @u.randomFromList([-25.5, 25.5, -25, 25, -30.5, 30.5, -30, 30])
            ]
            [answers, index] = @u.shuffleAnswers4(inc, correct)

            maxScore = 100
            canvas_height = 250
            canvas_width = 300

            [xtick, ytick] = [ canvas_width / 5 , canvas_height / 10 ]
            Ky = canvas_height/maxScore
            gridColor = 'L'
            tickBump = 3

            boxColor = 'G'
            boxPadding = 10

            img = GraphicsManager.newImageWhiteWithOffset(canvas_width, canvas_height, 25 )
            for i in [0 .. 10]
                img.drawLine(  -tickBump,i*ytick   ,  canvas_width,i*ytick   , gridColor) # horizontal
            for i in [0 .. 5]
                img.placeCharSequenceCentered(-13,2*i*ytick , '' + i*20) # labels on even horizontals
                img.drawLine(  i*xtick,-tickBump   ,  i*xtick,canvas_height  , gridColor) # vertical
            for i in [0 .. 4]
                img.fillRectangleCoords(  i*xtick + boxPadding,0   ,  (i + 1)*xtick - boxPadding,Ky * as[i]  , boxColor) # boxes
                img.placeCharSequence((i + 0.5)*xtick - 6,Ky * as[i] + 4, '' + as[i])
                img.placeCharSequenceCentered((i + 0.5)*xtick, -6, '' + names[i].toUpperCase())

            imgdata = img.getBase64()

            [  ['The graph shows ' + _activity + '. What is the average of ' + names[pickedIndices[0]] + ' and ' + names[pickedIndices[1]] + '\'s ' + _scores + '?' , answers], index, [imgdata]]

    new M06()
]