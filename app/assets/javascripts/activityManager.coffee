angular.module('AppOne')

.factory("ActivityManager", ['$rootScope', ($rootScope) ->
    class ActivityManager
        taskTypes: {}
        setTaskType: (taskType) ->
            @currentTaskType = taskType
            @currentTask = @taskTypes[@currentTaskType]
            @currentTaskAnswerType = @currentTask.answerType
        hasTaskType: (taskType) ->
            @taskTypes[taskType] != undefined

        registerTask: (task) ->
            if (task.name in @taskTypes)
                console.log('task ' + task.name + ' is already registered')
            else
                @taskTypes[task.name] = task
        deregisterTask: (taskName) ->
            if (taskName in @taskTypes)
                delete @taskTypes[taskName]
            else
                console.log('task ' + taskName + ' is already registered')

        loadScript: (url) ->
            newScript = document.createElement('script')
            newScript.type = 'text/javascript'
            newScript.onload = () =>
                console.log(document.numeric.numericTasks);
                for key, task of document.numeric.numericTasks
                    console.log('constructor task key: ' + key);
                    @registerTask(task)
                    $rootScope.$broadcast('activitiesListUpdated', @)
            newScript.src = url
            document.getElementsByTagName('head')[0].appendChild(newScript);


        loadScripts: (scriptSeq) ->
            for task in scriptSeq
                console.log('constructor task: ' + task);
                @loadScript(task)

        constructor: () ->
            @loadScripts(document.numeric.defaultTaskList)

    new ActivityManager()
])
