angular.module('AppOne')

.factory("ActivityDriver", ['$timeout','$sce', '$q', 'ActivitySummary', ($timeout, $sce, $q, ActivitySummary ) ->
    class Activity
        constructor: (@currentTask) ->
            @name = @currentTask.meta.name
            @parameters = @currentTask.parameters

        newQuestion: ->
            @question = @currentTask.createNextQuestion()
            if @question == undefined
                return undefined

            @questionStatement_ = @question.statement
            @questionStatementAsHTML_ = $sce.trustAsHtml(@question.statement)

            if @question.answerType == 'numeric'
                @inputTypeNumeric = true
                @inputTypeMultipleChoice = false
                if @question.answerOnNextLine
                    @questionStatement = @questionStatement_
                else
                    @questionStatement = @questionStatement_ + ' = '
            if @question.answerType == 'multiple'
                @inputTypeNumeric = false
                @inputTypeMultipleChoice = true
                @questionStatement = @questionStatement_

            if @question.answerOnNextLine
                @answerOnNextLine = true
            else
                @answerOnNextLine = false

            if @question.sizingClassCode
                if @question.sizingClassCode = 5
                    @sizingClass = 'sizeMakeSmaller'
                else
                    @sizingClass = 'sizeKeepSame'
            else
                @sizingClass = 'sizeKeepSame'


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
            if @inputTypeMultipleChoice
                answerString = @questionStatementChoices[answer]
            answerString
        answerString: (answer) ->
            answerString = answer
            if @inputTypeMultipleChoice
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
        setActivity: (@currentTask, @scope) ->
            @clearResult()
            @resetStats()
            @currentActivity = new Activity(@currentTask)
            @taskName = @currentTask.meta.name
            @_clearLastQuestion()
            @newQuestion()
            @startTime = new Date()
            ActivitySummary.init(@currentTask.id, @currentTask.meta.name)
            @currentActivity

        tryFinishActivity : ->
            deferred = $q.defer()
            ActivitySummary.finish()
            .then(
                (data) -> deferred.resolve(data)
            )
            .catch(
                (status) ->
                    console.log('error finishing task:' + status)
                    deferred.reject(status)
            )
            deferred.promise

        selectParamValue: (key, value) ->
            @currentActivity.parameters[key].selectedValue = value
            @newQuestion(true) # arg true - keep clock (do not reset for this question)

        newQuestion: (keepClock) ->
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

            if !keepClock
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
            else
                @_markWrongResult()
                @answeredQuestion =
                    statement: @questionStatement_
                    statementAsHTML: @questionStatementAsHTML_
                    answer: answerString
                    result: false
            ActivitySummary.add(@answeredQuestion)
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

