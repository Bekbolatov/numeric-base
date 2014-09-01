angular.module('Krista')

.factory "M18", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M18
        u: KristaUtil
        generate: ->
            a = @u.random(111, 450)
            b = @u.random(111, 450)

            [  ['What is the value of the expression ' + a + ' + ' + b + '?'], a + b]

    new M18()
]