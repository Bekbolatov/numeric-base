angular.module('Krista')

.factory "KristaUtil", [ 'KristaData', (KristaData) ->
    class KristaUtil
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

        shuffleListInPlace: (a) ->
            for i in [a.length-1..1]
                j = Math.floor Math.random() * (i + 1)
                [a[i], a[j]] = [a[j], a[i]]
            a


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
