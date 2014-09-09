angular.module 'ModuleCommunication'

.factory 'ServerHttp', ['$q', '$http', 'DeviceId', 'MessageDispatcher', 'FS', ( $q, $http, DeviceId, MessageDispatcher, FS ) ->
    class ServerHttp
        constructor: () ->
        _inCordova: () -> typeof LocalFileSystem != 'undefined'
        _baseCdv: () -> document.numeric.url.base.cdv
        _baseChrome: () -> document.numeric.url.base.chrome
        _baseCdvFs: (path) -> @_baseCdv() + document.numeric.url.base.fs + path
        _base: () ->
            if @_inCordova()
                @_baseCdv()
            else
                @_baseChrome()

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
        download: (url, filePath) ->
            if url.indexOf('?') > -1
                url = url + DeviceId.qsAndWithCb(1000)
            else
                url = url + DeviceId.qsWithCb(1000)
            deferred = $q.defer()
            if @_inCordova()
                fileTransfer = new FileTransfer();
                fileTransfer.download(
                    url
                    @_baseCdvFs(filePath)
                    (entry) -> deferred.resolve('ok')
                    (error) -> deferred.reject(error.code)
                    false
                    {
                        headers:
                            "Authorization": "" + DeviceId.deviceSecretId
                    })
            else
                @get(url)
                .then (response) =>
                    try
                        data = response.data
                        FS.writeToFile(filePath, data)
                        .then (response) =>
                            deferred.resolve('ok')
                        .catch (e) =>
                            deferred.reject(e)
                    catch t
                        deferred.reject(t)
                .catch (e) =>
                    deferred.reject(e)
            deferred.promise
        transformUrl: (url) ->
            if url.indexOf('?') > -1
                url = url + DeviceId.qsAndWithCb(1000)
            else
                url = url + DeviceId.qsWithCb(1000)

    new ServerHttp()
]