angular.module('Krista')

.factory "M10", ['RandomFunctions', 'HyperTextManager', (RandomFunctions, HyperTextManager ) ->
    class M10
        u: RandomFunctions
        h: HyperTextManager
        generate: ->
            digits = @u.randomNonRepeating([1,2,3,4,5,6,7,8,9], 5)
            index = @u.random(0, 5)
            digit = digits[index]
            answers = [
                @h.fraction(digit, 10)
                @h.fraction(digit, 100)
                @h.fraction(digit, '1,000')
                @h.fraction(digit, '10,000')
                @h.fraction(digit, '100,000')
            ]

            [  ['In the decimal 0.' + digits.join('') + ', the digit ' + digit + ' is equal to which of the following?', answers ], index]

    new M10()
]