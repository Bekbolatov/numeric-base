angular.module('Krista')

.factory "M11", ['RandomFunctions', (RandomFunctions ) ->
    class M11
        u: RandomFunctions
        generate: ->
            a = @u.random(21, 50)
            b = @u.random(11, 40)

            [  ['' + (a + b) + ' - ' + a + ' = ?'], b]

    new M11()
]