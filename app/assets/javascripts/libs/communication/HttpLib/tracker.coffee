angular.module 'ModuleCommunication'

.factory 'Tracker', ['Settings', 'ServerHttp', ( Settings, ServerHttp ) ->
    class Tracker
        touch: (page, id) ->
            if !Settings.ready
                return 0

            idParam = if id != undefined
                "&id=" + id
            else
                ""
            ServerHttp.get(Settings.get('mainServerAddress') + document.numeric.path.touch + "?page=" + page + idParam, {timeout: 2000}, 10)

    new Tracker()
]