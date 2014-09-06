angular.module('AppOne')
# In memory cache with Write-through to persistence service of bookmarked (aka "installed") activities Meta information
# If no such was persisted then bootstraps with list in document.numeric.defaultActivitiesList
# Persistence is layered 1. localStorage[document.numeric.keys.bookmarkedActivities], 2. FileSystem, 3. Server
.factory("Bookmarks", ['$q', 'PersistenceManager', 'ActivityMeta', ($q, PersistenceManager, ActivityMeta ) ->
    class Bookmarks
        get: (activityId) -> @writeThruCache.get(activityId)
        add: (activityId, meta) -> @writeThruCache.add(activityId, meta)
        remove: (activityId) -> @writeThruCache.remove(activityId)
        clear: () -> @writeThruCache.clear()
        # promise find meta and initialize cache and persistence
        _findMetaAndAdd: (activityId) =>
            (count) =>
                deferred = $q.defer()
                ActivityMeta.get(activityId)
                .then (meta) =>
                    @add(activityId, meta)
                    .then () =>
                        deferred.resolve(count + 1)
                    .catch (t) =>
                        deferred.resolve(count)
                .catch (t) ->
                    deferred.resolve(count) #don't block other activities load if one fails when no meta is found
                deferred.promise

        constructor: ->
            @writeThruCache = PersistenceManager.writeThruCache(document.numeric.key.bookmarkedActivities)
            @bookmarks = @writeThruCache.cache
            @writeThruCache.initCacheFromPersisted()
            .catch (t) => # bootstrap with default given in _init.js (if nothing was stored before)
                adds = []
                for activityId in document.numeric.defaultActivitiesList
                    adds.push @_findMetaAndAdd(activityId)
                zero = $q.defer()
                zero.resolve(0)
                adds.reduce(
                    (processed, another) => processed.then (count) => another(count)
                    zero.promise
                )
                .then (count) -> console.log('loaded ' + count + ' scripts on bootstrap.')

    new Bookmarks()
])
