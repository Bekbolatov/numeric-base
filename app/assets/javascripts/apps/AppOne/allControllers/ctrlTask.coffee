angular.module('AppOne')

# Task Controller
.controller 'TaskCtrl', ['$scope', '$routeParams', '$location', 'Settings', 'ActivityDriver', 'ActivityManager', ($scope, $routeParams, $location, Settings, ActivityDriver, ActivityManager ) ->
    if !Settings.ready
        $location.path('/')

    taskId = $routeParams.taskId
    if taskId == undefined || taskId == ''
        return $location.path('/')

    $scope.activityDriver = ActivityDriver

    ActivityManager.loadActivity(taskId)
    .then((activity) ->
        $scope.currentActivity = ActivityDriver.setActivity(activity, $scope)
        $scope.finishActivity = ->
            ActivityDriver.tryFinishActivity()
            .then((data) ->
                console.log(data)
                $location.path('/historyItem/' + data + '/tasksList')
            )
            .catch((status) -> console.log('could not finish activity: ' + status))
        )
    .catch((status) -> $location.path('/'))

    ]
