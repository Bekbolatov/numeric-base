angular.module('AppOne')

# Task Controller
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
