angular.module('Krista')

.factory "M03", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M03
        u: KristaUtil
        generate: ->
            a = @u.random(21, 50)
            b = @u.random(3, 40)

            [  ['' + a + ' + ' + b + ' = ?'], a + b]

    new M03()
]