class M14
    u: document.numeric.modules.DataUtilities
    r: document.numeric.modules.RandomFunctions
    generate: ->
        luis = @r.random(11, 30)
        diff1 = @r.random(3, Math.floor( luis / 2 ) )
        diff2 = @r.random(3, Math.floor( luis / 2 ) )
        while diff1 == diff2
            diff2 = @r.random(2, Math.floor( luis / 2 ) )

        if @r.randomAB()
            diff1e = luis - diff1
            diff1w = 'more'
        else
            diff1e = luis + diff1
            diff1w = 'less'
        if @r.randomAB()
            diff2e = luis - diff2
            diff2w = 'less'
        else
            diff2e = luis + diff2
            diff2w = 'more'

        names = @u.randomNames(2)

        [  ['' + names[0][0] + ' has $' + diff1 + ' dollars ' + diff1w + ' than $' + diff1e + '. How much money does ' + names[1][0] + ' have if ' + names[1][1] + ' has $' + diff2 + ' ' + diff2w + ' than ' + names[0][0] ], diff2e]
