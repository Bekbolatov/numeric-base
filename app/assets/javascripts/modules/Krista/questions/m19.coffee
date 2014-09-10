angular.module('Krista')

.factory "M19", ['RandomFunctions', (RandomFunctions ) ->
    class M19
        u: RandomFunctions
        generate: ->
            a = @u.random(3, 8)
            a = (a/2).toFixed(1)

            [  [ '' + a + ' ft. = _ inches?' ], a*12]

    new M19()
]