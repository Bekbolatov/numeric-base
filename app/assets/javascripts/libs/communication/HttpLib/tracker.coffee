angular.module 'ModuleCommunication'

.factory 'Tracker', ['Settings', 'ServerHttp', ( Settings, ServerHttp ) ->
    class Tracker
        touch: (page, id) ->
            idParam = if id != undefined
                "&id=" + id
            else
                ""
            ServerHttp.get(Settings.get('mainServerAddress') + "touch?page=" + page + idParam, {timeout: 2000}, 10)

    new Tracker()
]