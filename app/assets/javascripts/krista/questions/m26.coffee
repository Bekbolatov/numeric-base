angular.module('Krista')

.factory "M26", ['KristaData', 'KristaUtil', 'HyperTextManager', 'MathFunctions', (KristaData, KristaUtil, HyperTextManager, MathFunctions ) ->
    class M26
        u: KristaUtil
        h: HyperTextManager
        m: MathFunctions

        generate: ->
            n = @u.random(3, 8)
            a = @u.random(1, 6)
            b = a + @u.random(2, 5)  # 1/3 1/5   5/7 5/9

            [a, b] = @m.reduce(a, b)

            correct = [n, a, b]

            inc = []

            case1 = false

            if @u.randomAB()
                inc.push([n - @u.random(1,3), a, b * 2])
                case1 = true
            else if @u.randomAB()
                inc.push([n - @u.random(1,3), a + 1, b])
            else
                inc.push([n, a, b])

            if @u.randomAB()
                inc.push([n + @u.random(1,3), Math.max(1, a - 1), b])
            else
                inc.push([n - @u.random(1,3), Math.max(1, a - 1), b])



            if @u.randomAB()
                if a > 1
                    inc.push([n + @u.random(1,3), a + 1, b * 2])
                else
                    inc.push([n + @u.random(1,3), a, b * 2])
            else
                inc.push([n, a + @u.random(1,3), b * 2])


            if @u.randomAB() > 0 || case1
                inc.push([n, a, b * 2])
            else
                inc.push([n - @u.random(1,3), a, b * 2])


            [answers, index] = @u.shuffleAnswers4(inc, correct)

            answers = ( ( [answer[0]] ).concat( @m.reduce(answer[1], answer[2]) ) for answer in answers)
            answers =  ( ('' + answer[0] + @h.fraction(answer[1], answer[2])) for answer in answers)

            [  ['What is ' + @h.fraction(n*b+a, b) + ' expressed as a mixed number?', answers], index]

    new M26()
]