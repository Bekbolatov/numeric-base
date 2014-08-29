angular.module('Krista')

.factory "M22", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M22
        u: KristaUtil
        generate: ->
            a = @u.random(1, 9)
            b = 0
            c = @u.random(1, 9)
            d = @u.random(1, 9)

            zeroC = @u.randomAB()
            if zeroC
                 [b, c] = [c, b]

            p = '' + a + ',' + b + c + d

            pstring = '' + @u.digitToWord(a) + ' thousand'
            if zeroC
                pstring += ' ' + @u.digitToWord(b) + ' hundred and ' + @u.digitToWord(d)
                o = [
                    '' + a + ',' + b + d + '0'
                    '' + a + ',' + b + b + d
                    '' + a + '0,0' + b + d
                    '' + a + '0,' + b + '0' + d
                ]
            else
                if c < 2
                    pstring += ' ' + @u.numberBelow20ToWord(c*10 + d)
                else
                    pstring += ' ' + @u.tensToWord(c) + ' ' + @u.digitToWord(d)

                o = [
                    '' + a + ',' + c + '0' + d
                    '' + a + ',' + c + c + d
                    '' + a + '0,0' + c + d
                    '' + a + '0,' + c + '0' + d
                ]

            [answers, index] = @u.shuffleAnswers4(o, p)

            [  ['Which is ' + pstring + '?', answers], index]

    new M22()
]