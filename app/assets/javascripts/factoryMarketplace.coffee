angular.module('AppOne')

.factory("Marketplace", ['$rootScope', '$http', ($rootScope, $http) ->
    class Marketplace
        config:
            localTasksBase: document.numeric.localTasksBaseUrl
            activitiesPublic: document.numeric.publicTasksUrlLocal

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
