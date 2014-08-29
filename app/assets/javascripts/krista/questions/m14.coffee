angular.module('Krista')

.factory "M14", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M14
        u: KristaUtil
        generate: ->
            luis = @u.random(11, 30)
            diff1 = @u.random(3, Math.floor( luis / 2 ) )
            diff2 = @u.random(3, Math.floor( luis / 2 ) )
            while diff1 == diff2
                diff2 = @u.random(2, Math.floor( luis / 2 ) )

            if @u.randomAB()
                diff1e = luis - diff1
                diff1w = 'more'
            else
                diff1e = luis + diff1
                diff1w = 'less'
            if @u.randomAB()
                diff2e = luis - diff2
                diff2w = 'less'
            else
                diff2e = luis + diff2
                diff2w = 'more'

            names = @u.randomPairNames()

            [  ['' + names[0][0] + ' has $' + diff1 + ' dollars ' + diff1w + ' than $' + diff1e + '. How much money does ' + names[1][0] + ' have if ' + names[1][1] + ' has $' + diff2 + ' ' + diff2w + ' than ' + names[0][0] ], diff2e]

    new M14()
]