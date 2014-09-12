angular.module('AppOne')

# Task Controller
.controller 'TaskCtrl', ['$scope', '$routeParams', '$location', 'Settings', 'Tracker', 'ActivityDriver', 'ActivityManager', 'StarPracticeApi', ($scope, $routeParams, $location, Settings, Tracker, ActivityDriver, ActivityManager, StarPracticeApi ) ->
    if !Settings.ready
        return $location.path('/')

    taskId = $routeParams.taskId
    if taskId == undefined || taskId == ''
        return $location.path('/')
    else
        Tracker.touch('task', taskId)

    $scope.activityDriver = ActivityDriver

    ActivityManager.loadActivity(taskId)
    .then((activity) ->
        $scope.currentActivity = ActivityDriver.setActivity(activity, $scope)
        $scope.finishActivity = ->
            ActivityDriver.tryFinishActivity()
            .then (data) ->
                console.log(data)
                $location.path('/historyItem/' + data + '/tasksList')
            .catch (status) ->
                console.log('could not save activity: ' + status)
                $location.path('/')
        )
    .catch((status) -> $location.path('/'))

    ]
