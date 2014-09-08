angular.module 'ModuleCommunication'

.factory 'ServerHttp', ['$q', '$http', 'FileDownload', 'DeviceId', 'MessageDispatcher', ( $q, $http, FileDownload, DeviceId, MessageDispatcher ) ->
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
        download: (url, dst) ->
            if url.indexOf('?') > -1
                url = url + DeviceId.qsAndWithCb(1000)
            else
                url = url + DeviceId.qsWithCb(1000)
            FileDownload.download(
                url
                dst
                ->
                ->
                false
                { headers: { "Authorization": '' + DeviceId.deviceSecretId } })
    new ServerHttp()
]