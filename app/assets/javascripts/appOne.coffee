angular.module 'AppOne', ['ngRoute', 'timer', 'filters']

.controller 'HomeCtrl', ['$scope', '$rootScope', '$routeParams', ($scope, $rootScope, $routeParams) ->
    $rootScope.$on 'activitiesListUpdated', (ev, data) ->
        $scope.$apply()
]

.controller 'TaskListCtrl', ['$scope', '$rootScope', 'ActivityManager', ($scope, $rootScope, ActivityManager) ->
    $scope.listOfAvailableActivities = ActivityManager.taskTypes
    $rootScope.$on 'activitiesListUpdated', (ev, data) ->
        $scope.$apply()
    ]

.controller 'TaskCtrl', ['$scope', '$routeParams', '$location', 'ActivityDriver', 'ActivityManager', ($scope, $routeParams, $location, ActivityDriver, ActivityManager ) ->
    if $routeParams.taskType == undefined || $routeParams.taskType == '' || !ActivityManager.hasTaskType($routeParams.taskType)
        return $location.path('/')
    ActivityManager.setTaskType($routeParams.taskType)
    ActivityDriver.setTask(ActivityManager.currentTask, $scope)

    $scope.activityDriver = ActivityDriver
    $scope.currentActivity = ActivityDriver.currentActivity

    $scope.resetTimer =  () ->
        $scope.$broadcast('timer-start');
    $scope.$on 'timer-tick', (event, args) ->
        $scope.elapsedTime = args.millis
    $scope.$on 'end-of-test', (event, args) ->
        $scope.endOfTestReached = 'reached'
        $location.path('/taskSummary')
    #for options
    $scope.selectParamValue = (key, value) ->
        ActivityDriver.currentActivity.parameters[key].selectedValue = value
        ActivityDriver.newQuestion()
        ActivityDriver.clearResult()
    ]

.controller 'TaskSummaryCtrl', ['$scope', '$location', 'ActivityDriver', 'ActivityManager', ($scope, $location, ActivityDriver, ActivityManager) ->
    $scope.task = ActivityManager.currentTask
    $scope.activityManager = ActivityManager
    $scope.numeric = ActivityDriver
    if ActivityDriver.currentActivity == undefined
        $location.path('/')
    ]

# managing Activities (aka Tasks),getting new, removing old etc
.controller 'TasksManagingCtrl', ['$scope', ($scope) -> ]

.controller 'TasksMarketplaceCtrl', ['$scope', ($scope) ->
    $scope.test = 'todo: tasks marketplace'
    ]

# statistics and reports
.controller 'StatsCtrl', ['$scope', ($scope) ->
    $scope.test = 'todo: stats...'
    ]
# app settings
.controller 'SettingsCtrl', ['$scope', ($scope) ->
    $scope.test = 'todo: settings...'
    ]

.controller 'TestCtrl', ['$scope', '$rootScope', '$routeParams', 'ActivityManager', ($scope, $rootScope, $routeParams, ActivityManager ) ->
    $scope.activityManager = ActivityManager
    $scope.test = 'testt'
    ]
