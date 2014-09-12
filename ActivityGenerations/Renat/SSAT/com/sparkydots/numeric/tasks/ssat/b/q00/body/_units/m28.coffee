class M28
    u: document.numeric.modules.RandomFunctions
    h: document.numeric.modules.HyperTextManager
    g: document.numeric.modules.GraphicsManager

    generate: ->
        d = @u.random(3, 6)
        dh = d / 2

        A = @u.random(-7, -1)

        d1 = @u.random(2, 3) * 2
        D1 = d1 * dh

        d2 = @u.random(2, 4) * 2
        D2 = d2 * dh

        B = A + D1
        C = B + D2

        h = 60
        w = 250
        tick = w / (d1 + d2 + 2)
        img = @g.newImageWhiteWithOffset(w, h, 20 )
        dark = 'D'

        H = 2 * h / 3
        L = h / 3

        img.drawLine(0, H, w, H, dark)
        img.drawLine(0, H, 5, H - 3, dark)
        img.drawLine(0, H, 5, H + 3, dark)
        img.drawLine(w, H, w - 5, H - 3, dark)
        img.drawLine(w, H, w - 5, H + 3, dark)

        for t in [ 0 .. (d1 + d2) ]
            x = (t + 1) * tick
            img.drawLine(x, H - 5, x, H + 5, dark)

        img.drawLine(tick, L, tick, H - 8)
        img.drawLine(tick, H - 8, tick - 2, H - 8 - 4)
        img.drawLine(tick, H - 8, tick + 2, H - 8 - 4)
        img.placeCharSequence(tick - 8, L - 12, '' + A, dark)

        x = tick * (d1 + 1)
        img.drawLine(x , L, x, H - 8)
        img.drawLine(x, H - 8, x - 2, H - 8 - 4)
        img.drawLine(x, H - 8, x + 2, H - 8 - 4)
        img.placeCharSequence(x - 2, L - 12, '?', dark)

        x = tick * ( d1 + d2 + 1)
        img.drawLine(x, L, x, H - 8)
        img.drawLine(x, H - 8, x - 2, H - 8 - 4)
        img.drawLine(x, H - 8, x + 2, H - 8 - 4)
        img.placeCharSequence(x - 2, L - 12, '' + C, dark)

        imgdata = img.getBase64()

        correct = B
        o = @u.random(-4, 1)
        inc = []
        for i in [ 0 .. 4 ]
            if o + i != 0
                inc.push(B + o + i)

        [answers, index] = @u.shuffleAnswers4(inc, correct)

        [  ['Use the number line below to answer the question. The hash marks are evenly spaced. What number is the vertical arrow with question mark pointing to on the number line?' + @h.graphic(imgdata), answers], index]

