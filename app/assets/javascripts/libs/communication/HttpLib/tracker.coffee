angular.module 'ModuleCommunication'

.factory 'Tracker', ['Settings', 'ServerHttp', ( Settings, ServerHttp ) ->
    class Tracker
        touch: (page, id) ->
            if !Settings.ready
                return 0
            if id == undefined
                id = "default"
            else
            ServerHttp.get(Settings.get('mainServerAddress') + document.numeric.path.touch + "/" + page + "/" + id, {timeout: 2000}, 10)

    new Tracker()
]