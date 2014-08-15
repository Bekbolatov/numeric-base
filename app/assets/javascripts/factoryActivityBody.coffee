angular.module('AppOne')

.factory("ActivityBody", ['$q', '$http' , ($q, $http ) ->
    class FileDownloader
        constructor: ->
            if window.requestFileSystem
                @webkit = false
            else
                window.requestFileSystem = window.webkitRequestFileSystem
                @webkit = true
            console.log('requestFileSystem webkit=' + @webkit)
        errorHandler = (dfd) ->
            (e) ->
                msg = switch e.code
                    when FileError.QUOTA_EXCEEDED_ERR then 'QUOTA_EXCEEDED_ERR'
                    when FileError.NOT_FOUND_ERR then 'NOT_FOUND_ERR'
                    when FileError.SECURITY_ERR then 'SECURITY_ERR'
                    when FileError.INVALID_MODIFICATION_ERR then 'INVALID_MODIFICATION_ERR'
                    when FileError.INVALID_STATE_ERR then 'INVALID_STATE_ERR'
                    else 'Unknown Error'
                console.log('ERROR: ' + msg)
                dfd.reject(msg)
        onInitFs: (uri, fileURL, dfd) ->
            (fs) ->
                console.log("Opened file system: " + fs.name + " : " + fs.root.fullPath);
                fileTransfer = new FileTransfer();
                fileTransfer.download(
                    uri
                    fileURL
                    (entry) ->
                        console.log("download complete: " + entry.fullPath)
                        dfd.resolve('ok')
                    (error) ->
                        console.log("download error source " + error.source)
                        dfd.reject(error.code)
                    false
                    {
                        headers:
                            "Authorization": "Basic dGVzdHVzZXJuYW1lOnRlc3RwYXNzd29yZA=="

                    }
            )
        download: (uri, fileURL) ->
            deferred = $q.defer()
            window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, @onInitFs(uri, fileURL, deferred), @errorHandler)
            deferred.promise

    class ActivityBody
        _activities: {}
        _scriptId: (activityId) -> 'script_' + activityId
        _downloader: new FileDownloader()
        _uriCdv: (activityId) -> document.numeric.directoryActivityBody + activityId + '.js'
        _uriFS: (activityId) -> document.numeric.directoryActivityBodyFS + activityId + '.js'
        _uriLocal: (activityId) -> document.numeric.urlActivityBodyLocal + activityId + '.js'
        _uriRemote: (activityId) -> document.numeric.urlActivityBodyServer + activityId + '.js'
        _downloadActivityFromLocal: (key) -> @_downloader.download(@_uriLocal(key), @_uriCdv(key))
        _downloadActivityFromRemote: (key) -> @_downloader.download(@_uriRemote(key), @_uriCdv(key))

        get: (activityId) -> @_activities[activityId]

        unloadActivity: (activityId) ->
            if (@_activities[activityId])
                element = document.getElementById(@_scriptId(activityId))
                element.parentElement.removeChild(element)
                delete @_activities[activityId]

        attachActivityMeta: (key)=>
            deferred = $q.defer()
            ActivityMeta.get(key)
            .then(
                (data)->
                    @_activities[key].id = key
                    @_activities[key].meta = data
                    deferred.resolve('attached meta')
                (status) ->
                    deferred.reject(status)
            )
            deferred.promise

        loadScriptLocalwww: (key) => @loadScript_(@_uriLocal(key), key) #works when exists in distribution
        loadScriptLocalFS: (key) => @loadScript_(@_uriFS(key), key)
        loadScriptLocalCDV: (key) => @loadScript_(@_uriCdv(key), key)

        loadScript_: (uri, key) => # removes the added dom element script if failed
            console.log('tryin to load script with key: ' + key + ' and uri: ' + uri)
            deferred = $q.defer()
            scriptId = @_scriptId(key)
            newScript = document.createElement('script')
            newScript.type = 'text/javascript'
            newScript.id = scriptId
            newScript.onload = =>
                console.log('script onload')
                if document.numeric.numericTasks[key]
                    @_activities[key] = document.numeric.numericTasks[key]
                    delete document.numeric.numericTasks[key]
                    @_activities[key].id = key
                    deferred.resolve('script loaded: ' + scriptId)
                else
                    element = document.getElementById(scriptId)
                    element.parentElement.removeChild(element)
                    deferred.reject('script did not load: ' + scriptId)
            newScript.onerror = =>
                element = document.getElementById(scriptId)
                element.parentElement.removeChild(element)
                deferred.reject('error occured, script did not load: ' + scriptId)
            newScript.src = uri
            document.getElementsByTagName('head')[0].appendChild(newScript);
            deferred.promise


        loadScript: (key) => # removes the added dom element script if failed
            console.log('tryin to load script with key: ' + key)
            deferred = $q.defer()
            scriptId = @_scriptId(key)
            uri = @_uriCdv(key)
            if @_downloader.webkit
                uri = @_uriLocal(key) #uri CVD - testing in webapp
            newScript = document.createElement('script')
            newScript.type = 'text/javascript'
            newScript.id = scriptId
            newScript.onload = =>
                console.log('script onload')
                if document.numeric.numericTasks[key]
                    @_activities[key] = document.numeric.numericTasks[key]
                    delete document.numeric.numericTasks[key]
                    @_activities[key].id = key
                    deferred.resolve('script loaded: ' + scriptId)
                else
                    element = document.getElementById(scriptId)
                    element.parentElement.removeChild(element)
                    deferred.reject('script did not load: ' + scriptId)
            newScript.src = uri
            document.getElementsByTagName('head')[0].appendChild(newScript);
            deferred.promise



        loadScripts: (scriptSeq) ->
            console.log('loadScripts called with ' + scriptSeq)
            document.numeric.numericTasks = {}
            promises = []
            for task in scriptSeq #angular.forEach( $scope.testArray, function(value){
                promises.push(@loadScriptFunction(task))
                #promises.push(@attachActivityMeta(task))
            $q.all(promises)
            #.then(@registerLoadedNumericTasks)

        loadActivity: (activityId) ->
            #first try local store
            localStoreUrl = Marketplace.activityFileFromLocalStore(activityId)
            @loadScripts([activityId])


    new ActivityBody()
])