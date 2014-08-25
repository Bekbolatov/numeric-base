angular.module('AppOne')

.factory("ActivityManager", ['$q', 'Bookmarks', 'ActivityBody', 'ActivityMeta', ($q, Bookmarks, ActivityBody, ActivityMeta ) ->
    class ActivityManager
        constructor: -> @bookmarks = Bookmarks.bookmarks
        getInstalledActivitiesMeta: -> @bookmarks
        getInstalledActivityMeta: (activityId) -> @bookmarks[activityId]
        isInstalled: (activityId) -> @bookmarks[activityId] != undefined

        installActivity: (activityId, meta) ->
            deferred = $q.defer()
            if meta
                ActivityMeta.set(activityId, meta)
            ActivityBody
            .loadActivity(activityId)
            .then(
                -> ActivityBody.unloadActivity(activityId)
            )
            .then(
                ->
                    Bookmarks.add(activityId, meta)
                    deferred.resolve('ok')
            )
            .catch(
                (status) ->
                    console.log(status)
                    deferred.reject(status)
            )
            deferred.promise

        uninstallActivity: (activityId) ->
            deferred = $q.defer()
            ActivityBody.unloadActivity(activityId)
            ActivityBody.removeBody(activityId)
            .then(
                () =>
                    Bookmarks.remove(activityId)
                    deferred.resolve('ok')
            )
            deferred.promise

        updateActivity: (activityId, meta) =>
            deferred = $q.defer()
            @uninstallActivity(activityId)
            .then(
                (data) =>
                    @installActivity(activityId, meta)
                    deferred.resolve(data)
            )
            deferred.promise

        loadActivity: (activityId) -> ActivityBody.getOrLoad(activityId)

    console.log('CALL TO FACTORY: ActivityManager')
    new ActivityManager()
])
