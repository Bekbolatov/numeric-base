angular.module 'ModuleCommunication'

.factory 'ServerHttp', ['$q', '$http', 'DeviceId', 'MessageDispatcher', ( $q, $http, DeviceId, MessageDispatcher ) ->
    class ServerHttp
        constructor: () ->
        get: (url, options) ->
            deferred = $q.defer()
            url = url + DeviceId.qsWithCb(1000)
            #options mix-in/override
            $http.get(url , { cache: false, timeout: 7000, headers: { "Authorization": "Basic " + DeviceId.deviceSecretId } })
            .then (response) =>
                data = response.data
                if data != undefined && data.messages != undefined && data.content != undefined
                    MessageDispatcher.addNewMessages(data.messages)
                    response.data = data.content
                deferred.resolve(response)
            .catch (e) => deferred.reject(e)
            deferred.promise

    new ServerHttp()
]