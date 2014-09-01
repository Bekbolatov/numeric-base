angular.module('Krista')

.factory "M11", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M11
        u: KristaUtil
        generate: ->
            a = @u.random(21, 50)
            b = @u.random(11, 40)

            [  ['' + (a + b) + ' - ' + a + ' = ?'], b]

    new M11()
]