class M27
    u: document.numeric.modules.RandomFunctions
    h: document.numeric.modules.HyperTextManager
    generate: ->

        pies = 'pies'
        friends = 'friends'
        person = 'person'

        p = @u.random(17, 50)
        f = @u.random(5, 8)

        diff = @u.random(1, 4)
        diff2 = @u.random(2, 5)
        diff3 = @u.random(3, 6)

        answers = [
            [ f - 1, p ]
            [ f + 1, p ]
            [ p - diff, f - 1 ]
            [ p - diff, f + diff3 ]
            [ p + diff2, f - 1 ]
        ]

        @u.shuffleListInPlace(answers)

        smallest = 100
        index = -1
        for i, a of answers
            offset = Math.abs( a[0] / a[1]  - p / f )
            if offset < smallest
                smallest = offset
                index = i

        answers =  ( ('' + @h.fraction(answer[0], answer[1])) for answer in answers)

        [  ['' + p + ' ' + pies + ' will be divided evenly among ' + f + ' ' + friends + '. Of the below, which expression gives the best estimate of the total number of ' + pies + ' each ' + person + ' will receive?', answers], index]

