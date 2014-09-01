angular.module('Krista')

.factory "M19", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M19
        u: KristaUtil
        generate: ->
            a = @u.random(3, 8)
            a = (a/2).toFixed(1)

            [  [ '' + a + ' ft. = _ inches?' ], a*12]

    new M19()
]