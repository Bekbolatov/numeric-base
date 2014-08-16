angular.module('AppOne')

.factory("ActivityDriver", ['$timeout','$sce', ($timeout, $sce) ->
    class Activity
        constructor: (@currentTask) ->
            @name = @currentTask.name
            @parameters = @currentTask.parameters
            if @currentTask.answerType == 'numeric'
                @inputTypeNumeric = true
                @inputTypeMultipleChoice = false
            else if @currentTask.answerType == 'multiple'
                @inputTypeNumeric = false
                @inputTypeMultipleChoice = true

        newQuestion: ->
            @question = @currentTask.createNextQuestion()
            if @question == undefined
                return undefined
            @questionStatement_ = @question.statement
            @questionStatementAsHTML_ = $sce.trustAsHtml(@question.statement)
            if @currentTask.answerType == 'numeric'
                @questionStatement = @questionStatement_ + ' = '
            if @currentTask.answerType == 'multiple'
                @questionStatement = @questionStatement_
            @questionStatementAsHTML = $sce.trustAsHtml(@questionStatement)
            @questionStatementChoices = @question.choices
            returnQuestion =
                questionStatement_ : @questionStatement_
                questionStatementAsHTML_ : @questionStatementAsHTML_
                questionStatement : @questionStatement
                questionStatementAsHTML : @questionStatementAsHTML
                questionStatementChoices : @questionStatementChoices
            returnQuestion

        questionString: ->
            answerString = answer
            if @currentTask.answerType == 'multiple'
                answerString = @questionStatementChoices[answer]
            answerString
        answerString: (answer) ->
            answerString = answer
            if @currentTask.answerType == 'multiple'
                answerString = @questionStatementChoices[answer]
            answerString

        checkAnswer: (answer) ->
            @question.checkAnswer(answer)



    class ActivityDriver
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
            @currentActivity = new Activity(@currentTask)
            @taskName = @currentTask.meta.name
            @_clearLastQuestion()
            @newQuestion()
            @startTime = new Date()

        newQuestion: () ->
            @totalTime = Math.round( (new Date() - @startTime) / 1000 )
            @answer = undefined
            @question = @currentActivity.newQuestion()
            if @question == undefined
                @scope.$broadcast('end-of-test')
                @scope.$broadcast('timer-stop')
                return

            @questionStatement_ = @question.questionStatement_
            @questionStatementAsHTML_ = @question.questionStatementAsHTML_
            @questionStatement = @question.questionStatement
            @questionStatementAsHTML = @question.questionStatementAsHTML
            @questionStatementChoices = @question.questionStatementChoices

            @scope.$broadcast('timer-start')

        _checkAnswer: (answer) =>
            @scope.$broadcast('timer-stop')
            answerString = @currentActivity.answerString(answer)

            if @currentActivity.checkAnswer(answer)
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

    console.log('CALL TO FACTORY: ActivityDriver')
    new ActivityDriver()
])

