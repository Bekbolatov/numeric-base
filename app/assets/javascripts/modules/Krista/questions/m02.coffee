angular.module('Krista')

.factory "M02", ['RandomFunctions', 'HyperTextManager', (RandomFunctions, HyperTextManager ) ->
    class M02
        r: RandomFunctions
        h: HyperTextManager

        increaseRandomly: (a, b) ->
            method = @r.randomFromList([ 0, 1, 2, 3 ])
            if method == 0          # a inc, b inc
                k = @r.random(1,2)
                if a < b
                    [a + k, b + k]
                else
                    [a + k, b]
            else if method == 1     # a inc, b unch
                [a + @r.random(1,2), b]
            else if method == 2     # a unch, b dec
                if b > 2
                    [a, Math.max(2, b - @r.random(1,2))]
                else
                    [a + 1, b + 1]  # b may be small, good to increase a bit
            else                    # a dec, b dec*k
                k = Math.ceil( (b + 1) / a )
                if b >= k + 2
                    [a - 1, b - k]
                else
                    [a + 1, b + 1]  # b may be small, good to increase a bit

        generate: ->
            m = @r.random(1, 6)
            if m > 3
                n = m + @r.random(5, 9)
            else
                n = m + @r.random(1, 6)
            correct = [m, n]

            inc = []
            for i in [1 .. 4]
                [m, n] = @increaseRandomly(m, n)
                inc.push([m, n])

            [answers, index] = @r.shuffleAnswers4(inc, correct)

            answers =  (@h.fraction(answer[0], answer[1]) for answer in answers)


            [  ['What is the smallest fraction?', answers ],    index ]

    new M02()
]