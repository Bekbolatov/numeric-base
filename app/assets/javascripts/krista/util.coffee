angular.module('Krista')

.factory "KristaUtil", [ 'KristaData', (KristaData) ->
    class KristaUtil
        random: (a, b) -> a + ( Math.random() * (b-a) ) | 0 # ..., a-1, [a, a+1, ..., b-1], b, b+1, ...
        randomAB: -> (@random(0,2) > 0)
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
            names = KristaData.data.name
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

        randomDigits: (n) -> @randomNonRepeating([ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9], n)

        randomVariableLetter: -> @randomFromList('abcdefghkmnpqrstuvwyzABCDEFGHKLMNPQRSTUVWYZ')
        shuffleListInPlace: (a) ->
            for i in [a.length-1..1]
                j = Math.floor Math.random() * (i + 1)
                [a[i], a[j]] = [a[j], a[i]]
            a

        # 4 wrong and 1 right given (total of 5 answers)
        shuffleAnswers4: (otherPossibleAnswers, correct) ->
            @shuffleListInPlace(otherPossibleAnswers)
            index = @random(0,5)
            tail = otherPossibleAnswers.splice(index, 10)
            answers = otherPossibleAnswers.concat([correct]).concat(tail)
            [answers, index]

        digitToWord: (d) ->
            words = [ 'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine' ]
            words[d]
        numberBelow20ToWord: (num) ->
            below20 = ['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen']
            below20[num]
        tensToWord: (c) ->
            tens = ['', 'ten', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety']
            tens[c]

        gcd: (a, b) ->
            if a < 0
                a = -a
            if b < 0
                b = -b
            if a > b
                [a, b] = [b, a]
            if a == 0
                b
            if b == 0
                a

            c = b - Math.floor(b/a) * a
            if c <= 0
                a
            else
                @gcd(c, a)

        reduce: (a, b) ->
            c = @gcd(a, b)
            [a/c, b/c]

        toCssFraction: (a, b) ->
            output = '<span class="fraction">'
            output += '<span class="fraction-top">' + a + '</span>'
            output += '<span class="fraction-bottom">' + b + '</span>'
            output += '</span>'


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
        AifBthenwhatC: (A, B, C, v) =>
            if v != undefined && v != ''
                output = A + '. ' + v + ' ' + B + ', ' + C + '?'
            else
                output = A + '. ' + B + '. ' + C + '?'
            @prettify(output)
        AandBwhatC: (A, B, C, v) =>
            output = A + ', and ' + B + '. ' + C + '?'
            @prettify(output)
        whatCifAandB: (A, B, C, v) =>
            output = C + ', if ' + A + ', and ' + B  + '?'
            @prettify(output)
        AwhatCifB: (A, B, C, v) =>
            if v == undefined || v == ''
                v = 'if'
            output = A + '. ' + C + ' ' + v + ' ' + B + '?'
            @prettify(output)
        ifBthenwhatC: (B, C, v) =>
            if v != undefined || v == ''
                output = v + ' ' + B + ', ' + C + '?'
            else
                output = B + '. ' + C + '?'
            @prettify(output)

        combine3: (A, B, C, v) =>
            #s = @randomFromList(['AifBthenwhatC', 'AandBwhatC', 'whatCifAandB', 'AwhatCifB'])
            s = @randomFromList(['AifBthenwhatC', 'AandBwhatC', 'AwhatCifB'])
            v = @randomFromList(['if', ''])
            @[s](A, B, C, v)
        combine2: (B, C, v) =>
            s = @randomFromList(['ifBthenwhatC'])
            v = @randomFromList(['if', ''])
            @[s](B, C, v)


    console.log('KristaUtil factory')
    new KristaUtil()
]
