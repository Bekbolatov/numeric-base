angular.module('AppOne')

# Task Controller
.controller 'TaskCtrl', ['$scope', '$routeParams', '$location', 'ActivityDriver', 'ActivityManager', ($scope, $routeParams, $location, ActivityDriver, ActivityManager ) ->

    # set Activity on ActivityDriver
    taskId = $routeParams.taskId
    if taskId == undefined || taskId == ''
        return $location.path('/')
    activity = ActivityManager.getActivity(taskId)
    if activity == undefined
        return $location.path('/')
    ActivityDriver.setActivity(activity, $scope)

    $scope.activityDriver = ActivityDriver
    $scope.currentActivity = ActivityDriver.currentActivity

    $scope.resetTimer =  () -> $scope.$broadcast('timer-start');
    $scope.$on 'timer-tick', (event, args) ->
        $scope.elapsedTime = args.millis

    $scope.$on 'end-of-test', (event, args) ->
        $scope.endOfTestReached = 'reached'
        $location.path('/taskSummary')


    # for options
    $scope.selectParamValue = (key, value) ->
        ActivityDriver.currentActivity.parameters[key].selectedValue = value
        ActivityDriver.newQuestion()
        ActivityDriver.clearResult()
    ]
