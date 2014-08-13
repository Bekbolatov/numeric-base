angular.module('AppOne')

.factory("Marketplace", ['$rootScope', '$http', ($rootScope, $http) ->
    class Marketplace

        writeToScopePublicActivities: ($scope, fieldData, fieldError, searchTerm, pageNumber)->
            searchTermArg = ""
            if searchTerm != undefined
                searchTermArg = "&q=" + searchTerm

            $http.get("assets/tasks/acftivitiesPublic.js?p=" + pageNumber + searchTermArg)
                .success (data, status, headers, config) ->
                    $scope[fieldData] = data;
                .error (data, status, headers, config) ->
                    $scope[fieldError] = status;

    new Marketplace()
])
