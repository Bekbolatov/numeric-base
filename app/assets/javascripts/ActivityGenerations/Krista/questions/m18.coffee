angular.module('Krista')

.factory "M18", ['RandomFunctions', (RandomFunctions ) ->
    class M18
        u: RandomFunctions
        generate: ->
            a = @u.random(111, 450)
            b = @u.random(111, 450)

            [  ['What is the value of the expression ' + a + ' + ' + b + '?'], a + b]

    new M18()
]