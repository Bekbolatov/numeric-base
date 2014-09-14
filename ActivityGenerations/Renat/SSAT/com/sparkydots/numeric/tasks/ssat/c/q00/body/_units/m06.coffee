class M06
    u: document.numeric.modules.DataUtilities
    r: document.numeric.modules.RandomFunctions
    h: document.numeric.modules.HyperTextManager
    g: document.numeric.modules.GraphicsManager

    generate: ->
        _activity = 'the scores that 5 students earned on a quiz'
        _scores = 'scores'

        [mina, maxa] = [50, 92]
        as = []
        for i in [1 .. 5]
            as.push @r.random(mina, maxa + 1)
        names =  ( name[0] for name in @u.randomNames(5, (n) -> (n.length < 9) ) )

        pickedIndices = @r.randomNonRepeating([0 .. 4], 2)

        correct = ( as[pickedIndices[0]] + as[pickedIndices[1]] ) / 2
        inc = [
            correct + @r.randomFromList([-2.5, 2.5, -5, 5])
            correct + @r.randomFromList([-7.5, 7.5, -10, 10, -10.5, 10.5])
            correct + @r.randomFromList([-15.5, 15.5, -15, 15, -20.5, 20.5, -20, 20])
            correct + @r.randomFromList([-25.5, 25.5, -25, 25, -30.5, 30.5, -30, 30])
        ]
        [answers, index] = @r.shuffleAnswers4(inc, correct)

        maxScore = 100
        canvas_height = 250
        canvas_width = 250
        offset_left = 35
        offset_right = 5
        offset_top = 5
        offset_bottom = 15

        [xtick, ytick] = [ canvas_width / 5 , canvas_height / 10 ]
        Ky = canvas_height/maxScore
        gridColor = 'L'
        tickBump = 3

        boxColor = 'G'
        boxPadding = 10

        img = @g.newImageWhiteWithOffset(canvas_width, canvas_height, offset_left, offset_right, offset_top, offset_bottom )
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
        imgtag =  @h.graphic(imgdata, canvas_width + offset_left + offset_right, canvas_height + offset_top + offset_bottom)

        [  ['The graph shows ' + _activity + '. What is the average of ' + names[pickedIndices[0]] + ' and ' + names[pickedIndices[1]] + '\'s ' + _scores + '?' + imgtag , answers], index]
