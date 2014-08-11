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

.filter 'secondsToHuman', ->
    (allSeconds) ->
        allHours = allSeconds/3600
        hours = Math.floor(allHours)
        allSeconds = allSeconds - hours*3600

        allMinutes = allSeconds/60
        minutes = Math.floor(allMinutes)
        allSeconds = allSeconds - minutes*60

        seconds = allSeconds

        if (hours > 0)
            return "" + hours + " hours, " + minutes + " minutes, " + seconds + " seconds"
        if (minutes > 0)
            return "" + minutes + " minutes, " + seconds + " seconds"
        return "" + seconds + " seconds"

.filter 'secondsToClock', ->
    (allSeconds) ->
        if allSeconds == undefined || isNaN(allSeconds)
            return ""
        allHours = allSeconds/3600
        hours = Math.floor(allHours)
        allSeconds = allSeconds - hours*3600

        allMinutes = allSeconds/60
        minutes = Math.floor(allMinutes)
        if minutes < 10
            minutes = "0" + minutes
        allSeconds = allSeconds - minutes*60

        seconds = allSeconds
        if seconds < 10
            seconds = "0" + seconds

        if (hours > 0)
            return "" + hours + ":" + minutes + ":" + seconds + ""
        return "" + minutes + ":" + seconds + ""

.factory("NumericData", ['$timeout','$sce', ($timeout, $sce) ->
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
            @totalTime = NaN
            @startTime = new Date()

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
            @totalTime = Math.round( (new Date() - @startTime) / 1000 )
            if @question == undefined
                @scope.$broadcast('end-of-test')
                @scope.$broadcast('timer-stop')
                return
            @questionStatement_ = @question.statement
            @questionStatementAsHTML_ = $sce.trustAsHtml(@question.statement)
            if @currentTask.answerType == 'numeric'
                @questionStatement = @questionStatement_ + ' = '
            @questionStatementAsHTML = $sce.trustAsHtml(@questionStatement)
            @questionStatementChoices = @question.choices

            @scope.$broadcast('timer-start')

        _checkAnswer: (answer) =>
            @scope.$broadcast('timer-stop')
            if @currentTask.answerType == 'numeric'
                answerString = answer
            else
                answerString = @questionStatementChoices[answer]

            if @question.checkAnswer(answer)
                @_markCorrectResult()
                @answeredQuestion =
                    statement: @questionStatement_
                    statementAsHTML: @questionStatementAsHTML_
                    answer: answerString
                    result: true
                    time: Math.round(@scope.elapsedTime/1000)
            else
                @_markWrongResult()
                @answeredQuestion =
                    statement: @questionStatement_
                    statementAsHTML: @questionStatementAsHTML_
                    answer: answerString
                    result: false
                    time: Math.round(@scope.elapsedTime/1000)
            $timeout( \
                () =>
                    @result.class = 'none'
                , 500)

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
])

