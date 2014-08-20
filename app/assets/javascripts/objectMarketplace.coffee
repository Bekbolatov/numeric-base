angular.module('AppOne')

.factory("Marketplace", ['$http', ($http ) ->
    class Marketplace
        config:
            activitiesPublic: document.numeric.urlActivityMetaListServer

        getPublicActivitiesMeta: (pageNumber, searchTerm, keepCache) ->
            st = ""
            if searchTerm != undefined
                st = "&q=" + searchTerm.trim()

            cb = ""
            if !keepCache
                cb = "&cb=" + Math.round( (new Date()) / 15000 )

            $http.get(
                @config.activitiesPublic + "?p=" + pageNumber + st + cb
                { cache: false })

    new Marketplace()
])
