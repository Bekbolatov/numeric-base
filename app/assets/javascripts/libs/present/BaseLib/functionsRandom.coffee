angular.module 'BaseLib'

.factory "RandomFunctions", [ ->
    class RandomFunctions
        random: (a, b) -> a + ( (Math.random() * (b-a) ) | 0 ) # ..., a-1, [a, a+1, ..., b-1], b, b+1, ...
        randomAB: -> (@random(0,2) > 0)
        randomFromList: (list) ->
            if list == undefined || list.length < 1
                return 0
            list[@random(0, list.length)]
        randomPairFromList: (list) ->
            if list == undefined || list.length < 1
                return []
            n = list.length
            if n == 1
                return [list[0], list[0]]
            pair = undefined
            while pair == undefined
                n1 = @random(0, n)
                n2 = @random(0, n)
                if n1 != n2
                    pair = [list[n1], list[n2]]
            pair
        randomNonRepeating: (list, n) ->
            if !list || list.length < 1
                return []
            if n > list.length
                n = list.length
            else if n < 1
                n = 1
            remaining = list
            rn = list.length
            grow = []
            while n > 0
                remove = @random(0, rn)
                grow = grow.concat(remaining.splice(remove, 1))
                n = n - 1
                rn = rn - 1
            grow
        randomDigits: (n) ->
            if n > 10
                n = 10
            if n < 1
                n = 1
            @randomNonRepeating([ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9], n)
        randomVariableLetter: -> @randomFromList('abcdefghkmnpqrstuvwyzABCDEFGHKLMNPQRSTUVWYZ')
        shuffleListInPlace: (a) ->
            if a == undefined || a.length < 2
                return
            for i in [a.length-1..1]
                j = Math.floor Math.random() * (i + 1)
                [a[i], a[j]] = [a[j], a[i]]
            a

        shuffleAnswers4: (otherPossibleAnswers, correct) -> # 4 wrong and 1 right given (total of 5 answers)
            @shuffleListInPlace(otherPossibleAnswers)
            index = @random(0,5)
            tail = otherPossibleAnswers.splice(index, 10)
            answers = otherPossibleAnswers.concat([correct]).concat(tail)
            [answers, index]

        _someChars : 'z123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZAB'
        _randomSomeChar: () -> @_someChars[Math.random()*64 | 0]
        randomSomeString: (n) ->
            s = ''
            for i in [1..n]
                s = s + @_randomSomeChar()
            s


    randomFunctions = new RandomFunctions()
    document.numeric.modules.RandomFunctions = randomFunctions
    randomFunctions
]
