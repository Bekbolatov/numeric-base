angular.module 'ModuleCommunication'

.factory 'ServerHttp', ['$q', '$http', 'Settings', 'DeviceId', 'MessageDispatcher', 'FS', ( $q, $http, Settings, DeviceId, MessageDispatcher, FS ) ->
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
        version: -> document.numeric.appVersion
        touch: (page, id) -> @get(Settings.get('mainServerAddress') + page, {timeout: 2000}, 10)

        get: (url, options, cbtime) ->
            deferred = $q.defer()
            if cbtime == undefined
                cbtime = 1000

            if url.indexOf('?') > -1
                url = url + DeviceId.qsAndWithCb(cbtime)
            else
                url = url + DeviceId.qsWithCb(cbtime)
            url += "&v=" + @version()

            if options != undefined
                if options.cache == undefined
                    options.cache = false
                if options.timeout == undefined
                    options.timeout = 7000
                if options.headers == undefined
                    options.headers = { "Authorization": '' + DeviceId.deviceSecretId }
                else if options.headers.Authorization == undefined
                    options.headers.Authorization = '' + DeviceId.deviceSecretId
            else
                options = { cache: false, timeout: 7000, headers: { "Authorization": '' + DeviceId.deviceSecretId } }

            $http.get(url , options)
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

            FS.tryDeleteFile(filePath)
            .then (result) -> console.log('deleted previous version')
            .catch (status) -> console.log('could not delete previous version')
            .then (result) =>
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