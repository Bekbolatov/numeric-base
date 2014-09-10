angular.module('AppOne')

.controller 'TaskListCtrl', ['$scope', '$location', '$sce', 'Settings', 'Tracker', 'MessageDispatcher', 'ActivityManager',  'KristaQuestions', ($scope, $location, $sce, Settings, Tracker , MessageDispatcher, ActivityManager, KristaQuestions ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('taskslist')

    msg = MessageDispatcher.getMessageToShow()
    if msg != undefined
        $scope.showMessage = true
        $scope.message = $sce.trustAsHtml(msg.content)
    else
        $scope.showMessage = false
        $scope.message = ''

    $scope.tableOfAvailableActivities = ActivityManager.getInstalledActivitiesMeta()
    $scope.noActivities = (Object.keys($scope.tableOfAvailableActivities).length < 1)
    $scope.$watch(
        'tableOfAvailableActivities'
        (newValue, oldValue) ->
            $scope.noActivities = (Object.keys($scope.tableOfAvailableActivities).length < 1)
        true)
]
