angular.module('AppOne')

.factory("Marketplace", ['Settings', 'DeviceId', 'ServerHttp', (Settings, DeviceId, ServerHttp ) ->
    class Marketplace
        config:
            activitiesLocal: -> document.numeric.url.base.local + document.numeric.path.list
            activitiesPublic: -> Settings.get('mainServerAddress') + document.numeric.path.list

        getLocalActivitiesMeta: -> ServerHttp.get(@config.activitiesLocal())
        getPublicActivitiesMeta: (pageNumber, searchTerm, keepCache) ->
            st = ""
            if searchTerm != undefined
                st = "&q=" + searchTerm.trim()

            ServerHttp.get(@config.activitiesPublic() + "?p=" + pageNumber + st)

    new Marketplace()
])
