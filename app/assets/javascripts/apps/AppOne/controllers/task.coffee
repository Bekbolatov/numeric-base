angular.module('AppOne')

# Task Controller
.controller 'TaskCtrl', ['$scope', '$location', 'Settings', 'Tracker', 'ActivityDriver', 'ActivitySummary', 'StarPracticeApi', ($scope, $location, Settings, Tracker, ActivityDriver, ActivitySummary, StarPracticeApi ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('task', ActivityDriver.currentActivity.id)


    $scope.finishActivity = ->
        ActivityDriver.tryFinishActivity()
        .then (timestamp) ->
            ActivitySummary.setCurrentItem(timestamp, '#/channel')
            $location.path('/historyItem')
        .catch (status) ->
            console.log('could not save activity: ' + status)
            $location.path('/channel')


    $scope.activityDriver = ActivityDriver
    $scope.currentActivity = ActivityDriver.currentActivity

    ActivityDriver.start($scope)

    # activity options

    $scope.toOptions = () =>
        $scope.optionsChanged = false
        document.getElementById('optionsContainer').scrollTop = 0
        document.getElementById('problemContainer').scrollTop = 0
        $scope.isFlipped = true


    $scope.isFlipped = false
    $scope.optionsChanged = false
    $scope.backToActivity = () =>
        console.log(document.getElementById('problemContainer').scrollTop)
        document.getElementById('problemContainer').scrollTop = 0
        if $scope.optionsChanged && $scope.isFlipped
            $scope.isFlipped = false
            $scope.optionsChanged = false
            ActivityDriver.newQuestion(true)

    $scope.selectParamValue = (paramKey, level) =>
        $scope.optionsChanged = true
        jump = ActivityDriver.selectParamValue(paramKey, level)
        if jump
            $scope.backToActivity()
            console.log(document.getElementById('problemContainer').scrollTop)



    ]
