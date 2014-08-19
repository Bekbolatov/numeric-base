angular.module('AppOne')

# depends only on $q, $http and ActivityMeta
# Most common uses:
# ActivityBody.all()/.get('com.sparkydots.groupa.activitya') - gives all registered activities or one specific activity by id
# loadActivity('com.sparkydots.groupa.activitya') - obtains activity, local cache, or remote server and loads JS in a new script tag in the head - makes available for .get(...)
# unloadActivity('com.sparkydots.groupa.activitya')
.factory("ActivityBody", ['$q', '$http', 'ActivityMeta', ($q, $http, ActivityMeta ) ->
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
                fileTransfer = new FileTransfer();
                fileTransfer.download(
                    uri
                    fileURL
                    (entry) ->
                        dfd.resolve('ok')
                    (error) ->
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
        _uriLocal: (activityId) -> document.numeric.urlActivityBodyLocal + activityId + '.js'
        _uriRemote: (activityId) -> document.numeric.urlActivityBodyServer + activityId + '.js'

        _attachActivityMeta: (key)=>
            deferred = $q.defer()
            ActivityMeta.get(key)
            .then(
                (data)=>
                    @_activities[key].id = key
                    @_activities[key].meta = data
                    deferred.resolve('attached meta')
                (status) ->
                    deferred.reject(status)
            )
            deferred.promise

        _loadScript: (uri, key) =>
            deferred = $q.defer()
            @__loadScript(uri, key)
            .then (result) =>
                deferred.resolve(result)
            .catch (status) =>
                element = document.getElementById(@_scriptId(key))
                element.parentElement.removeChild(element)
                deferred.reject(status)
            deferred.promise

        __loadScript: (uri, key) => # removes the added dom element script if failed
            console.log('__ attempt to load script with key: ' + key + ' and uri: ' + uri)
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
                    deferred.reject('script did not load: ' + scriptId)
            newScript.onerror = =>
                deferred.reject('error occured, script did not load: ' + scriptId)
            newScript.src = uri
            document.getElementsByTagName('head')[0].appendChild(newScript);
            deferred.promise

        unloadActivity: (activityId) ->
            if (@_activities[activityId])
                element = document.getElementById(@_scriptId(activityId))
                element.parentElement.removeChild(element)
                delete @_activities[activityId]

        loadActivity: (activityId) => # if on web, maybe can use @downloader.webkit to determine and bypass downloads to local (insteads, always use from remote)
            console.log('Call to load script with activityId: ' + activityId)
            if @_activities[activityId]
                deferred = $q.defer()
                deferred.resolve('already loaded')
                deferred.promise
            else
                @_loadScript(@_uriLocal(activityId), activityId)
                .catch => @_loadScript(@_uriCdv(activityId), activityId)
                .catch =>
                    @_downloader.download(@_uriRemote(activityId), @_uriCdv(activityId))
                    .then => @_loadScript(@_uriCdv(activityId), activityId)
                .then => @_attachActivityMeta(activityId)

        loadActivities: (activities) ->
            console.log('loadScripts called with ' + activities)
            promises = []
            for activityId in activities
                promises.push(@loadActivity(activityId))
            $q.all(promises)

        all: -> @_activities
        get: (activityId) -> @_activities[activityId]

    console.log('CALL TO FACTORY: ActivityBody')
    new ActivityBody()
])