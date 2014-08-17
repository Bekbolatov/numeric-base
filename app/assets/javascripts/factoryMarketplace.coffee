angular.module('AppOne')

.factory("Marketplace", ['$rootScope', '$http', '$q', 'ActivityMeta', ($rootScope, $http, $q, ActivityMeta ) ->
    class Marketplace
        config:
            localTasksBase: document.numeric.localTasksBaseUrl
            activitiesPublic: document.numeric.urlActivityMetaListServer

        # stores meta-data about the task, a limited-version of all activity info
        # todo - hook up
        getActivityInfo: (key) ->
            @ActivityMeta.get(key)

        #maybe unused
        activityFileFromLocalStore: (activityId) ->
            @config.localTasksBase + activityId + '.js'

        writeToScopePublicActivities: ($scope, fieldData, fieldError, searchTerm, pageNumber)->
            searchTermArg = ""
            if searchTerm != undefined
                searchTermArg = "&q=" + searchTerm.trim()

            $http.get(@config.activitiesPublic + "?p=" + pageNumber + searchTermArg, { cache: false })
                .success (data, status, headers, config) ->
                    $scope[fieldData] = data;
                .error (data, status, headers, config) ->
                    $scope[fieldError] = status;
    new Marketplace()
])
