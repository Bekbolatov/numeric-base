angular.module('Krista')

.factory "M17", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M17
        u: KristaUtil
        generate: ->
            p = @u.randomFromList([2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31])
            o = @u.randomNonRepeating([4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 22, 24, 25, 26, 27, 28, 30, 32, 33, 34, 35, 36, 38, 39, 40, 42, 44, 45, 46, 48, 49, 50, 51, 52, 54, 55, 56, 57, 58, 60, 62, 63, 64, 65, 66, 68, 69, 70, 72, 74, 75, 76, 77, 78, 80, 81, 82, 84, 85, 86, 87, 88, 90, 91, 92, 93, 94, 95, 96, 98, 99, 100], 4)

            [answers, index] = @u.shuffleAnswers4(o, p)
            answers = ( ('' + answer) for answer in answers)

            [  ['Which of the numbers below is a prime number?', answers], index]

    new M17()
]