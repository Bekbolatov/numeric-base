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

        get: (url, options, cbtime) ->
            deferred = $q.defer()
            if cbtime == undefined
                cbtime = 1000
            cb = "cb=" + Math.round( (new Date()) / cbtime )

            if url.indexOf('?') > -1
                url = url + '&' + cb
            else
                url = url + '?' + cb
            if options != undefined
                if options.cache == undefined
                    options.cache = false
                if options.timeout == undefined
                    options.timeout = 7000
                if options.headers == undefined
                    options.headers = { "Authorization": '' + DeviceId.deviceSecretId + ':' + DeviceId.devicePublicId + ':' + @version() }
                else if options.headers.Authorization == undefined
                    options.headers.Authorization = '' + DeviceId.deviceSecretId
            else
                options = { cache: false, timeout: 7000, headers: { "Authorization": '' + DeviceId.deviceSecretId  + ':' + DeviceId.devicePublicId + ':' + @version() } }
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
            deferred = $q.defer()
            FS.tryDeleteFile(filePath)
            .then (result) -> console.log('deleted previous version')
            .catch (status) -> console.log('could not delete previous version')
            .then (result) =>
                @get(url)
                .then (response) ->
                    try
                        data = response.data
                        FS.writeToFile(filePath, data)
                        .then (response) -> deferred.resolve('ok')
                        .catch (e) -> deferred.reject(e)
                    catch t
                        deferred.reject(t)
                .catch (e) -> deferred.reject(e)
            deferred.promise


        delete: (url, options) ->
            console.log("delete url: " + url)
            deferred = $q.defer()

            if options != undefined
                if options.headers == undefined
                    options.headers = { "Authorization": '' + DeviceId.deviceSecretId + ':' + DeviceId.devicePublicId + ':' + @version() }
                else if options.headers.Authorization == undefined
                    options.headers.Authorization = '' + DeviceId.deviceSecretId
            else
                options = { headers: { "Authorization": '' + DeviceId.deviceSecretId  + ':' + DeviceId.devicePublicId + ':' + @version() } }

            $http.defaults.headers.common.Authorization = '' + DeviceId.deviceSecretId  + ':' + DeviceId.devicePublicId + ':' + @version()
            $http.delete(url)

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