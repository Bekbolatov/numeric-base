angular.module('Krista')

.factory "M08", ['RandomFunctions', 'HyperTextManager', (RandomFunctions, HyperTextManager ) ->
    class M08
        u: RandomFunctions
        h: HyperTextManager
        generate: ->
            a = @u.random(2, 9)
            b = @u.randomNonRepeating([11, 13, 17, 19, 23, 29, 31], 4)
            b.sort()

            p = b.concat()

            o = [
                [ b[3], b[2], b[1], b[0] ]
                [ b[3], b[1], b[2], b[0] ]
                [ b[0], b[2], b[1], b[3] ]
                [ b[2], b[1], b[0], b[3] ]
            ]

            [answers, index] = @u.shuffleAnswers4(o, p)

            answers = ((    (@h.fraction(a, an[0])) + ', ' + (@h.fraction(a,an[1])) + ', ' + (@h.fraction(a,an[2])) + ', ' + (@h.fraction(a,an[3]))  ) for an in answers)

            [  ['Which of the below fractions are ordered from largest to smallest?', answers], index]

    new M08()
]