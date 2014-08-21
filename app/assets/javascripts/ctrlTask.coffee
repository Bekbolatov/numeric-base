angular.module('AppOne')

# Task Controller
.controller 'TaskCtrl', ['$scope', '$routeParams', '$location', 'ActivityDriver', 'ActivityManager', ($scope, $routeParams, $location, ActivityDriver, ActivityManager ) ->
    taskId = $routeParams.taskId
    if taskId == undefined || taskId == ''
        return $location.path('/')

    $scope.activityDriver = ActivityDriver

    ActivityManager.loadActivity(taskId)
    .then((activity) ->
        $scope.currentActivity = ActivityDriver.setActivity(activity, $scope)
        $scope.finishActivity = ActivityDriver.tryFinishActivity()
            .then((data) -> $location.path('/taskSummary'))
            .catch((status) -> console.log('could not finish activity: ' + status))
        )
    .catch((status) -> $location.path('/'))

    ]
