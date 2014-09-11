class M21
    u: document.numeric.modules.RandomFunctions
    generate: ->
        k = @u.random(2, 10)

        [a, b] = @u.randomPairFromList([2,3,4,5,6,7,8,9,10,11])

        [  [ '' + a + ' is to ' + a*k + ' as ' + b + ' is to _ ?' ], b*k]
