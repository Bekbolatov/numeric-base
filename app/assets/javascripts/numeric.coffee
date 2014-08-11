angular.module('numeric', [])
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
            if @currentTask.answerType == 'multiple'
                @questionStatement = @questionStatement_
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
                , 1000)

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

