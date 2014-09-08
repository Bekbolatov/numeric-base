angular.module('AppOne')

.controller 'TaskListCtrl', ['$scope', '$location', '$sce', 'Settings', 'MessageDispatcher', 'ActivityManager',  'KristaQuestions', ($scope, $location, $sce, Settings, MessageDispatcher, ActivityManager, KristaQuestions ) ->
    if !Settings.ready
        $location.path('/')

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
