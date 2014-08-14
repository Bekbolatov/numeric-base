angular.module('AppOne')

.factory("Marketplace", ['$rootScope', '$http', '$q', ($rootScope, $http, $q) ->
    class Marketplace
        activitiesMetaInfo: new ActivitiesMetaInfo()

        config:
            localTasksBase: document.numeric.localTasksBaseUrl
            activitiesPublic: document.numeric.publicTasksUrlLocal

        # stores meta-data about the task, a limited-version of all activity info
        # todo - hook up
        getActivityInfo: (key) ->
            @activitiesMetaInfo.getMetaInfo(key)

        activityFileFromLocalStore: (activityId) ->
            @config.localTasksBase + activityId + '.js'

        writeToScopePublicActivities: ($scope, fieldData, fieldError, searchTerm, pageNumber)->
            searchTermArg = ""
            if searchTerm != undefined
                searchTermArg = "&q=" + searchTerm

            $http.get(@config.activitiesPublic + "?p=" + pageNumber + searchTermArg)
                .success (data, status, headers, config) ->
                    $scope[fieldData] = data;
                .error (data, status, headers, config) ->
                    $scope[fieldError] = status;
    new Marketplace()
])
