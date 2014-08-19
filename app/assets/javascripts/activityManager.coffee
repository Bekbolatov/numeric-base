angular.module('AppOne')

.factory("ActivityManager", ['Bookmarks', 'ActivityBody', (Bookmarks, ActivityBody ) ->
    class ActivityManager
        constructor: -> @bookmarks = Bookmarks.bookmarks
        getInstalledActivitiesMeta: -> @bookmarks
        getInstalledActivityMeta: (activityId) -> @bookmarks[activityId]
        isInstalled: (activityId) -> @bookmarks[activityId] != undefined
        installActivity: (activityId) ->
            Bookmarks.add(activityId)
            # maybe also need to download the activity body
        uninstallActivity: (activityId) -> Bookmarks.remove(activityId)

        loadActivity: (activityId) -> ActivityBody.getOrLoad(activityId)

    console.log('CALL TO FACTORY: ActivityManager')
    new ActivityManager()
])
