angular.module('AppOne')

.factory("Bookmarks", ['$q', 'PersistenceManager', 'ActivityMeta', ($q, PersistenceManager, ActivityMeta ) ->
    class Bookmarks
        get: (activityId) -> @writeThruCache.get(activityId)
        add: (activityId, meta) -> @writeThruCache.set(activityId, meta)
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
            @writeThruCache = PersistenceManager.cacheWithwriteThruToLocalStorePersister(document.numeric.key.bookmarkedActivities)
            @bookmarks = @writeThruCache.cache
            @writeThruCache.init()
            # Start: temp fix - migrate all older
            .then (saved) =>
                @writeThruCache.remove('com.sparkydots.numeric.tasks.ssat.a.q00')
                .then (saved) =>
                    @writeThruCache.remove('com.sparkydots.numeric.tasks.ssat.a.q04')
                    .then (saved) =>
                        @writeThruCache.remove('com.sparkydots.numeric.tasks.ssat.a.q05')
                        .then (saved) =>
                            @writeThruCache.remove('com.sparkydots.numeric.tasks.ssat.b.q00')
            # End: temp fix - migrate all older

            .catch (t) => # bootstrap with default given in _init.js (if nothing was stored before)
                adds = []
                for activityId in document.numeric.defaultActivitiesList
                    adds.push @_findMetaAndAdd(activityId)
                adds.reduce(
                    (processed, another) => processed.then (count) => another(count)
                    $q.when(0)
                )
                .then (count) -> console.log('loaded ' + count + ' scripts on bootstrap.')

    new Bookmarks()
])
