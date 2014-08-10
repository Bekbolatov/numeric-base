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
        clearResult: () ->
            @result =
                class: 'none'
                verbal: '&nbsp;'
        resetStats: () ->
            @statsCorrect = 0
            @statsWrong = 0

        _clearLastQuestion: () ->
            @answeredQuestion =
                statement: ''
                class: 'correct'
                time: ''


        # Problem construction and check
        setTask: (@currentTask, @scope) ->
            @clearResult()
            @resetStats()
            @newQuestion()
            @taskName = @currentTask.name
            @_clearLastQuestion()
            @startTime = new Date()

        getTaskName: ->
            @currentTask.name

        newQuestion: () ->
            @answer = undefined
            @question = @currentTask.createNextQuestion(@statsCorrect + @statsWrong)
            if @question == undefined
                @scope.$broadcast('end-of-test')
                @scope.$broadcast('timer-stop')
                @endTime = new Date()
                @totalTime = Math.round( (@endTime - @startTime) / 1000 )
                return
            @questionStatement = @question.statement
            if @currentTask.answerType == 'numeric'
                @questionStatement = @questionStatement + ' = '
            @questionStatementChoices = @question.choices

            @scope.$broadcast('timer-start')

        _checkAnswer: (answer) ->
            @scope.$broadcast('timer-stop')
            if @currentTask.answerType == 'numeric'
                answerString = answer
            else
                answerString = @questionStatementChoices[answer]

            if @question.checkAnswer(answer)
                @_markCorrectResult()
                @answeredQuestion =
                    statement: @question.statement
                    answer: answerString
                    result: true
                    time: Math.round(@scope.elapsedTime/1000)
            else
                @_markWrongResult()
                @answeredQuestion =
                    statement: @question.statement
                    answer: answerString
                    result: false
                    time: Math.round(@scope.elapsedTime/1000)

        # User keypad entries
        pressed: (digit) ->
            @clearResult()
            if (@answer == undefined)
                @answer = 0
            @answer = @answer * 10 + digit
        clear: () ->
            @answer = undefined
        enter: () ->
            if (@answer != undefined)
                @_checkAnswer(@answer)
                @newQuestion()
        # User multiple-choice entries
        pressedChoice: (choice) ->
            @_checkAnswer(choice)
            @newQuestion()



        constructor: () ->
            @clearResult()
            @resetStats()
            @_clearLastQuestion()

    new Numeric()


