angular.module('AppOne')

.factory("ActivityManager", ['$rootScope', '$q', 'Marketplace', 'ActivityMeta' , ($rootScope, $q, Marketplace, ActivityMeta ) ->
    class ActivityManager


        constructor: () ->
            @loadScripts(document.numeric.defaultActivitiesList)
            .then((result) -> console.log('result: ' + result))
            .catch((status) -> console.log('error loading scripts: ' + status))

    console.log('CALL TO FACTORY: ActivityManager')
    new ActivityManager()
])
