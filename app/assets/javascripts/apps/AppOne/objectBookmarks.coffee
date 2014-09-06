angular.module('AppOne')

# In memory cache with Write-through to persistence service of bookmarked (aka "installed") activities Meta information
# If no such was persisted then bootstraps with list in document.numeric.defaultActivitiesList
# Persistence is layered 1. localStorage[document.numeric.keys.bookmarkedActivities], 2. FileSystem, 3. Server
# Depends on ActivityMeta
.factory("Bookmarks", ['$q', 'PersistenceManager', 'ActivityMeta', ($q, PersistenceManager, ActivityMeta ) ->
    class Bookmarks
        bookmarks: {} # allows dirty-checking, writes-through to localStorage
        get: (activityId) -> @bookmarks[activityId]

        _key: document.numeric.key.bookmarkedActivities
        _read: -> PersistenceManager.read(@_key)
        _write: (table) -> PersistenceManager.save(@_key, table)
        _clear: -> PersistenceManager.save(@_key, {})

        _add: (activityId, metaData) =>
            @_read()
            .then (table) =>
                table[activityId] = metaData
                @_write(table)
        _remove: (activityId) =>
            @_read()
            .then (table) =>
                if table[activityId]
                    delete table[activityId]
                    @_write(table)

        addHalfSync: (activityId) =>
            ActivityMeta.get(activityId)
            .then(
                (data) =>
                    @bookmarks[activityId] = data
                    @_add(activityId, data)
                (status) -> console.log(status)
            )
        removeHalfSync: (activityId) ->
            if @bookmarks[activityId]
                delete @bookmarks[activityId]
            @_remove(activityId)
        clearHalfSync: () ->
            for id, meta of @bookmarks
                delete @bookmarks[id]
            @_clear()

        add: (activityId) =>
            deferred = $q.defer()
            ActivityMeta.get(activityId)
            .then (data) =>
                    @bookmarks[activityId] = data
                    @_add(activityId, data)
                    .then () =>
                        deferred.resolve()
            .catch (t) =>
                console.log(t)
                deferred.reject(t)
            deferred.promise
        remove: (activityId) ->
            deferred = $q.defer()
            if @bookmarks[activityId]
                delete @bookmarks[activityId]
            @_remove(activityId)
            .then () =>
                deferred.resolve(0)
            .catch (t) =>
                deferred.reject(t)
            deferred.promise
        clear: () ->
            deferred = $q.defer()
            for id, meta of @bookmarks
                delete @bookmarks[id]
            @_clear()
            .then () =>
                deferred.resolve(0)
            .catch (t) =>
                deferred.reject(t)
            deferred.promise

        constructor: ->
            @_read()
            .then (previous) => # load previously saved
                console.log(previous)
                for id, meta of previous
                    @bookmarks[id] = meta
            .catch (t) =>
                @_clear() # bootstrap with default given in _init.js (if nothing was stored before)
                .then (t) =>
                    adds = []
                    for activityId in document.numeric.defaultActivitiesList
                        adds.push(@add(activityId))
                    $q.all(adds)

    new Bookmarks()
])
