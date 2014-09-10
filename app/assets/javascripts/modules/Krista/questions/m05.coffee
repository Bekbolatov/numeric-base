angular.module('Krista')

.factory "M05", ['RandomFunctions', (RandomFunctions ) ->
    class M05
        r: RandomFunctions

        generate: () ->
            targetNumber = @r.random(1, 90)
            starter = 0
            inc = []
            for i in [1 .. 5]
                starter += @r.randomFromList([0.01, 0.02, 0.03, 0.04, 0.05, 0.06])
                inc.push(starter)
            possibleAnswers = ( (targetNumber + inci * @r.randomFromList([-1, 1])).toFixed(2) for inci in inc )

            closest = possibleAnswers.splice(0,1)
            @r.shuffleListInPlace(possibleAnswers)
            index = @r.random(0,5)
            tail = possibleAnswers.splice(index, 10)
            answers = possibleAnswers.concat(closest).concat(tail)
            [ ['Which of the following is closest in value to ' + targetNumber + '?', answers], index]

    new M05()
]
