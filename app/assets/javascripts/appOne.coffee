angular.module('AppOne', ['ngRoute', 'timer', 'numeric', 'filters'])

.controller('HomeCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.numericApp = NumericApp
])

.controller('TaskListCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.numericApp = NumericApp
    $rootScope.$on('NumericAppUpdated', (ev, newNumericApp) ->
            $scope.$apply()
    )
])

.controller('TaskCtrl', ['$scope', '$routeParams', '$location', '$sce', 'NumericData', 'NumericApp', ($scope, $routeParams, $location, $sce, NumericData, NumericApp ) ->
    if ($routeParams.taskType != undefined && $routeParams.taskType != '' && NumericApp.hasTaskType($routeParams.taskType))
        NumericApp.setTaskType($routeParams.taskType)
        NumericData.setTask(NumericApp.currentTask, $scope)
    else if (NumericData.currentTask != undefined && NumericData.currentTask.name != undefined)
        NumericData.newQuestion()
        NumericData.clearResult()
    else
        $location.path('/')

    $scope.numericApp = NumericApp
    $scope.numeric = NumericData
    $scope.task = NumericApp.currentTask

    $scope.resetTimer =  () ->
        $scope.$broadcast('timer-start');
    $scope.$on 'timer-tick', (event, args) ->
        $scope.elapsedTime = args.millis
    $scope.$on 'end-of-test', (event, args) ->
        $scope.endOfTestReached = 'reached'
        $location.path('/taskSummary')
    #for options
    $scope.selectParamValue = (key, value) ->
        NumericApp.currentTask.parameters[key].selectedValue = value
        NumericData.newQuestion()
        NumericData.clearResult()


    $scope.stringOne = $sce.trustAsHtml('hello<i>sd</i>')
])

.controller('TaskSummaryCtrl', ['$scope', '$rootScope', '$routeParams', '$location', 'NumericData', 'NumericApp', ($scope, $rootScope, $routeParams, $location, NumericData, NumericApp ) ->
    $scope.task = NumericApp.currentTask
    $scope.numericApp = NumericApp
    $scope.numeric = NumericData
    if NumericData.statsCorrect == 0 && NumericData.statsWrong == 0
        $location.path('/')
    $rootScope.$on('NumericAppUpdated', (ev, newNumericApp) ->
            $scope.$apply()
    )
])

# managing Activities (aka Tasks),getting new, removing old etc
.controller('TasksManagingCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.numericApp = NumericApp
])

.controller('TasksMarketplaceCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.numericApp = NumericApp
    $rootScope.$on('NumericAppUpdated', (ev, newNumericApp) ->
            $scope.$apply()
    )
    $scope.test = 'todo: tasks marketplace'
])

# statistics and reports
.controller('StatsCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.test = 'todo: stats...'
    $scope.numericApp = NumericApp
    $rootScope.$on('NumericAppUpdated', (ev, newNumericApp) ->
            $scope.$apply()
    )
])

.controller('SettingsCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.test = 'todo: settings...'
    $scope.numericApp = NumericApp
    $rootScope.$on('NumericAppUpdated', (ev, newNumericApp) ->
            $scope.$apply()
    )
])


.controller('TestCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.numericApp = NumericApp
    $scope.test = 'testt'
])


.factory("NumericApp", ['$rootScope', ($rootScope) ->
    class NumericApp
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
                    $rootScope.$broadcast('NumericAppUpdated', @)
            newScript.src = url
            document.getElementsByTagName('head')[0].appendChild(newScript);


        loadScripts: (scriptSeq) ->
            for task in scriptSeq
                console.log('constructor task: ' + task);
                @loadScript(task)

        constructor: () ->
            @loadScripts(document.numeric.defaultTaskList)

    new NumericApp()
])

.directive('myCustomer', ->
    {
        restrict: 'AEC'
        replace: 'true'
        template: '<div>Name: {{ numeric.operationLabel }} and {{ color }}</div>'
        link: (scope, elem, attrs) ->
            scope.$watch( \
                'color' \
                , (newValue, oldValue) ->
                    if (newValue)
                        console.log("I see a data change!");
                        elem.css 'background-color', scope.color
                , false)
            elem.bind 'click', ->
                elem.css 'background-color', scope.color
#                scope.$apply ->
#                    scope.color = "blue";
            elem.bind 'mouseover', ->
                elem.css 'cursor', 'pointer'
    }
)


