class M13
    u: document.numeric.modules.RandomFunctions
    generate: ->
        a = @u.random(3, 8)
        a = (a/2).toFixed(1)

        [  [ '' + a + ' m = _ cm?' ], a*100]
