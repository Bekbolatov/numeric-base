class M18
    u: document.numeric.modules.RandomFunctions
    generate: ->
        a = @u.random(111, 450)
        b = @u.random(111, 450)

        [  ['What is the value of the expression ' + a + ' + ' + b + '?'], a + b]

