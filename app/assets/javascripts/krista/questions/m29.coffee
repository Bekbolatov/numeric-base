angular.module('Krista')

.factory "M29", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M29
        u: KristaUtil
        generate: ->     # a/n   and b/m
            [a, b] = @u.randomPairFromList([1, 2, 3, 5])
            if a > b
                [a, b] = [b, a]
            # b is smaller than a    a,b  ~    5,3  5,1    3,1   3,2  5,2  3,1  2,1
            m = @u.random(a + 1, 3*a + 1)    # m/a could be 2 or 3
            n = @u.random(b + 1, 3*b + 1)
            while n/b == m/a || n > 9
                n = @u.random(b + 1, 3*b + 1)

            [a, m] = @u.reduce(a, m)
            [b, n] = @u.reduce(b, n)

            K = a*b
            M = m*n
            correct = @u.reduce(K, M)
            #####
            inc = []
            inc.push(@u.reduce( a + b, m * n)) #B
            inc.push(@u.reduce( a * b, m * b)) #E
            inc.push(@u.reduce( a + b , m + n))
            inc.push(@u.reduce( 1 , m + n))

            [answers, index] = @u.shuffleAnswers4(inc, correct)

            #answers = ( ( @u.reduce(answer[0], answer[1]) ) for answer in answers)
            answers =  ( ('' + @u.toCssFraction(answer[0], answer[1])) for answer in answers)

            [  ['What is ' + @u.toCssFraction( a, m) + ' x ' + @u.toCssFraction( b, n) + '?', answers], index]

    new M29()
]