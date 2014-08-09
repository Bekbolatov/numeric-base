angular.module('AppOne', ['ngRoute', 'numeric', 'timer'])

angular.module('AppOne')
.config(['$routeProvider', ($routeProvider) ->
    $routeProvider
    .when('/home', {
        templateUrl: 'assets/home.html'
        controller: 'HomeCtrl'
    })
    .when('/listtasks', {
        templateUrl: 'assets/tasksList.html'
        controller: 'TaskListCtrl'
    })
    .when('/tasksManaging', {
        templateUrl: 'assets/tasksManaging.html'
        controller: 'TasksManagingCtrl'
    })
    .when('/tasksMarketplace', {
        templateUrl: 'assets/tasksMarketplace.html'
        controller: 'TasksMarketplaceCtrl'
    })
    .when('/newtask/:taskType', {
        templateUrl: 'assets/taskOptions.html'
        controller: 'TaskOptionsCtrl'
    })
    .when('/task/:taskAnswerType', {
        templateUrl: 'assets/task.html'
        controller: 'TaskCtrl'
    })
    .when('/report', {
        templateUrl: 'assets/taskReport.html'
        controller: 'ReportCtrl'
    })

    .when('/stats', {
        template: '<h1> {{ test }} </h1>'
        controller: 'StatsCtrl'
    })
    .when('/social', {
        template: '<h1> {{ test }} </h1>'
        controller: 'SocialCtrl'
    })
    .when('/settings/:section', {
        template: '<h1> {{ test }} </h1>'
        controller: 'SettingsCtrl'
    })
    .otherwise({
        redirectTo: '/home'
    })
])


.run(['$route', ($route) ->
  $route.reload();
])

.config(['$compileProvider', ($compileProvider) ->
    $compileProvider.aHrefSanitizationWhitelist /^\s*(https?|ftp|mailto|file|tel):/
])

.controller('HomeCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.numericApp = NumericApp
])

.controller('TaskListCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.numericApp = NumericApp
    $rootScope.$on('NumericAppUpdated', (ev, newNumericApp) ->
            $scope.$apply()
    )
])

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

.controller('TaskOptionsCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.numericApp = NumericApp
    NumericApp.currentTaskType = $routeParams.taskType
    $scope.task = NumericApp.getCurrentTask()
    $scope.selectParamValue = (key, value) ->
        console.log('Set key ' + key + ' to value ' + value)
        #NumericApp.taskTypes[NumericApp.currentTaskType].parameters[key].selectedValue = value
        NumericApp.getCurrentTask().parameters[key].selectedValue = value
])

.controller('TaskCtrl', ['$scope', '$routeParams', '$location', 'NumericData', 'NumericApp', ($scope, $routeParams, $location, NumericData, NumericApp ) ->
    $scope.numericApp = NumericApp
    $scope.numeric = NumericData
    NumericApp.currentTaskAnswerType = $routeParams.taskAnswerType
    NumericData.setTaskEngine(NumericApp.getCurrentTask(), $scope)
    $scope.resetTimer =  () ->
        $scope.$broadcast('timer-start');
    $scope.$on 'timer-tick', (event, args) ->
        $scope.elapsedTime = args.millis
    $scope.$on 'end-of-test', (event, args) ->
        $scope.endOfTestReached = 'reached'
        $location.path('/report')
])

.controller('ReportCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericData', 'NumericApp', ($scope, $rootScope, $routeParams, NumericData, NumericApp ) ->
    $scope.task = NumericApp.getCurrentTask()
    $scope.numericApp = NumericApp
    $scope.numeric = NumericData
    $rootScope.$on('NumericAppUpdated', (ev, newNumericApp) ->
            $scope.$apply()
    )
])

.controller('StatsCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.test = 'todo: stats...'
    $scope.numericApp = NumericApp
    $rootScope.$on('NumericAppUpdated', (ev, newNumericApp) ->
            $scope.$apply()
    )
])

.controller('SocialCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.test = 'todo: social...'
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


.factory("NumericApp", ['$rootScope', ($rootScope) ->
    class NumericApp
        taskTypes: {}
        getTask: (taskName) ->
            @taskTypes[taskName]
        getCurrentTask: () ->
            @getTask(@currentTaskType)

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


