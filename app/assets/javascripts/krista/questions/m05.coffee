angular.module('Krista')

.factory "M05", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class M05
        u: KristaUtil

        generate: () ->
            targetNumber = @u.random(1, 90)
            starter = 0
            inc = []
            for i in [1 .. 5]
                starter += @u.randomFromList([0.01, 0.02, 0.03, 0.04, 0.05, 0.06])
                inc.push(starter)
            possibleAnswers = ( (targetNumber + inci * @u.randomFromList([-1, 1])).toFixed(2) for inci in inc )

            closest = possibleAnswers.splice(0,1)
            @u.shuffleListInPlace(possibleAnswers)
            index = @u.random(0,5)
            tail = possibleAnswers.splice(index, 10)
            answers = possibleAnswers.concat(closest).concat(tail)
            [ ['Which of the following is closest in value to ' + targetNumber + '?', answers], index]

    new M05()
]
