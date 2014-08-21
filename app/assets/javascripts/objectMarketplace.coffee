angular.module('AppOne')

.factory("Marketplace", ['$http', ($http ) ->
    class Marketplace
        config:
            activitiesLocal: document.numeric.url.base.local + document.numeric.path.meta + document.numeric.path.list
            activitiesPublic: document.numeric.url.base.server + document.numeric.path.meta + document.numeric.path.list

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
