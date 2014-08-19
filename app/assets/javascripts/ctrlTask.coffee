angular.module('AppOne')

# Task Controller
.controller 'TaskCtrl', ['$scope', '$routeParams', '$location', 'ActivityDriver', 'ActivityManager', ($scope, $routeParams, $location, ActivityDriver, ActivityManager ) ->
    # if no activityId specified do not proceed
    taskId = $routeParams.taskId
    if taskId == undefined || taskId == ''
        return $location.path('/')

    $scope.activityDriver = ActivityDriver

    ActivityManager.loadActivity(taskId)
    .then(
        (activity) ->
            ActivityDriver.setActivity(activity, $scope)
            $scope.currentActivity = ActivityDriver.currentActivity

            $scope.resetTimer =  () -> $scope.$broadcast('timer-start');
            $scope.$on 'timer-tick', (event, args) -> $scope.elapsedTime = args.millis
            $scope.$on 'end-of-test', (event, args) ->
                $scope.endOfTestReached = 'reached'
                $location.path('/taskSummary')

            # for options
            $scope.selectParamValue = (key, value) ->
                ActivityDriver.currentActivity.parameters[key].selectedValue = value
                ActivityDriver.newQuestion()
                ActivityDriver.clearResult()


        (status) ->
            $location.path('/')
    )

#    activity = ActivityManager.getActivity(taskId)
#    if activity == undefined
#        return $location.path('/')




    ]
