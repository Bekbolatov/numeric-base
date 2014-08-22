angular.module('AppOne')

# depends only on $q, ActivityMeta, FileDownload
# Most common uses:
# ActivityBody.all()/.get('com.sparkydots.groupa.activitya') - gives all registered activities or one specific activity by id
# loadActivity('com.sparkydots.groupa.activitya') - obtains activity, local cache, or remote server and loads JS in a new script tag in the head - makes available for .get(...)
# unloadActivity('com.sparkydots.groupa.activitya')
.factory("ActivityBody", ['$q', 'ActivityMeta', 'FileDownload', ($q, ActivityMeta, FileDownload ) ->
    class ActivityBody
        _activities: {}
        _scriptId: (activityId) -> 'script_' + activityId
        _uriCdv: (activityId) -> document.numeric.url.base.cdv + document.numeric.url.base.fs + document.numeric.path.body + activityId
        _uriLocal: (activityId) -> document.numeric.url.base.local + document.numeric.path.body + activityId
        _uriRemote: (activityId) -> document.numeric.url.base.server + document.numeric.path.body + activityId

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

        _downloadActivityBody: (activityId)-> FileDownload.download(@_uriRemote(activityId), @_uriCdv(activityId))

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

        loadActivity: (activityId) =>
            console.log('Call to load script with activityId: ' + activityId)
            if @_activities[activityId]
                deferred = $q.defer()
                deferred.resolve('already loaded')
                deferred.promise
            else
                if typeof LocalFileSystem == 'undefined'
                    @_loadScript(@_uriRemote(activityId), activityId)
                    .then => @_attachActivityMeta(activityId)
                else
                    @_loadScript(@_uriLocal(activityId), activityId)
                    .catch => @_loadScript(@_uriCdv(activityId), activityId)
                    .catch =>
                        @_downloadActivityBody(activityId)
                        .then => @_loadScript(@_uriCdv(activityId), activityId)
                    .then => @_attachActivityMeta(activityId)

        loadActivities: (activities) ->
            console.log('loadScripts called with ' + activities)
            promises = []
            for activityId in activities
                promises.push(@loadActivity(activityId))
            $q.all(promises)

        #marked for del
        #all: -> @_activities
        get: (activityId) -> @_activities[activityId]
        getOrLoad: (activityId) =>
            deferred = $q.defer()
            activity = @_activities[activityId]
            if activity
                deferred.resolve(activity)
            else
                @loadActivity(activityId)
                .then(
                    =>
                        activity = @_activities[activityId]
                        if activity
                            deferred.resolve(activity)
                        else
                            deferred.reject('could not load activity')
                    (status) -> deferred.reject(status)
                )
            deferred.promise

    console.log('CALL TO FACTORY: ActivityBody')
    new ActivityBody()
])