angular.module('Krista')

.factory "M24", ['RandomFunctions', (RandomFunctions ) ->
    class M24
        u: RandomFunctions
        generate: ->
            a = @u.random(2, 10)
            b = @u.random(2, 10)
            q = @u.random(2, 10)
            Q = @u.randomVariableLetter()

            [  ['If ' + q*a + ' ÷ ' + Q + ' = ' + a + ', then ' + b + ' x ' + Q + ' = ?' ], b*q]

    new M24()
]