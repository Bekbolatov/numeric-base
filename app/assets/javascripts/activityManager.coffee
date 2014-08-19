angular.module('AppOne')

.factory("ActivityManager", ['Bookmarks', 'ActivityBody', (Bookmarks, ActivityBody ) ->
    class ActivityManager
        getInstalledActivitiesMeta: -> Bookmarks.getAll()
        getInstalledActivityMeta: (activityId) -> Bookmarks.get(activityId)
        isInstalled: (activityId) -> (Bookmarks.get(activityId) != undefined)
        installActivity: (activityId) ->
            Bookmarks.add(activityId)
        uninstallActivity: (activityId) ->
            Bookmarks.remove(activityId)

    console.log('CALL TO FACTORY: ActivityManager')
    new ActivityManager()
])
