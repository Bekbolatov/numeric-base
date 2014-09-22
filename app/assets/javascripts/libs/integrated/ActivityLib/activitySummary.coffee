angular.module('ActivityLib')

.factory("ActivitySummary", ['$q', 'FS', 'PersistenceManager', ($q, FS, PersistenceManager ) ->
    class ActivitySummary
        current: {}
        newFirst: 0
        constructor: ->
            @currentActivityPersister = PersistenceManager.localStoreBlockingPersister(document.numeric.key.currentActivitySummary)
            @activitySummariesPersister = PersistenceManager.localStoreBlockingPersister(document.numeric.key.storedActivitySummaries)
            if !@activitySummariesPersister.read()
                @activitySummariesPersister.save({items: []})
            @_extra = "Just the first line of defense."

        setCurrentItem: (id, back) ->
             @current.id = id
             @current.back = back

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
        _removeFromAllSummaries: (timestamp) -> #localstorage persister only
            table = @activitySummariesPersister.read()
            itemToDelete = undefined
            for key, val of table.items
                if Number(val.timestamp) == Number(timestamp)
                    itemToDelete = key
            if itemToDelete != undefined
                table.items.splice(itemToDelete, 1)
            @activitySummariesPersister.save(table)

        hasHistory: -> @getAllSummaries().length > 0
        getAllSummaries: -> @activitySummariesPersister.read().items
        getAllSummariesPage: (start, end) -> @getAllSummaries().slice(start, end)
        getFromAllSummaries: (timestamp) ->
            items = @getAllSummaries()
            for item in items
                if parseInt(item.timestamp) == parseInt(timestamp)
                    return item
            return undefined

        removeSummaryById: (timestamp) =>
            deferred = $q.defer()
            filename = document.numeric.path.result + timestamp
            FS.tryDeleteFile(filename)
            .then (data) =>
                @_removeFromAllSummaries()
                @deferred.resolve(data)
            .catch (status) =>
                deferred.reject(status)
            deferred.promise

        getSummaryById: (timestamp) ->
            deferred = $q.defer()
            summary = @getFromAllSummaries(timestamp)

            filename = document.numeric.path.result + timestamp
            FS.readDataFromFile(filename, summary.hash)
            .then (buffer) =>
                if buffer == 'mismatch'
                    @_removeFromAllSummaries(timestamp)
                deferred.resolve(buffer)
            .catch (status) =>
                @_removeFromAllSummaries(timestamp)
                deferred.reject(status)
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

            buffer.responses.push([answeredQuestion.statement, answeredQuestion.answer, answeredQuestion.actualAnswer, answeredQuestion.result, (new Date()) - @lastTimePoint, [answeredQuestion.toggledStar, answeredQuestion.addedNote] ])

            @currentActivityPersister.save(buffer)
            @lastTimePoint = (new Date()).getTime()
        finish: =>
            deferred = $q.defer()
            buffer = @currentActivityPersister.read()
            buffer.endTime = @lastTimePoint

            filename = document.numeric.path.result + buffer.endTime
            console.log('trying to write to filename: ' + filename)
            FS.writeDataToFile(filename, buffer, true)
            .then (hash) =>
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
            .catch (status) -> deferred.reject(status)
            deferred.promise

        getPrevStar : () ->
            buffer  = @currentActivityPersister.read().responses.slice(-1)[0][5][0]
        togglePrevStar : () ->
            buffer = @currentActivityPersister.read()
            last = buffer.responses.pop()
            last[5][0] = !last[5][0]
            buffer.responses.push(last)
            @currentActivityPersister.save(buffer)
        getPrevNote : () -> @currentActivityPersister.read().responses.slice(-1)[0][5][1]
        setPrevNote : (note) ->
            buffer = @currentActivityPersister.read()
            last = buffer.responses.pop()
            last[5][1] = note
            buffer.responses.push(last)
            @currentActivityPersister.save(buffer)


    new ActivitySummary()
])
