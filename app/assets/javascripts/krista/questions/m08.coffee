angular.module('Krista')

.factory "M08", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M08
        u: KristaUtil
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

            answers = ((    (@u.toCssFraction(a, an[0])) + ', ' + (@u.toCssFraction(a,an[1])) + ', ' + (@u.toCssFraction(a,an[2])) + ', ' + (@u.toCssFraction(a,an[3]))                     ) for an in answers)

            [  ['Which of the below fractions are ordered from largest to smallest?', answers], index]

    new M08()
]