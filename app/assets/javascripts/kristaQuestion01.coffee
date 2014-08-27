angular.module('AppOne')

.factory "KristaQuestion", ['$q', 'md5', ($q, md5) ->
    class KristaQuestion
        data: {
            name: {
                male: [ 'Jackson', 'Aiden', 'Liam', 'Lucas', 'Noah', 'Jayden', 'Ethan', 'Jacob', 'Jack', 'Logan', 'Benjamin', 'Michael', 'Ryan', 'Alexander', 'Elijah',
                    'James', 'William', 'Oliver', 'Connor', 'Matthew', 'Daniel', 'Luke', 'Henry', 'Gabriel', 'Joshua', 'Nicholas', 'Isaac', 'Nathan', 'Andrew', 'Samuel',
                    'Christian', 'Evan', 'Charlie', 'David', 'Sebastian', 'Joseph', 'Anthony', 'John', 'Tyler', 'Zachary', 'Thomas', 'Julian', 'Adam', 'Isaiah', 'Alex', 'Aaron',
                    'Parker', 'Cooper', 'Miles', 'Chase', 'Christopher', 'Blake', 'Austin', 'Jordan', 'Leo', 'Jonathan', 'Adrian', 'Colin', 'Hudson', 'Ian', 'Xavier', 'Tristan',
                    'Jason', 'Brody', 'Nathaniel', 'Jake', 'Jeremiah', 'Elliot']
                female: [ 'Sally', 'Lynn', 'Sophia', 'Emma', 'Olivia', 'Isabella', 'Mia', 'Ava', 'Lily', 'Zoe', 'Emily', 'Chloe', 'Layla', 'Madison', 'Madelyn', 'Abigail', 'Aubrey', 'Charlotte', 'Amelia',
                    'Ella', 'Kaylee', 'Avery', 'Aaliyah', 'Hailey', 'Hannah', 'Aria', 'Arianna', 'Lila', 'Evelyn', 'Grace', 'Ellie', 'Anna', 'Kaitlyn', 'Isabelle', 'Sophie', 'Scarlett',
                    'Natalie', 'Leah', 'Sarah', 'Nora', 'Mila', 'Elizabeth', 'Lillian', 'Kylie', 'Audrey', 'Lucy', 'Maya', 'Annabelle', 'Gabriella', 'Elena', 'Victoria', 'Claire', 'Savannah',
                    'Maria', 'Stella', 'Liliana', 'Allison', 'Samantha', 'Alyssa', 'Molly', 'Violet', 'Julia', 'Eva', 'Alice', 'Alexis', 'Kayla', 'Katherine', 'Lauren', 'Jasmine', 'Caroline', 'Vivian', 'Juliana']
            }
            item: {
                person: [
                    [ [ ['boy', 'boys'], [ 'girl', 'girls'] ], ['kid', 'children'] ]
                    [ [ ['boy', 'boys'], [ 'girl', 'girls'] ], ['kid', 'children'] ]
                    [ [ ['adult', 'adults'], [ 'kid', 'kids'] ], ['person', 'people'] ]
                    [ [ ['man', 'men'], [ 'woman', 'women'] ], ['person', 'people'] ]
                    [ [ ['firefighter', 'firefighters'], [ 'police man', 'police men'] ], ['firefighter or police man', 'firefighters and police men together'] ]
                ]
                bird: [
                    [ [ ['red bird', 'red birds'], [ 'blue bird', 'blue birds'] ], ['bird', 'birds'] ]
                    [ [ ['robin', 'robins'], [ 'sparrow', 'sparrows'] ], ['robin or sparrow', 'robins and sparrows together'] ]
                ]
                zoo: [
                    [ [ ['penguin', 'penguins'], [ 'meerkat', 'meerkats'] ], ['penguin or meerkat', 'penguins and meerkats together'] ]
                    [ [ ['zebra', 'zebras'], [ 'deer', 'deers'] ], ['zebra or deer', 'zebras and deers together'] ]
                ]
                forest: [
                    [ [ ['wolf', 'wolves'], [ 'rabbit', 'rabbits'] ], ['wolf or rabbit',  'wolves and rabbits together'] ]
                    [ [ ['pine tree', 'pine trees'], [ 'cedar tree', 'cedar trees'] ], ['cedar or pine tree',  'cedar and pine trees'] ]
                    [ [ ['bear', 'bears'], [ 'squirrel', 'squirrels'] ], ['bear or squirrel',  'bears and squirrels together'] ]
                ]
                animal: [
                    [ [ ['red bird', 'red birds'], [ 'blue bird', 'blue birds'] ], ['bird', 'birds'] ]
                    [ [ ['dog', 'dogs'], [ 'cat', 'cats'] ], ['animal', 'animals'] ]
                    [ [ ['mouse', 'mice'], [ 'cat', 'cats'] ], ['mouse or cat', 'mice and cats together'] ]
                    [ [ ['horse', 'horses'], [ 'cow', 'cows'] ], ['horse or cow', 'horses and cows together'] ]
                ]
                thing: [
                    [ [ ['orange candy', 'orange candies'], [ 'green candy', 'green candies'] ], ['candy', 'candies'] ]
                    [ [ ['red ball', 'red balls'], [ 'green ball', 'green balls'] ], ['ball', 'balls'] ]
                    [ [ ['red marble', 'red marbles'], [ 'blue marble', 'blue marbles'] ], ['marble', 'marbles'] ]
                    [ [ ['pencil', 'pencils'], [ 'pen', 'pens'] ], ['pen or pencil', 'pens and pencils together'] ]
                    [ [ ['black pencil', 'black pencils'], [ 'red pencil', 'red pencils'] ], ['pencil', 'pencils'] ]
                    [ [ ['apple', 'apples'], [ 'banana', 'bananas'] ], ['apple or banana', 'apples and bananas together'] ]
                    [ [ ['fruit', 'fruits'], [ 'vegetable', 'vegetables'] ], ['fruit or vegetable', 'fruits and vegetables together'] ]
                    [ [ ['book about computers', 'books about computers'], [ 'book about food', 'books about food'] ], ['book', 'books'] ]
                    [ [ ['pea', 'peas'], [ 'carrot', 'carrots'] ], ['pea or carrot', 'peas and carrots together'] ]
                ]
            }
            location : {
                person: [
                    [ [''], '' ]
                    [ ['picture'], 'on the' ]
                    [ ['room'], 'in the' ]
                    [ ['class', 'ballet class'], 'in the' ]
                    [ ['class'], 'in the' ]
                    [ ['building'], 'in the' ]
                    [ ['lobby'], 'in the' ]
                    [ ['hotel'], 'in the' ]
                    [ ['park'], 'in the' ]
                    [ ['museum'], 'in the' ]
                    [ ['bank'], 'in the' ]
                    [ ['train station'], 'at the' ]
                    [ ['playground'], 'on the' ]
                    [ ['school'], 'in the' ]
                ]
                bird: [
                    [ [''], '' ]
                    [ ['picture'], 'on the' ]
                    [ ['tree', 'tall'], 'on the', 'sitting' ]
                    [ ['park'], 'in the' ]
                    [ ['forest'], 'in the' ]
                    [ ['lake'], 'by the', 'sitting' ]
                ]
                zoo: [
                    [ [''], '' ]
                    [ ['picture'], 'on the' ]
                    [ ['zoo', 'local'], 'at the' ]
                ]
                forest: [
                    [ [''], '' ]
                    [ ['picture'], 'on the' ]
                    [ ['forest'], 'in the' ]
                ]
                animal: [
                    [ [''], '' ]
                    [ ['picture'], 'on the' ]
                    [ ['city'], 'in the' ]
                ]
                thing: [
                    [ [''], '' ]
                    [ ['picture'], 'on the' ]
                    [ ['city'], 'in the' ]
                    [ ['room'], 'in the' ]
                    [ ['box'], 'in the' ]
                    [ ['table'], 'on the' ]
                    [ ['room'], 'in the' ]
                ]
            }
        }
        random: (a, b) -> a + ( Math.random() * (b-a) ) | 0 # ..., a-1, [a, a+1, ..., b-1], b, b+1, ...
        randomFromList: (list) -> list[@random(0, list.length)]
        randomPairFromList: (list) ->
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
        randomPairNames: () =>
            names = @data.name
            l1 = names.male.length
            l2 = names.female.length
            pair = undefined
            while pair == undefined
                n1 = @random(0, l1 + l2)
                n2 = @random(0, l1 + l2)
                if n1 != n2
                    pair = []
                    if n1 >= l1
                        pair.push([names.female[n1-l1], 'she', 'her', 'her'])
                    else
                        pair.push([names.male[n1], 'he', 'him', 'his'])
                    if n2 >= l1
                        pair.push([names.female[n2-l1], 'she', 'her', 'her'])
                    else
                        pair.push([names.male[n2], 'he', 'him', 'his'])
            pair
        randomForQuestionType04: () =>
            subject = @randomFromList(['person', 'animal', 'bird', 'zoo', 'forest', 'thing', 'thing' ])
            console.log('subj: ' + subject)
            items = @data.item[subject]
            locations = @data.location[subject]
            console.log('items: ' + items)

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
                location: @randomFromList(locations)
                elements: @randomFromList(items)
                ratio : [r1, r2]
                numbers: [r1*m, r2*m]
            }
            console.log('->' + dr.location)
            console.log(dr)
            dr

        prettify: (text) ->
            afterSpaced = '.,;-!?'
            sentenceStop = '.!?'
            az = 'abcdefghijklmnopqrstuvwxyz'
            output = ''
            previousLetter = undefined
            upperCaseNext = true
            skipBlack = true
            for letter in text
                append = letter.toLowerCase()
                if az.indexOf(append) > -1 && upperCaseNext
                    append = letter.toUpperCase()
                    upperCaseNext = false
                if sentenceStop.indexOf(letter) > -1
                    upperCaseNext = true
                if afterSpaced.indexOf(letter) > -1
                    output += letter + ' '
                    append = ''
                if letter == ' '
                    if skipBlank
                        append = ''
                    skipBlank = true
                else
                    skipBlank = false
                output += append
            output = output.trim().replace(' .', '.')
            output
        AifBthenwhatC: (A, B, C, v) ->
            if v != undefined && v != ''
                output = A + '. ' + v + ' ' + B + ', ' + C + '?'
            else
                output = A + '. ' + B + '. ' + C + '?'
            @prettify(output)
        AandBwhatC: (A, B, C, v) ->
            output = A + ', and ' + B + '. ' + C + '?'
            @prettify(output)
        whatCifAandB: (A, B, C, v) ->
            output = C + ', if ' + A + ', and ' + B  + '?'
            @prettify(output)
        AwhatCifB: (A, B, C, v) ->
            if v == undefined || v == ''
                v = 'if'
            output = A + '. ' + C + ' ' + v + ' ' + B + '?'
            @prettify(output)
        ifBthenwhatC: (B, C, v) ->
            if v != undefined || v == ''
                output = v + ' ' + B + ', ' + C + '?'
            else
                output = B + '. ' + C + '?'
            @prettify(output)

        questionType04Composer: () =>
            data = @randomForQuestionType04()
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

            c.generate = =>
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

                if ratioSecond
                    [@[s]( p2,  p1, p3, v), answer]
                else
                    [@[s]( p1, p2, p3, v), answer]

            c.generate()



    console.log('KristaQuestion factory')
    k = new KristaQuestion()
    document.numeric.modules.KristaQuestion = k
]
