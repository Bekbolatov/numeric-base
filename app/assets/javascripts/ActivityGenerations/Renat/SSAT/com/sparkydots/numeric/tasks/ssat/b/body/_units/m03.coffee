class M03
    r: document.numeric.modules.RandomFunctions
    generate: ->
        a = @r.random(21, 50)
        b = @r.random(3, 40)

        [  ['' + a + ' + ' + b + ' = ?'], a + b]
