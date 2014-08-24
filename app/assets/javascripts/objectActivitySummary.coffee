angular.module('AppOne')

# Keep track and add elements to summary for current activity: continually check-point after each answer
# At Activity Finish, flush to disk
# Ability to load some past summary from disk, possibly one just saved, to feed ctrlSummary
.factory("ActivitySummary", ['$q', 'FS', ($q, FS) ->
    class ActivitySummary
        constructor: ->
            if !@_readAllSummaries()
                @_writeAllSummaries({items: []})

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
            table.items.unshift(summaryInfo)
            @_writeAllSummaries(table)
        _removeFromAllSummaries: (timestamp) -> # not using right now
            console.log('removing record to allActivitySummaries')
            table = @_readAllSummaries()
            itemToDelete = 0
            newItems = item for item in table.items when item.timestamp != timestamp
            #also remove the file
            @_writeAllSummaries(newItems)

        getAllSummaries: -> @_readAllSummaries().items
        getSummaryById: (timestamp) ->
            deferred = $q.defer()
            filename = document.numeric.path.result + timestamp
            console.log('will try to read summary from file: ' + filename)
            FS.readDataFromFile(filename)
            .then(
                (buffer) => deferred.resolve(buffer)
                (status) => deferred.reject(status))
            deferred.promise

        # read and write is better done in bulk here
        init: (activityId, activityName)->
            buffer = @__baseFormat()
            buffer.activityId = activityId
            buffer.activityName = activityName
            buffer.startTime = (new Date()).getTime()
            @_write(buffer)
            @lastTimePoint = (new Date()).getTime()

        add: (answeredQuestion) ->
            buffer = @_read()
            if answeredQuestion.result
                buffer.runningTotals.correct = buffer.runningTotals.correct + 1
            else
                buffer.runningTotals.wrong = buffer.runningTotals.wrong + 1
            buffer.responses.push([answeredQuestion.statement, answeredQuestion.answer, answeredQuestion.result, (new Date()) - @lastTimePoint])
            @_write(buffer)
            @lastTimePoint = (new Date()).getTime()
            console.log('contents of ActivitySummary:')
            console.log(@_read())

        finish: =>
            deferred = $q.defer()
            buffer = @_read()
            buffer.endTime = @lastTimePoint
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
