angular.module('Krista')

.factory "M30", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M30
        u: KristaUtil
        generate: ->
            d = @u.randomFromList([-3, -2, -1, 1, 2, 3])
            f = (n) -> Math.round(Math.pow(2, n + 1) + d)
            els = [ f(1), f(2), f(3), f(4), f(5) ]

            init = els.slice(0,4)
            last = els[4]

            inc = [
                last - 2
                init.reduce (x, y) ->
                    x + y
                last + @u.randomFromList([ -4, 4])
                last + @u.randomFromList([ -6, 6])
            ]

            [answers, index] = @u.shuffleAnswers4(inc, last)

            [  ['What is the next number in the pattern  ' + init.join(', ') + ', ...?', answers ], index]

    new M30()
]