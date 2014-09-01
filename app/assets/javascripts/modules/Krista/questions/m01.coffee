angular.module('Krista')

.factory "M01", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M01
        u: KristaUtil
        generate: ->
            a = @u.random(21, 50)
            b = @u.random(3, 40)

            [  ['' + a + ' + ' + b + ' = ?'], a + b]

    new M01()
]