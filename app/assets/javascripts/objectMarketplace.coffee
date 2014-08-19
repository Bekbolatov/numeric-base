angular.module('AppOne')

.factory("Marketplace", ['$http', ($http ) ->
    class Marketplace
        config:
            activitiesPublic: document.numeric.urlActivityMetaListServer

        getPublicActivitiesMeta: (pageNumber, searchTerm) ->
            searchTermArg = ""
            if searchTerm != undefined
                searchTermArg = "&q=" + searchTerm.trim()
            $http.get(
                @config.activitiesPublic + "?p=" + pageNumber + searchTermArg
                { cache: false })

    new Marketplace()
])
