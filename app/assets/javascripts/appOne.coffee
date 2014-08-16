angular.module 'AppOne', ['ngRoute', 'timer', 'filters']

.controller 'HomeCtrl', ['$scope', '$rootScope', '$routeParams', ($scope, $rootScope, $routeParams) ->
    $rootScope.$on 'activitiesListUpdated', (ev, data) ->
        $scope.$apply()
]

.controller 'TaskListCtrl', ['$scope', '$rootScope', 'ActivityManager', ($scope, $rootScope, ActivityManager ) ->
    $scope.listOfAvailableActivities = ActivityManager.getAllActivities()
    $rootScope.$on 'activitiesListUpdated', (ev, data) ->
        $scope.$apply()
    ]

.controller 'TaskCtrl', ['$scope', '$routeParams', '$location', 'ActivityDriver', 'ActivityManager', ($scope, $routeParams, $location, ActivityDriver, ActivityManager ) ->
    taskId = $routeParams.taskId
    if taskId == undefined || taskId == ''
        return $location.path('/')
    activity = ActivityManager.getActivity(taskId)
    if activity == undefined
        return $location.path('/')
    ActivityDriver.setTask(activity, $scope)

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

.controller 'TaskSummaryCtrl', ['$scope', '$location', 'ActivityDriver', ($scope, $location, ActivityDriver ) ->
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
.controller 'SettingsCtrl', ['$scope', 'ActivityMeta', 'ActivityBody', ($scope, ActivityMeta, ActivityBody ) ->
    $scope.clearLocalStorage = -> ActivityMeta.clearLocalStorage()


    $scope.downloadToFile1 = ->
        console.log('remove')
        ActivityBody.unloadActivity('com.sparkydots.numeric.tasks.t.basic_math')
        ActivityBody.unloadActivity('com.sparkydots.numeric.tasks.t.multiple_choice')

    $scope.downloadToFile2 = ->
        console.log('downloadtofile2')
        ActivityBody.loadActivity('com.sparkydots.numeric.tasks.t.basic_math')
        .then((result) -> console.log('result: ' + result))
        .catch((status) -> console.log('error status: ' + status))

    $scope.downloadToFile3 = ->
        console.log('downloadtofile3')
        ActivityBody.loadActivity('com.sparkydots.numeric.tasks.t.multiple_choice')
        .then((result) -> console.log('result: ' + result))
        .catch((status) -> console.log('error status: ' + status))

    $scope.downloadJs = ->
        console.log('multiple_choiced')
        ActivityBody.loadActivity('com.sparkydots.numeric.tasks.t.multiple_choiced')
        .then((result) -> console.log('result: ' + result))
        .catch((status) -> console.log('error status: ' + status))
    ]


.controller 'TestCtrl', ['$scope', '$rootScope', '$routeParams', 'ActivityManager', ($scope, $rootScope, $routeParams, ActivityManager ) ->
    $scope.activityManager = ActivityManager
    $scope.test = 'testt'
    ]
