angular.module('AppOne')

.controller 'TaskSummaryCtrl', ['$scope', '$location', 'ActivityDriver', 'ActivitySummary', ($scope, $location, ActivityDriver, ActivitySummary ) ->
    if ActivityDriver.currentActivity == undefined
        $location.path('/')
    $scope.task = ActivityDriver.currentTask
    $scope.numeric = ActivityDriver
    ]
