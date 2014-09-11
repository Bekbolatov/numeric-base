angular.module('Krista')

.factory "M07", ['RandomFunctions', (RandomFunctions ) ->
    class M07
        r: RandomFunctions
        generate: ->
            a = @r.random(2, 10)
            b = @r.random(2, 10)
            q = @r.random(2, 10)
            Q = @r.randomVariableLetter()

            [  ['If ' + q*a + ' ÷ ' + Q + ' = ' + a + ', then ' + b + ' x ' + Q + ' = ?' ], b*q]

    new M07()
]