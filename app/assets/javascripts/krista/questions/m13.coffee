angular.module('Krista')

.factory "M13", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M13
        u: KristaUtil
        generate: ->
            a = @u.random(3, 8)
            a = (a/2).toFixed(1)

            [  [ '' + a + ' m = _ cm?' ], a*100]

    new M13()
]