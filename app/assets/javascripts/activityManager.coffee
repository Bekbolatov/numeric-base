angular.module('AppOne')

.factory("ActivityManager", ['$q', 'Bookmarks', 'ActivityBody', ($q, Bookmarks, ActivityBody ) ->
    class ActivityManager
        constructor: -> @bookmarks = Bookmarks.bookmarks
        getInstalledActivitiesMeta: -> @bookmarks
        getInstalledActivityMeta: (activityId) -> @bookmarks[activityId]
        isInstalled: (activityId) -> @bookmarks[activityId] != undefined
        installActivity: (activityId) ->
            deferred = $q.defer()
            ActivityBody
            .loadActivity(activityId)
            .then(
                -> ActivityBody.unloadActivity(activityId)
            )
            .then(
                ->
                    Bookmarks.add(activityId)
                    deferred.resolve('ok')
            )
            .catch(
                (status) ->
                    console.log(status)
                    deferred.reject(status)
            )
            deferred.promise
            # 1. maybe also need to download the activity body
            # if no local cdvfile is present
        uninstallActivity: (activityId) ->
            Bookmarks.remove(activityId)
            # 1. maybe also remove the cdvfile is there was one
            # 2. maybe also try to unload from memory

        loadActivity: (activityId) -> ActivityBody.getOrLoad(activityId)

    console.log('CALL TO FACTORY: ActivityManager')
    new ActivityManager()
])
