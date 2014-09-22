class ActivityLoader
    constructor: (@$q, @Settings, @ServerHttp, @FS ) ->
    _pathToBody: (activityId) -> document.numeric.path.body + activityId
    _uriCache: (activityId) ->
        uri = if @_inCordova() then document.numeric.url.base.cdv else document.numeric.url.base.chrome
        cb = "?cb=" + Math.round( (new Date()) / 1 )
        uri + document.numeric.url.base.fs + @_pathToBody(activityId) + cb
    _uriRemote: (activityId) -> @Settings.get('mainServerAddress') + @_pathToBody(activityId)

    _scriptId: 'script_currentlyLoaded'
    _inCordova: () -> typeof LocalFileSystem != 'undefined'

    _createScriptTagAndLoad: (uri, activityId) => # removes the added dom element script if failed
        console.log('__ attempt to load script with activityId: ' + activityId + ' and uri: ' + uri)
        deferred = @$q.defer()
        try
            newScript = document.createElement('script')
            newScript.type = 'text/javascript'
            newScript.id = @_scriptId
            newScript.onload = =>
                if document.numeric.numericTasks[activityId]
                    activity = document.numeric.numericTasks[activityId]
                    delete document.numeric.numericTasks[activityId]
                    deferred.resolve(activity)
                else
                    deferred.reject('could not load script with tag due to some error')
            newScript.onerror = (status) => deferred.reject(status)
            newScript.src = uri
            try
                document.getElementsByTagName('head')[0].removeChild(document.getElementById(@_scriptId))
            catch e
            document.getElementsByTagName('head')[0].appendChild(newScript);
        catch e
            deferred.reject(e)
        deferred.promise

    _loadScriptFromCache: (activityId) =>
        deferred = @$q.defer()
        @_createScriptTagAndLoad(@_uriCache(activityId), activityId)
        .then (activity) =>
            try
                document.getElementsByTagName('head')[0].removeChild(document.getElementById(@_scriptId))
            catch e
            deferred.resolve(activity)
        .catch (status) =>
            try
                document.getElementsByTagName('head')[0].removeChild(document.getElementById(@_scriptId))
            catch e
            deferred.reject(status)
        deferred.promise

    _tryCachedActivity: (activityId, version) =>
        deferred = @$q.defer()
        @_loadScriptFromCache(activityId)
        .then (activity) =>
#            console.log(version)
#            console.log(activity.meta.version)
#            console.log(version == activity.meta.version)
#            console.log(activity.id)
#            console.log(activityId)
#            console.log(activity.id == activityId)
            if activity != undefined && activity.id == activityId && (version == undefined || (activity.meta != undefined && version == activity.meta.version) )
                deferred.resolve(activity)
            else
                deferred.reject('cached activity is older')

        .catch (status) =>
            deferred.reject(status)
        deferred.promise

    loadActivity: (activityId, version) =>
        if version != undefined
            version = Number(version)
        deferred = @$q.defer()

        if @_loadedActivity != undefined && @_loadedActivity.id == activityId && (version == undefined || ( @_loadedActivity.meta != undefined && version == @_loadedActivity.meta.version ) )
            deferred.resolve(@_loadedActivity)
        else
            @_tryCachedActivity(activityId, version)
            .catch (status) =>
                @ServerHttp.download(@_uriRemote(activityId), @_pathToBody(activityId))
                .then => @_tryCachedActivity(activityId, version)
            .then (activity) =>
                @_loadedActivity = activity
                deferred.resolve(@_loadedActivity)

            .catch (status) => deferred.reject(status)

        deferred.promise

    removeCachedActivity: (activityId) =>
        deferred = @$q.defer()
        @FS.tryDeleteFile(@_pathToBody(activityId))
        .then (result) => deferred.resolve(result)
        .catch (status) => deferred.reject(status)
        deferred.promise

angular.module('ActivityLib')
.factory("ActivityLoader", ['$q', 'Settings', 'ServerHttp', 'FS', ($q, Settings, ServerHttp, FS ) ->
    new ActivityLoader($q, Settings, ServerHttp, FS )
])