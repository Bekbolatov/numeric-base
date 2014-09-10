angular.module('Krista')

.factory "M22", ['RandomFunctions', 'TextFunctions', (RandomFunctions, TextFunctions ) ->
    class M22
        u: RandomFunctions
        t: TextFunctions
        generate: ->
            a = @u.random(1, 9)
            b = 0
            c = @u.random(1, 9)
            d = @u.random(1, 9)

            zeroC = @u.randomAB()
            if zeroC
                 [b, c] = [c, b]

            p = '' + a + ',' + b + c + d

            pstring = '' + @t.digitToWord(a) + ' thousand'
            if zeroC
                pstring += ' ' + @t.digitToWord(b) + ' hundred and ' + @t.digitToWord(d)
                o = [
                    '' + a + ',' + b + d + '0'
                    '' + a + ',' + b + b + d
                    '' + a + '0,0' + b + d
                    '' + a + '0,' + b + '0' + d
                ]
            else
                pstring += ' ' + @t.twoDigitToWords(c, d)

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