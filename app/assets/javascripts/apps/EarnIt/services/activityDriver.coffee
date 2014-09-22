angular.module('EarnIt')

.factory("ActivityDriver", ['$timeout','$sce', '$q', 'ActivityLoader', 'ActivitySummary', ($timeout, $sce, $q, ActivityLoader, ActivitySummary ) ->
    class Activity
        constructor: (@currentTask) ->
            @id = @currentTask.id
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
            @

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

        trySetActivity: (activityId, version) ->
            deferred = $q.defer()
            ActivityLoader.loadActivity(activityId, version)
            .then (activity) =>
                @setActivity(activity)
                deferred.resolve(0)
            .catch (status) ->
                console.log(status)
                deferred.reject(status)
            deferred.promise

        # Problem construction and check
        setActivity: (@currentTask) ->
            @currentActivity = new Activity(@currentTask)
            @taskName = @currentTask.meta.name
            @currentActivity

        start: (@scope) ->
            @finishing = false
            @clearResult()
            @resetStats()
            @_clearLastQuestion()
            @newQuestion()
            @startTime = new Date()
            ActivitySummary.init(@currentTask.id, @currentTask.meta.name)

        tryFinishActivity: ->
            @finishing = true
            deferred = $q.defer()
            ActivitySummary.finish()
            .then (timestamp) -> deferred.resolve(timestamp)
            .catch (status) ->
                console.log('error finishing task:' + status)
                deferred.reject(status)
            deferred.promise

        selectParamValue: (key, value) ->
            @currentActivity.parameters[key].selectedValue = value
            if @currentActivity.parameters[key].jump
                true
            else
                false

        # begin: add note, toggle star
        clearNotesBuffer: () ->
            @toggledStar = false
            @addedNote = false

        toggleStar: () ->
            @toggledStar = !@toggledStar
        addNote: (note) ->
            if note == false
                return @addedNote = false
            if note == undefined || note.length < 1
                return 1
            @addedNote = note.substr(0, 300)

        toggleStarPrev: () -> ActivitySummary.togglePrevStar()
        toggledStarPrev: () -> ActivitySummary.getPrevStar()
        addedNotePrev: () -> ActivitySummary.getPrevNote()
        addNotePrev: (note) ->
            if note == false
                return ActivitySummary.setPrevNote(false)
            if note == undefined || note.length < 1
                return 1
            ActivitySummary.setPrevNote(note.substr(0, 300))
        # end: add note, toggle star

        newQuestion: (keepClock) -> # arg true - keep clock (do not reset for this question)
            @totalTime = Math.round( (new Date() - @startTime) / 1000 )
            @answer = undefined
            try
                @question = @currentActivity.newQuestion()
            catch e
                console.log(e)
                try
                    @question = @currentActivity.newQuestion()
                catch e
                    console.log(e)
                    try
                        @question = @currentActivity.newQuestion()
                    catch e
                        console.log(e)
                        alert('activity exited')
                        @question = undefined
            if @question == undefined
                @scope.$broadcast('end-of-test')
                @scope.$broadcast('timer-stop')
                return
            @questionStatementAsHTML = @question.questionStatementAsHTML
            document.getElementById('problemContainer').scrollTop = 0
            @clearNotesBuffer()
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

            @answeredQuestion.addedNote = @addedNote
            @answeredQuestion.toggledStar = @toggledStar

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

    new ActivityDriver()
])

