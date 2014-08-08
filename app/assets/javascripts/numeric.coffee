angular.module('numeric', [])

angular.module('numeric')

.filter 'questionMark', ->
    (input) ->
        if input == undefined
            '?'
        else
            input

.filter 'firstCapital', ->
    (input) ->
        if input == undefined
            ''
        else
            input.substring(0,1).toUpperCase()+input.substring(1)

.filter 'orderObjectBy', ->
    (items, field, reverse) ->
        filtered = []
        angular.forEach(items, (item) ->filtered.push(item))
        filtered.sort( (a, b) -> if a[field] > b[field] then 1 else -1)
        if reverse
            filtered.reverse()
        filtered

.factory "NumericData", () ->
    class Numeric
        # Stats and Result communication
        _markCorrectResult: () ->
            @statsCorrect = @statsCorrect + 1
            @result =
                class: 'correct'
                verbal: 'Excellent!'
        _markWrongResult: () ->
            @statsWrong = @statsWrong + 1
            @result =
                class: 'incorrect'
                verbal: 'Wrong...'
        _clearResult: () ->
            @result =
                class: 'none'
                verbal: '&nbsp;'
        resetStats: () ->
            @statsCorrect = 0
            @statsWrong = 0


        # Problem construction and check
        setTaskEngine: (@newTaskEngine) ->
            @_clearResult()
            @resetStats()
            @_newQuestion()

        _newQuestion: () ->
            @answer = undefined
            @question = @newTaskEngine.createNextQuestion()

        _checkAnswer: () ->
            if (@question.checkAnswer(@answer))
                @_markCorrectResult()
            else
                @_markWrongResult()


        # User keypad entries
        pressed: (digit) ->
            @_clearResult()
            if (@answer == undefined)
                @answer = 0
            @answer = @answer * 10 + digit
        clear: () ->
            @answer = undefined
        enter: () ->
            if (@answer != undefined)
                @_checkAnswer()
                @_newQuestion()



        constructor: () ->
            @_clearResult()
            @resetStats()

    new Numeric()


