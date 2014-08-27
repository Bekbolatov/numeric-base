angular.module('AppOne')

.factory "KristaQuestion", ['KristaData', 'KristaUtil', (KristaData, KristaUtil ) ->
    class KristaQuestion
        random: (a, b) -> KristaUtil.random(a, b)
        randomFromList: (list) -> KristaUtil.randomFromList(list)
        randomPairFromList: (list) -> KristaUtil.randomPairFromList(list)
        shuffleListInPlace: (list) -> KristaUtil.shuffleListInPlace(list)

        generateDataForQuestionType04: () =>
            subject = @randomFromList(['person', 'animal', 'bird', 'zoo', 'forest', 'thing', 'thing' ])
            item = @randomFromList(KristaData.data.item[subject])
            location = @randomFromList(KristaData.data.location[subject])

            r = @randomPairFromList([1,2,3,4,5,6,7])
            r1 = r[0]
            r2 = r[1]
            if ( ( r1 % 2 ) == 0) && ( ( r2 % 2 ) == 0 )
                r1 = r1 / 2
                r2 = r2 / 2
            if ( ( r1 % 3 ) == 0) && ( ( r2 % 3 ) == 0 )
                r1 = r1 / 3
                r2 = r2 / 3

            m = @random(2,6)
            dr = {
                location: location
                elements: item
                ratio : [r1, r2]
                numbers: [r1*m, r2*m]
            }
            dr

        questionType04Composer: () =>
            data = @generateDataForQuestionType04()
            c = {}
            c.ratio = -> data.ratio.join(':')
            c.ratioFor = (i) -> data.ratio[i]
            c.number = (i) -> data.numbers[i]
            c.numberTotal = () ->
                total = 0
                for n in data.numbers
                    total += n
                total
            # red bird(s)/blue bird(s)
            c.element = (i) -> data.elements[0][i][0]
            c.elements = (i) -> data.elements[0][i][1]
            # bird/birds
            c.item = -> data.elements[1][0]
            c.items = -> data.elements[1][1]
            # ... (sitting) (on the) (tall) (tree)
            c.inSet = (acting, pink) ->
                output = ''
                if acting && data.location[2]
                    output += data.location[2] + ' '
                if data.location[1]
                    output += data.location[1] + ' '
                if pink && data.location[0].length > 1
                    output += data.location[0][1] + ' '
                output + data.location[0][0]

            ## COMBO LEVEL 1
            # there are 5 boys ...
            c.forEvery = (i) ->
                if c.ratioFor(i) == 1
                    output = 'one ' + c.element(i)
                else
                    output = c.ratioFor(i) + ' ' + c.elements(i)
                output
            c.forEveryThere = (i) ->
                if c.ratioFor(i) == 1
                    output = 'there is one ' + c.element(i)
                else
                    output = 'there are ' + c.ratioFor(i) + ' ' + c.elements(i)
                output
            c.thereAre = (i) ->
                output = 'there '
                if c.number(i) == 1
                    output += 'is one ' + c.element(i)
                else
                    output += 'are ' + c.number(i) + ' ' + c.elements(i)
                output
            c.thereAreTotal = ->
                total = c.numberTotal()
                output = 'there '
                if total == 1
                    output += 'is 1 ' + c.item()
                else
                    output += 'are ' + total + ' ' + c.items()
                output
            c.ratioIsSingleVariant = (there) ->
                if there == undefined || there == ''
                    'the ratio of ' + c.elements(0) + ' to ' + c.elements(1) + ' is ' + c.ratio()
                else
                    'the ratio of ' + c.elements(0) + ' to ' + c.elements(1) + ' ' + there + ' is ' + c.ratio()
            c.ratioIs = (there) =>
                if @random(0, 2) > 0
                    if there == undefined || there == ''
                        'the ratio of ' + c.elements(0) + ' to ' + c.elements(1) + ' is ' + c.ratio()
                    else
                        'the ratio of ' + c.elements(0) + ' to ' + c.elements(1) + ' ' + there + ' is ' + c.ratio()
                else
                    if there == undefined || there == ''
                        'for every ' + c.forEvery(0) + ' ' + c.forEveryThere(1)
                    else
                        'for every ' + c.forEvery(0) + ' ' + there + ' ' + c.forEveryThere(1)
            # QUESTIONS: how many red birds are there?
            c.howMany = (i)-> 'how many ' + c.elements(i) + ' are there'
            c.howManyTotal = -> 'how many ' + c.items() + ' are there'

            ## COMBO LEVEL 2
            # STATEMENTS: there are 5 blue birds in the box
            c.ratioIsInSet = (acting, pink) -> c.ratioIs(c.inSet(acting, pink))
            c.thereAreInSet = (i, acting, pink) -> c.thereAre(i) + ' ' + c.inSet(acting, pink)
            c.thereAreTotalInSet = (acting, pink) -> c.thereAreTotal() + ' ' + c.inSet(acting, pink)

            # Questions: how many red birds are there in the box?
            c.howManyInSet = (i, acting, pink) -> c.howMany(i) + ' ' + c.inSet(acting, pink)
            c.howManyTotalInSet = (acting, pink) -> c.howManyTotal() + ' ' + c.inSet(acting, pink)

            c.generateQuestion = =>
                s = @randomFromList(['AifBthenwhatC', 'AandBwhatC', 'whatCifAandB', 'AwhatCifB'])
                v = @randomFromList(['if', ''])
                ratioSecond = @randomFromList([false, true])
                knownUnknown = @randomPairFromList([0, 1, 2])
                if knownUnknown[0] != 2
                    if ratioSecond
                        p2 = c.thereAreInSet(knownUnknown[0], true, true)
                        if @random(0, 2) > 0
                            p1 = c.ratioIs()
                        else
                            p1 = c.ratioIsInSet()
                    else
                        p1 = c.ratioIsInSet(true, true)
                        if @random(0, 2) > 0
                            p2 = c.thereAre(knownUnknown[0])
                        else
                            p2 = c.thereAreInSet(knownUnknown[0], false, false)
                else
                    if ratioSecond
                        p2 = c.thereAreTotalInSet(true, true)
                        if @random(0, 2) > 0
                            p1 = c.ratioIs()
                        else
                            p1 = c.ratioIsInSet()
                    else
                        p1 = c.ratioIsInSet(true, true)
                        if @random(0, 2) > 0
                            p2 = c.thereAreTotal()
                        else
                            p2 = c.thereAreTotalInSet(false, false)

                if knownUnknown[1] == 2
                    answer = c.numberTotal()
                    if @random(0, 2) > 0
                        p3 = c.howManyTotal()
                    else
                        p3 = c.howManyTotalInSet(false, false)
                else
                    answer = c.number(knownUnknown[1])
                    if @random(0, 2) > 0
                        p3 = c.howMany(knownUnknown[1])
                    else
                        p3 = c.howManyInSet(knownUnknown[1], false, false)

                func = KristaUtil[ s ]
                if ratioSecond
                    question = func(p2, p1, p3, v)
                else
                    question = func(p1, p2, p3, v)
                [ question  , answer]

            c.generateQuestion()




        questionType05Composer: () ->
            targetNumber = @random(1, 90)
            starter = 0
            inc = []
            for i in [1 .. 5]
                starter += @randomFromList([0.01, 0.02, 0.03, 0.04, 0.05, 0.06])
                inc.push(starter)
            possibleAnswers = ( (targetNumber + inci * @randomFromList([-1, 1])).toFixed(2) for inci in inc )

            closest = possibleAnswers.splice(0,1)
            @shuffleListInPlace(possibleAnswers)
            index = @random(0,5)
            tail = possibleAnswers.splice(index, 10)
            answers = possibleAnswers.concat(closest).concat(tail)
            ['Which of the following is closest in value to ' + targetNumber + '?', answers, index]

    console.log('KristaQuestion factory')
    k = new KristaQuestion()
    document.numeric.modules.KristaQuestion = k
]
