class ActivityManager
    constructor: (@$q, @ActivityBody ) ->
    installActivity: (activityId, meta) ->
        deferred = $q.defer()
        ActivityBody
        .loadActivity(activityId)
        .then(
            -> ActivityBody.unloadActivity(activityId)
        )
        .then(
            ->
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
                deferred.resolve('ok')
        )
        deferred.promise

    getActivity: (activityId) -> ActivityBody.loadActivity(activityId)

angular.module('AppOne')
.factory "ActivityManager-old", ['$q', 'ActivityBody', ( $q, ActivityBody ) ->
    new ActivityManager($q, ActivityBody )
]
