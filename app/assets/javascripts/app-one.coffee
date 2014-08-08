angular.module('AppOne', ['ngRoute', 'numeric'])

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
    .when('/newtask/:taskType', {
        templateUrl: 'assets/taskOptions.html'
        controller: 'TaskOptionsCtrl'
    })
    .when('/task/:taskAnswerType', {
        templateUrl: 'assets/numeric.html'
        controller: 'NumericCtrl'
    })
    .when('/stats', {
        template: '<h1> {{ test }} </h1>'
        controller: 'StatsCtrl'
    })
    .when('/social', {
        template: '<h1> {{ test }} </h1>'
        controller: 'SocialCtrl'
    })
    .when('/settings', {
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

.controller('TaskOptionsCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.numericApp = NumericApp
    NumericApp.currentTaskType = $routeParams.taskType
    $scope.task = NumericApp.getCurrentTask()
    $scope.selectParamValue = (key, value) ->
        console.log('Set key ' + key + ' to value ' + value)
        #NumericApp.taskTypes[NumericApp.currentTaskType].parameters[key].selectedValue = value
        NumericApp.getCurrentTask().parameters[key].selectedValue = value
])

.controller('NumericCtrl', ['$scope', '$routeParams', 'NumericData', 'NumericApp', ($scope, $routeParams, NumericData, NumericApp ) ->
    $scope.numericApp = NumericApp
    $scope.numeric = NumericData
    NumericApp.currentTaskAnswerType = $routeParams.taskAnswerType
    NumericData.setTaskEngine(NumericApp.getCurrentTask())
])

.controller('StatsCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.test = '...stats...'
    $scope.numericApp = NumericApp
    $rootScope.$on('NumericAppUpdated', (ev, newNumericApp) ->
            $scope.$apply()
    )
])

.controller('SocialCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.test = '...social...'
    $scope.numericApp = NumericApp
    $rootScope.$on('NumericAppUpdated', (ev, newNumericApp) ->
            $scope.$apply()
    )
])

.controller('SettingsCtrl', ['$scope', '$rootScope', '$routeParams', 'NumericApp', ($scope, $rootScope, $routeParams, NumericApp ) ->
    $scope.test = '...settings...'
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


