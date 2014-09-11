class M23
    u: document.numeric.modules.RandomFunctions
    h: document.numeric.modules.HyperTextManager
    m: document.numeric.modules.MathFunctions

    generate: ->     # a/n   and b/m
        [a, b] = @u.randomPairFromList([1, 2, 3, 5])
        if a > b
            [a, b] = [b, a]
        # b is smaller than a    a,b  ~    5,3  5,1    3,1   3,2  5,2  3,1  2,1
        m = @u.random(a + 1, 3*a + 1)    # m/a could be 2 or 3
        n = @u.random(b + 1, 3*b + 1)
        while n/b == m/a || n > 9
            n = @u.random(b + 1, 3*b + 1)

        [a, m] = @m.reduce(a, m)
        [b, n] = @m.reduce(b, n)

        K = a*n + b*m
        M = m*n

        correct = @m.reduce(K, M)

        inc = []
        inc.push(@m.reduce( a + b, m + n))
        inc.push(@m.reduce( a + b, m * n))
        inc.push(@m.reduce( a + n , m * n))
        inc.push(@m.reduce( a*n + b*m, m + n))

        [answers, index] = @u.shuffleAnswers4(inc, correct)

        #answers = ( ( @m.reduce(answer[0], answer[1]) ) for answer in answers)
        answers =  ( ('' + @h.fraction(answer[0], answer[1])) for answer in answers)

        [  ['What is ' + @h.fraction( a, m) + ' + ' + @h.fraction( b, n) + '?', answers], index]

