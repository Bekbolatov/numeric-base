angular.module('AppOne')

.factory("Marketplace", ['$http', 'DeviceId', ($http, DeviceId ) ->
    class Marketplace
        config:
            activitiesLocal: document.numeric.url.base.local + document.numeric.path.list
            activitiesPublic: document.numeric.url.base.server + document.numeric.path.list

        getLocalActivitiesMeta: -> $http.get(@config.activitiesLocal)
        getPublicActivitiesMeta: (pageNumber, searchTerm, keepCache) ->
            st = ""
            if searchTerm != undefined
                st = "&q=" + searchTerm.trim()

            cb = ""
            if !keepCache
                cb = "&cb=" + Math.round( (new Date()) / 15000 )

            $http.get(
                @config.activitiesPublic + "?p=" + pageNumber + st + DeviceId.qsAnd() + cb
                {
                    timeout: 7000
                    cache: false
                    headers: {
                        "Authorization": "Basic " + DeviceId.deviceSecretId
                    }
                })

    new Marketplace()
])
