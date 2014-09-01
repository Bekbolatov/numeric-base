angular.module('Krista')

.factory "KristaUtil", [ 'KristaData', 'RandomFunctions', 'MathFunctions' ,'TextFunctions', (KristaData, RandomFunctions, MathFunctions, TextFunctions ) ->
    class KristaUtil
        r: RandomFunctions
        m: MathFunctions
        t: TextFunctions

        random: (a, b) -> @r.random(a, b)
        randomAB: -> @r.randomAB()
        randomFromList: (list) -> @r.randomFromList(list)
        randomPairFromList: (list) -> @r.randomPairFromList(list)
        randomNonRepeating: (list, n) -> @r.randomNonRepeating(list, n)
        randomDigits: (n) -> @r.randomDigits(n)
        randomVariableLetter: -> @r.randomVariableLetter()
        shuffleListInPlace: (list) -> @r.shuffleListInPlace(list)

        shuffleAnswers4: (otherPossibleAnswers, correct) -> # 4 wrong and 1 right given (total of 5 answers)
            @shuffleListInPlace(otherPossibleAnswers)
            index = @random(0,5)
            tail = otherPossibleAnswers.splice(index, 10)
            answers = otherPossibleAnswers.concat([correct]).concat(tail)
            [answers, index]

        randomBuyableItem: () => @randomFromList(KristaData.data.buyable)
        randomName: () =>
            names = KristaData.data.name
            l1 = names.male.length
            l2 = names.female.length
            n1 = @random(0, l1 + l2)
            if n1 >= l1
                name = [names.female[n1-l1], 'she', 'her', 'her']
            else
                name = [names.male[n1], 'he', 'him', 'his']
            name
        randomNames: (n) ->
            o = []
            names = []
            for i in [ 1 .. n ]
                name = @randomName()
                while o.indexOf(name[0]) > -1
                    name = @randomName()
                o.push(name[0])
                names.push(name)
            names

    console.log('KristaUtil factory')
    new KristaUtil()
]
