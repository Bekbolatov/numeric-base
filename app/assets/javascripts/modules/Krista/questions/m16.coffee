angular.module('Krista')

.factory "M16", ['DataPack', 'DataUtilities', 'RandomFunctions', (DataPack, DataUtilities, RandomFunctions ) ->
    class M16
        r: RandomFunctions
        u: DataUtilities
        d: DataPack
        randomBuyableItem: () => @randomFromList(DataPack.data.buyable)

        generate: ->
            diffs = @r.randomNonRepeating( [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30], 5)
            correct = diffs.splice(@r.random(0,5), 1)[0]
            toTuple = (s) ->
                Q = Math.floor(s/4)
                s = s - Q * 4
                D = Math.floor(s/2)
                N = s - D * 2
                [Q, D, N]
            toNumber = (s) ->
                [Q, D, N] = toTuple(s)
                Q * 0.25 + D * 0.10 + N * 0.05
            toString = (s) ->
                [Q, D, N] = toTuple(s)
                output = []
                if Q == 1
                    output.push('1 quarter')
                else if Q > 1
                    output.push( '' + Q + ' quarters' )
                if D == 1
                    output.push('1 dime')
                else if D > 1
                    output.push( '' + D + ' dimes' )
                if N == 1
                    output.push('1 nickel')
                else if N > 1
                    output.push( '' + N + ' nickels' )
                s = ''
                if output.length == 0
                    s = ''
                else if output.length == 1
                    s = output[0]
                else if output.length == 2
                    s = output[0] + ' and ' + output[1]
                else
                    output[output.length - 1] = 'and ' + output[output.length - 1]
                    s = output.join(', ')
                s

            [answers, index] = @r.shuffleAnswers4(diffs, correct)
            answers = (toString(answer) for answer in answers)

            sasha = @u.randomName()
            binder = @r.randomFromList(@d.data.buyable)
            A = @r.random(200, 800)
            A = Math.round(A/5)*5/100
            B = A + toNumber(correct)

            A = A.toFixed(2)
            B = B.toFixed(2)

            mother = @r.randomFromList(['mother', 'father', 'friend', 'classmate'])

            [  [ '' + sasha[0] + ' wants to buy ' + binder + ' that costs $' + B + '. However, ' + sasha[1] + ' has only $' + A + '. What coins could ' + sasha[0] + '\'s ' + mother + ' give ' + sasha[2] + ' so that ' + sasha[1] + ' would have exactly $' + B + '?', answers   ], index]

    new M16()
]