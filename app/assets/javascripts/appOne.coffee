angular.module 'AppOne', ['ngRoute', 'timer', 'filters']

.controller 'HomeCtrl', ['$scope', '$rootScope', '$routeParams', ($scope, $rootScope, $routeParams) ->
    $rootScope.$on 'activitiesListUpdated', (ev, data) ->
        $scope.$apply()
]

.controller 'TaskListCtrl', ['$scope', '$rootScope', 'ActivityManager', ($scope, $rootScope, ActivityManager) ->
    $scope.listOfAvailableActivities = ActivityManager.getAllActivities()
    $rootScope.$on 'activitiesListUpdated', (ev, data) ->
        $scope.$apply()
    ]

.controller 'TaskCtrl', ['$scope', '$routeParams', '$location', 'ActivityDriver', 'ActivityManager', ($scope, $routeParams, $location, ActivityDriver, ActivityManager ) ->
    taskId = $routeParams.taskId
    if taskId == undefined || taskId == '' || ActivityManager.getActivity(taskId) == undefined
        return $location.path('/')
    ActivityDriver.setTask(ActivityManager.getActivity($routeParams.taskId), $scope)

    $scope.activityDriver = ActivityDriver
    $scope.currentActivity = ActivityDriver.currentActivity

    $scope.resetTimer =  () ->
        $scope.$broadcast('timer-start');
    $scope.$on 'timer-tick', (event, args) ->
        $scope.elapsedTime = args.millis
    $scope.$on 'end-of-test', (event, args) ->
        $scope.endOfTestReached = 'reached'
        $location.path('/taskSummary')

    # confirm finish activity
    $scope.finishActivityPopup = () ->
        if navigator.notification.alert != undefined
            navigator.notification.alert('confirm', finishActivity, 'Finish activity?', ['No, go back', 'Yes, finish'])

    $scope.finishActivity = (buttonNumber) ->
        if buttonNumber == 1
            $location('/taskSummary')

    # for options
    $scope.selectParamValue = (key, value) ->
        ActivityDriver.currentActivity.parameters[key].selectedValue = value
        ActivityDriver.newQuestion()
        ActivityDriver.clearResult()
    ]

.controller 'TaskSummaryCtrl', ['$scope', '$location', 'ActivityDriver', ($scope, $location, ActivityDriver) ->
    if ActivityDriver.currentActivity == undefined
        $location.path('/')
    $scope.task = ActivityDriver.currentTask
    $scope.numeric = ActivityDriver
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
