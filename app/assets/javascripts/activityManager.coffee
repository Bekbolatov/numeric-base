angular.module('AppOne')

.factory("ActivityManager", ['$rootScope', '$q', 'Marketplace', 'ActivityMeta' , ($rootScope, $q, Marketplace, ActivityMeta ) ->
    class ActivityManager
        # One 'Activity' (aka 'task', 'practice set') <-> One JS script, loaded into DOM
        # One 'Activity' <=> One Id - probably use com.sparkydots.numeric.tasks.t.basic_math
        activities: {}
        getAllActivities: ->
            @activities
        getActivity: (key) ->
            @activities[key]

        registerLoadedTask: (key, task) ->
            if (@activities[key])
                console.log('key ' + key + ' is already used by an exiting task ' + @activities[key].meta.name + ', will not overwrite with new task ' + task.meta.name)
            else
                console.log('adding activity with id: ' + key)
                task.id = key
                task.scriptId = @_scriptIdFromActivityId(key)
                @activities[task.id] = task
                console.log('added activity with id: ' + task.id)

        deregisterTask: (taskId) ->
            if (@activities[taskId])
                console.log('removing activity with id: ' + taskId)
                element = document.getElementById(@activities[taskId].scriptId)
                element.parentElement.removeChild(element)
                delete @activities[taskId]
                console.log('removed activity with id: ' + taskId)
            else
                console.log('activity with id: ' + taskId + ' - has not been registered before')

        _activityIdFromURL: (url) ->
            namejs = url.split(/\/+/).pop()
            name = namejs.substring(0, namejs.length-3)
            name

        _scriptIdFromActivityId: (activityId) ->
            'script_' + activityId

        _hash: (someString) ->
            hash = 0
            for i in [0...(someString.length-1)]
                hash = ((hash << 5) - hash) + someString.charCodeAt(i)
                hash |= 0
            Math.abs(hash)

        _allJsLoaded: ->
            return true

        # TODO
        installActivity: (activityId) ->
            #first try local store
            localStoreUrl = Marketplace.activityFileFromLocalStore(activityId)
            @loadScripts([localStoreUrl])

        loadScriptFunction: (key) ->
            uri = document.numeric.urlActivityBodyLocal + key + '.js'
            deferred = $q.defer()
            scriptId = @_scriptIdFromActivityId(key)
            newScript = document.createElement('script')
            newScript.type = 'text/javascript'
            newScript.id = scriptId
            newScript.onload = ->
                ActivityMeta.get(key)
                .then(
                    (data)->
                        document.numeric.numericTasks[key].meta = data
                        deferred.resolve('script loaded from location: ' + uri)
                    (status) ->
                        deferred.reject(status)
                )
            newScript.src = uri
            document.getElementsByTagName('head')[0].appendChild(newScript);
            deferred.promise

        registerLoadedNumericTasks: =>
            deferred = $q.defer()
            console.log('numericTasks: ')
            console.log(document.numeric.numericTasks)
            for key, task of document.numeric.numericTasks
                @registerLoadedTask(key, task)
            #$rootScope.$broadcast('activitiesListUpdated', @)
            deferred.resolve('tasks loaded')
            deferred.promise

        attachActivityMeta: (key)=>
            deferred = $q.defer()
            ActivityMeta.get(key)
            .then(
                (data)->
                    document.numeric.numericTasks[key].meta = data
                    deferred.resolve('attached meta')
                (status) ->
                    deferred.reject(status)
            )
            deferred.promise

        loadScripts: (scriptSeq) ->
            console.log('loadScripts called with ' + scriptSeq)
            document.numeric.numericTasks = {}
            promises = []
            for task in scriptSeq #angular.forEach( $scope.testArray, function(value){
                promises.push(@loadScriptFunction(task))
                #promises.push(@attachActivityMeta(task))
            $q.all(promises)
            .then(@registerLoadedNumericTasks)


        constructor: () ->
            @loadScripts(document.numeric.defaultActivitiesList)
            .then((result) -> console.log('result: ' + result))
            .catch((status) -> console.log('error loading scripts: ' + status))

    console.log('CALL TO FACTORY: ActivityManager')
    new ActivityManager()
])
