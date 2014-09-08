angular.module 'ModuleCommunication'

.factory 'ServerHttp', ['$q', '$http', 'DeviceId', 'MessageDispatcher', ( $q, $http, DeviceId, MessageDispatcher ) ->
    class ServerHttp
        constructor: () ->
        get: (url, options) ->
            deferred = $q.defer()
            if url.indexOf('?') > -1
                url = url + DeviceId.qsAndWithCb(1000)
            else
                url = url + DeviceId.qsWithCb(1000)
            #options mix-in/override
            $http.get(url , { cache: false, timeout: 7000, headers: { "Authorization": '' + DeviceId.deviceSecretId } })
            .then (response) =>
                data = response.data
                if data != undefined && data.messages != undefined && data.content != undefined
                    MessageDispatcher.addNewMessages(data.messages)
                    response.data = data.content
                deferred.resolve(response)
            .catch (e) => deferred.reject(e)
            deferred.promise
        download: (url, fileURL) ->
            if url.indexOf('?') > -1
                url = url + DeviceId.qsAndWithCb(1000)
            else
                url = url + DeviceId.qsWithCb(1000)

            deferred = $q.defer()
            fileTransfer = new FileTransfer();
            fileTransfer.download(
                url
                fileURL
                (entry) -> deferred.resolve('ok')
                (error) -> deferred.reject(error.code)
                false
                {
                    headers:
                        "Authorization": "" + DeviceId.deviceSecretId
                })
            deferred.promise

    new ServerHttp()
]