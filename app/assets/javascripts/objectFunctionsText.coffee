angular.module 'AppOne'

.factory "TextFunctions", [ 'RandomFunctions', (RandomFunctions) ->
    class TextFunctions
        r: RandomFunctions
        capitalize: (a) ->
            if a == undefined
                return ''
            a[0].toUpperCase() + a.slice(1,10000)

        prettify: (text) ->
            if text == undefined
                return ''
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
            output = output.trim().replace(' .', '.').replace(' ?', '?')
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
            s = @r.randomFromList(['AifBthenwhatC', 'AandBwhatC', 'AwhatCifB'])
            v = @r.randomFromList(['if', ''])
            @[s](A, B, C, v)
        combine2: (B, C, v) =>
            s = @r.randomFromList(['ifBthenwhatC'])
            v = @r.randomFromList(['if', ''])
            @[s](B, C, v)


        digitToWord: (d) ->
            words = [ 'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine' ]
            words[d]
        numberBelow20ToWord: (num) ->
            below20 = ['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen']
            below20[num]
        tensToWord: (c) ->
            tens = ['', 'ten', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety']
            tens[c]
        twoDigitToWords: (c, d) ->
            if c < 2
                '' + @numberBelow20ToWord(c*10 + d)
            else
                '' + @tensToWord(c) + ' ' + @digitToWord(d)


    textFunctions = new TextFunctions()
    document.numeric.modules.TextFunctions = textFunctions
    textFunctions
]
