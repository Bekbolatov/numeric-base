angular.module('Krista')

.factory "M10", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M10
        u: KristaUtil
        generate: ->
            digits = @u.randomNonRepeating([1,2,3,4,5,6,7,8,9], 5)
            index = @u.random(0, 5)
            digit = digits[index]
            answers = [
                @u.toCssFraction(digit, 10)
                @u.toCssFraction(digit, 100)
                @u.toCssFraction(digit, '1,000')
                @u.toCssFraction(digit, '10,000')
                @u.toCssFraction(digit, '100,000')
            ]

            [  ['In the decimal 0.' + digits.join('') + ', the digit ' + digit + ' is equal to which of the following?', answers ], index]

    new M10()
]