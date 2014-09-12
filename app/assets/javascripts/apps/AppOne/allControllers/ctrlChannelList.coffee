angular.module('AppOne')

.controller 'ChannelListCtrl', ['$scope', '$location', '$sce', 'Settings', 'Tracker', 'MessageDispatcher', 'ActivityManager',  'StarPracticeApi', ($scope, $location, $sce, Settings, Tracker , MessageDispatcher, ActivityManager, StarPracticeApi ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('channellist')

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
