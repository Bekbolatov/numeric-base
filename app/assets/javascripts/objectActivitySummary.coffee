angular.module('AppOne')

# Keep track and add elements to summary for current activity: continually check-point after each answer
# At Activity Finish, flush to disk
# Ability to load some past summary from disk, possibly one just saved, to feed ctrlSummary
.factory("ActivitySummary", ['$q', ($q) ->
    class ActivitySummary
        __baseFormat: ->
            {
                activityId: ''
                activityName: ''
                runningTotals:
                    correct: 0
                    wrong: 0
                responses: []
            }
        _key: document.numeric.key.currentActivitySummary
        _read: -> JSON.parse(window.localStorage.getItem(@_key))
        _write: (table) -> window.localStorage.setItem(@_key, JSON.stringify(table))

        # read and write is better done in bulk here
        init: (activityId, activityName)->
            buffer = @__baseFormat()
            buffer.activityId = activityId
            buffer.activityName = activityName
            buffer.startTime = new Date()
            @_write(buffer)
            @questionStartTime = new Date()

        add: (answeredQuestion) ->
            buffer = @_read()
            if answeredQuestion.result
                buffer.runningTotals.correct = buffer.runningTotals.correct + 1
            else
                buffer.runningTotals.wrong = buffer.runningTotals.wrong + 1
            buffer.responses.push([answeredQuestion.statement, answeredQuestion.answer, answeredQuestion.result, (new Date()) - @questionStartTime])
            @_write(buffer)
            @questionStartTime = new Date()
            console.log('contents of ActivitySummary:')
            console.log(@_read())

        finish: ->
            deferred = $q.defer()
            buffer = @_read()
            buffer.endTime = new Date()
            filename = document.numeric.path.result + (buffer.endTime - buffer.startTime)
            FileWrite.writeToFile(filename, buffer)
            .then(
                () ->
                    @_write({})
                    deferred.resolve('ok')
            )
            .catch(
                (status) -> deferred.reject(status)
            )
            deferred.promise

    console.log('CALL TO FACTORY: ActivitySummary')
    new ActivitySummary()
])
