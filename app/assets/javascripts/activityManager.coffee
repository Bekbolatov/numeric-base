angular.module('AppOne')

.factory("ActivityManager", ['$rootScope', 'Marketplace' , ($rootScope, Marketplace ) ->
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
                console.log('key ' + key + ' is already used by an exiting task ' + @activities[key].name + ', will not overwrite with new task ' + task.name)
            else
                console.log('adding activity with id ' + key + ' and name ' + task.name)
                task.id = key
                task.scriptId = @_scriptIdFromActivityId(key)
                @activities[task.id] = task
                console.log('added activity ' + task.name + ' with id ' + task.id)

        deregisterTask: (taskId) ->
            if (@activities[taskId])
                console.log('removing activity with id ' + taskId + ' and name ' + @activities[taskId].name)
                element = document.getElementById(@activities[taskId].scriptId)
                element.parentElement.removeChild(element)
                delete @activities[taskId]
                console.log('removed activity with id ' + taskId)
            else
                console.log('activity with id ' + taskId + ' has not been registered before')

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
            @loadScriptsBatch([localStoreUrl])

        loadScript: (url) ->
            scriptId = @_scriptIdFromActivityId(@_activityIdFromURL(url))
            newScript = document.createElement('script')
            newScript.type = 'text/javascript'
            newScript.id = scriptId
            newScript.onload = () =>
                if @_allJsLoaded()
                    console.log('numericTasks: ')
                    console.log(document.numeric.numericTasks)
                    console.log("scriptId: " + scriptId)
                    for key, task of document.numeric.numericTasks
                        console.log('constructor task key: ' + key);
                        @registerLoadedTask(key, task)
                    $rootScope.$broadcast('activitiesListUpdated', @)

            newScript.src = url
            document.getElementsByTagName('head')[0].appendChild(newScript);

        # TODO  - try to load/register once
        loadScriptPartOfBatch: (url) ->
            scriptId = @_scriptIdFromActivityId(@_activityIdFromURL(url))
            newScript = document.createElement('script')
            newScript.type = 'text/javascript'
            newScript.id = scriptId
            newScript.onload = () =>
                if @_allJsLoaded()
                    console.log('numericTasks: ')
                    console.log(document.numeric.numericTasks)
                    console.log("scriptId: " + scriptId)
                    for key, task of document.numeric.numericTasks
                        console.log('constructor task key: ' + key);
                        @registerLoadedTask(key, task)
                    $rootScope.$broadcast('activitiesListUpdated', @)

            newScript.src = url
            document.getElementsByTagName('head')[0].appendChild(newScript)


        loadScriptsBatch: (scriptSeq) ->
            document.numeric.numericTasks = {}
            for task in scriptSeq
                @loadScriptPartOfBatch(task)

        constructor: () ->
            @loadScriptsBatch(document.numeric.defaultTaskList)

    console.log('CALL TO FACTORY: ActivityManager')
    new ActivityManager()
])
