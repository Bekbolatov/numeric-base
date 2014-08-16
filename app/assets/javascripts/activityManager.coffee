angular.module('AppOne')

.factory("ActivityManager", ['$rootScope', '$q', 'Marketplace', 'ActivityMeta', 'ActivityBody' , ($rootScope, $q, Marketplace, ActivityMeta, ActivityBody ) ->
    class ActivityManager
        constructor: () ->
            ActivityBody.loadActivities(document.numeric.defaultActivitiesList)
            .then((result) -> console.log('result: ' + result))
            .catch((status) -> console.log('error loading scripts: ' + status))

        getAllActivities: -> ActivityBody.all()
        getActivity: (activityId) -> ActivityBody.get(activityId)

    console.log('CALL TO FACTORY: ActivityManager')
    new ActivityManager()
])
