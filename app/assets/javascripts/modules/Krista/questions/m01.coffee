angular.module('Krista')

.factory "M01", ['RandomFunctions', (RandomFunctions ) ->
    class M01
        r: RandomFunctions
        generate: ->
            a = @r.random(21, 50)
            b = @r.random(3, 40)

            [  ['' + a + ' + ' + b + ' = ?'], a + b]

    new M01()
]