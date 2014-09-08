angular.module('AppOne')

.factory("Connections", ['$q', 'ServerHttp', 'Settings', 'DeviceId' , ($q, ServerHttp, Settings, DeviceId ) ->
    class Connections
        _key: document.numeric.key.connections
        _urls:
            remote: -> Settings.get('mainServerAddress') + document.numeric.path.connections
        _read: -> JSON.parse(window.localStorage.getItem(@_key))
        _write: (table) -> window.localStorage.setItem(@_key, JSON.stringify(table))
        _clear: -> window.localStorage.setItem(@_key, JSON.stringify({}))
        _add: (connectionInfo) ->
            table = @_read()
            table.push(connectionInfo)
            @_write(table)

        _indexOf: (connectionId) =>
            for index, item of @_read()
                if item.id == connectionId
                    return index
            return -1

        _remove: (connectionId) ->
            i = @_indexOf(connectionId)
            if i < 0
                return 1
            table = @_read()
            table.splice(i, 1)
            @_write(table)

        _httpGet: =>
            =>
                url = @_urls.remote()
                deferred = $q.defer()
                console.log('|- trying ' + url + ' ...')
                ServerHttp.get(url)
                .then( \
                    (response) =>
                        console.log('| |- found at ' + url)
                        if response.data != undefined
                            @_write(response.data)
                            deferred.resolve(data)
                        else
                            deferred.reject('no data')
                    (status) =>
                        console.log('| |- not found at ' + url)
                        deferred.reject(status)
                )
                deferred.promise

        getAll: () -> @_read()
        add: (connectionId, connectionInfo) -> @_add(connectionId, connectionInfo)

        constructor: ->
            if !@_read()
                @_httpGet()()
                # temporarily load fake info
                .catch(
                    (status) =>
                    @_write(document.numeric.defaultTeachersList)
                )
                # normally, just initialize
                #@_clear()


    console.log('CALL TO FACTORY: Connections')
    new Connections()
])