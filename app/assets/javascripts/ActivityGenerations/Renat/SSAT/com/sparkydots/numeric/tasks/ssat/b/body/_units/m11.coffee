class M11
    u: document.numeric.modules.RandomFunctions
    generate: ->
        a = @u.random(21, 50)
        b = @u.random(11, 40)

        [  ['' + (a + b) + ' - ' + a + ' = ?'], b]
