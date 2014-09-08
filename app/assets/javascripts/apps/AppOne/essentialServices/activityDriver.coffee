angular.module('AppOne')

.factory("ActivityDriver", ['$timeout','$sce', '$q', 'ActivitySummary', ($timeout, $sce, $q, ActivitySummary ) ->
    class Activity
        constructor: (@currentTask) ->
            @name = @currentTask.meta.name
            @parameters = @currentTask.parameters
        lettered: (n) -> ' ' + ("ABCDEFGH")[n] + ') '
        newQuestion: ->
            @question = @currentTask.createNextQuestion()
            if @question == undefined
                return undefined

            if @question.answerType == 'numeric'
                @inputTypeNumeric = true
                @inputTypeMultipleChoice = false
                @questionStatementChoices = undefined
                @questionStatementAsHTML_ = @question.statement
                @questionStatementAsHTML = $sce.trustAsHtml(@question.statement)
            else if @question.answerType == 'multiple'
                @inputTypeNumeric = false
                @inputTypeMultipleChoice = true
                @questionStatementChoices_ = @question.choices
                questionStatement = @question.statement + '<div class="problem-ol-mult-choice-holder"><ol type="A" class="problem-ol-mult-choice">'
                for i, choice of @question.choices
                    questionStatement += '<li>' + choice + '</li>'
                questionStatement += '</ol></div>'

                @questionStatementAsHTML_ = questionStatement
                @questionStatementAsHTML = $sce.trustAsHtml(questionStatement)
            else
                return undefined

            if @question.sizingClassCode
                if @question.sizingClassCode = 5
                    @sizingClass = 'sizeMakeSmaller'
                else
                    @sizingClass = 'sizeKeepSame'
            else
                @sizingClass = 'sizeKeepSame'

            returnQuestion =
                questionStatementAsHTML_ : @questionStatementAsHTML_
                questionStatementAsHTML : @questionStatementAsHTML
                questionStatementChoices_ : @questionStatementChoices_
            returnQuestion

        questionString: ->
            answerString = answer
            if @inputTypeMultipleChoice
                answerString = @questionStatementChoices_[answer]
            answerString
        answerString: (answer) ->
            answerString = answer
            if @inputTypeMultipleChoice
                answerString = @lettered(answerString) + @questionStatementChoices_[answerString]
            answerString

        answerStringActual: () ->
            answerString = @question.getAnswer()
            if @inputTypeMultipleChoice
                answerString = @lettered(answerString) + @questionStatementChoices_[answerString]
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
                verbal: ''
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

        tryFinishActivity: ->
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
            @questionStatementAsHTML = @question.questionStatementAsHTML

            if !keepClock
                @scope.$broadcast('timer-start')

        _checkAnswer: (answer) =>
            @scope.$broadcast('timer-stop')

            @answeredQuestion =
                statement: @question.questionStatementAsHTML_
                statementAsHTML: @question.questionStatementAsHTML
                answer: @currentActivity.answerString(answer)
                answerAsHTML: $sce.trustAsHtml('' + @currentActivity.answerString(answer))
                actualAnswer: @currentActivity.answerStringActual()
                actualAnswerAsHTML: $sce.trustAsHtml('' + @currentActivity.answerStringActual())
            if @currentActivity.checkAnswer(answer)
                @_markCorrectResult()
                @answeredQuestion.result = true
            else
                @_markWrongResult()
                @answeredQuestion.result = false

            ActivitySummary.add(@answeredQuestion)
#            $timeout( \
#                () =>
#                    @result.class = 'none'
#                , 1000)

        # User keypad entries
        pressed: (digit) ->
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
