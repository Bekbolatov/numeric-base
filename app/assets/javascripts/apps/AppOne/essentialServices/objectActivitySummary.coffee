angular.module('AppOne')

.factory("ActivitySummary", ['$q', 'FS', 'PersistenceManager', ($q, FS, PersistenceManager ) ->
    class ActivitySummary
        constructor: ->
            @currentActivityPersister = PersistenceManager.localStoreBlockingPersister(document.numeric.key.currentActivitySummary)
            @activitySummariesPersister = PersistenceManager.localStoreBlockingPersister(document.numeric.key.storedActivitySummaries)
            if !@activitySummariesPersister.read()
                @activitySummariesPersister.save({items: []})
            @_extra = "Just the first line of defense."
        __baseFormat: ->
            {
                activityId: ''
                activityName: ''
                runningTotals:
                    correct: 0
                    wrong: 0
                responses: []
            }
        _addToAllSummaries: (summaryInfo) ->
            table = @activitySummariesPersister.read()
            table.items.unshift(summaryInfo)
            @activitySummariesPersister.save(table)
        _removeFromAllSummaries: (timestamp) -> # not using right now
            table = @activitySummariesPersister.read()
            itemToDelete = 0
            newItems = item for item in table.items when item.timestamp != timestamp
            #also remove the file - currently not deleting
            @activitySummariesPersister.save(table)
        getAllSummaries: -> @activitySummariesPersister.read().items
        getAllSummariesPage: (start, end) -> @getAllSummaries().slice(start, end)
        getFromAllSummaries: (timestamp) ->
            items = @getAllSummaries()
            for item in items
                if parseInt(item.timestamp) == parseInt(timestamp)
                    return item
            return undefined
        getSummaryById: (timestamp) ->
            deferred = $q.defer()
            summary = @getFromAllSummaries(timestamp)

            filename = document.numeric.path.result + timestamp
            FS.readDataFromFile(filename, summary.hash)
            .then(
                (buffer) => deferred.resolve(buffer)
                (status) => deferred.reject(status))
            deferred.promise
        init: (activityId, activityName)->
            buffer = @__baseFormat()
            buffer.activityId = activityId
            buffer.activityName = activityName
            buffer.startTime = (new Date()).getTime()
            @currentActivityPersister.save(buffer)
            @lastTimePoint = (new Date()).getTime()
        add: (answeredQuestion) ->
            buffer = @currentActivityPersister.read()
            if answeredQuestion.result
                buffer.runningTotals.correct = buffer.runningTotals.correct + 1
            else
                buffer.runningTotals.wrong = buffer.runningTotals.wrong + 1

            if answeredQuestion.questionHasGraphicData
                buffer.responses.push([answeredQuestion.statement, answeredQuestion.answer, answeredQuestion.actualAnswer, answeredQuestion.result, (new Date()) - @lastTimePoint, [answeredQuestion.questionGraphicData] ])
            else
                buffer.responses.push([answeredQuestion.statement, answeredQuestion.answer, answeredQuestion.actualAnswer, answeredQuestion.result, (new Date()) - @lastTimePoint, []])
            @currentActivityPersister.save(buffer)
            @lastTimePoint = (new Date()).getTime()
        finish: =>
            deferred = $q.defer()
            buffer = @currentActivityPersister.read()
            buffer.endTime = @lastTimePoint

            filename = document.numeric.path.result + buffer.endTime
            console.log('trying to write to filename: ' + filename)
            FS.writeDataToFile(filename, buffer, true)
            .then(
                (hash) =>
                    activitySummaryInfo = {
                        activityName: buffer.activityName
                        timestamp: buffer.endTime
                        totalTime: buffer.endTime - buffer.startTime
                        numberCorrect: buffer.runningTotals.correct
                        numberWrong: buffer.runningTotals.wrong
                        hash: hash
                    }
                    @_addToAllSummaries(activitySummaryInfo)
                    @currentActivityPersister.save({})
                    @newFirst = 0
                    deferred.resolve(buffer.endTime)
            )
            .catch(
                (status) -> deferred.reject(status)
            )
            deferred.promise

        setFirstIndex: (newFirst) -> @newFirst = newFirst
        getFirstIndex: -> @newFirst

    console.log('CALL TO FACTORY: ActivitySummary')
    new ActivitySummary()
])
