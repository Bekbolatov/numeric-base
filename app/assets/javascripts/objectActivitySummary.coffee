angular.module('AppOne')

# Keep track and add elements to summary for current activity: continually check-point after each answer
# At Activity Finish, flush to disk
# Ability to load some past summary from disk, possibly one just saved, to feed ctrlSummary
.factory("ActivitySummary", ['$q', 'FS', ($q, FS) ->
    class ActivitySummary
        constructor: ->
            if !@_readAllSummaries()
                @_writeAllSummaries({items: []})
                FS.getDirEntry(document.numeric.path.result, {create:true})
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

        _keyAllSummaries: document.numeric.key.storedActivitySummaries
        _readAllSummaries: -> JSON.parse(window.localStorage.getItem(@_keyAllSummaries))
        _writeAllSummaries: (table) -> window.localStorage.setItem(@_keyAllSummaries, JSON.stringify(table))
        _addToAllSummaries: (summaryInfo) ->
            console.log('adding record to allActivitySummaries')
            table = @_readAllSummaries()
            table.items.push(summaryInfo)
            @_writeAllSummaries(table)
        # read and write is better done in bulk here
        init: (activityId, activityName)->
            buffer = @__baseFormat()
            buffer.activityId = activityId
            buffer.activityName = activityName
            buffer.startTime = (new Date()).getTime()
            @_write(buffer)
            @questionStartTime = (new Date()).getTime()

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

        finish: =>
            deferred = $q.defer()
            buffer = @_read()
            buffer.endTime = (new Date()).getTime()
            filename = document.numeric.path.result + buffer.endTime
            console.log('trying to write to filename: ' + filename)
            FS.writeDataToFile(filename, buffer)
            .then(
                () =>
                    activitySummaryInfo = {
                        activityName: buffer.activityName
                        timestamp: buffer.endTime
                        totalTime: buffer.endTime - buffer.startTime
                        numberCorrect: buffer.runningTotals.correct
                        numberWrong: buffer.runningTotals.wrong
                    }
                    @_addToAllSummaries(activitySummaryInfo)
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
