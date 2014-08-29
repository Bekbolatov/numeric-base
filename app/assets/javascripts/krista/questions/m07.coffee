angular.module('Krista')

.factory "M07", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M07
        u: KristaUtil
        generate: ->
            a = @u.random(2, 10)
            b = @u.random(2, 10)
            q = @u.random(2, 10)
            Q = @u.randomVariableLetter()

            [  ['If ' + q*a + ' ÷ ' + Q + ' = ' + a + ', then ' + b + ' x ' + Q + ' = ?' ], b*q]

    new M07()
]