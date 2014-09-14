angular.module('AppOne')

# Task Controller
.controller 'TaskCtrl', ['$scope', '$location', 'Settings', 'Tracker', 'ActivityDriver', 'ActivitySummary', 'StarPracticeApi', ($scope, $location, Settings, Tracker, ActivityDriver, ActivitySummary, StarPracticeApi ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('task', ActivityDriver.currentActivity.id)


    $scope.activityDriver = ActivityDriver
    $scope.currentActivity = ActivityDriver.currentActivity

    $scope.isOnOptions = false
    $scope.isOnReviewLast = false
    $scope.optionsChanged = false

    $scope.hasAnswers = () -> ActivityDriver.statsCorrect > 0 || ActivityDriver.statsWrong > 0

    $scope.finishActivity = ->
        if $scope.hasAnswers()
            ActivityDriver.tryFinishActivity()
            .then (timestamp) ->
                ActivitySummary.setCurrentItem(timestamp, '#/channel')
                $location.path('/historyItem')
            .catch (status) ->
                console.log('could not save activity: ' + status)
                $location.path('/channel')
        else
            $location.path('/channel')

    # Navigation
    $scope.toPrevQuestion = () =>
        document.getElementById('problemContainer').scrollTop = 0
        document.getElementById('optionsContainer').scrollTop = 0
        document.getElementById('prevQuestionContainer').scrollTop = 0
        $scope.isOnReviewLast = true
        $scope.isOnOptions = false
    $scope.toOptions = () =>
        document.getElementById('problemContainer').scrollTop = 0
        document.getElementById('optionsContainer').scrollTop = 0
        document.getElementById('prevQuestionContainer').scrollTop = 0
        $scope.optionsChanged = false
        $scope.isOnReviewLast = false
        $scope.isOnOptions = true
    $scope.backToActivity = () =>
        document.getElementById('problemContainer').scrollTop = 0
        document.getElementById('optionsContainer').scrollTop = 0
        document.getElementById('prevQuestionContainer').scrollTop = 0
        if $scope.optionsChanged && $scope.isOnOptions
            $scope.optionsChanged = false
            ActivityDriver.newQuestion(true)
        $scope.isOnOptions = false
        $scope.isOnReviewLast = false
    $scope.selectParamValue = (paramKey, level) =>
        $scope.optionsChanged = true
        jump = ActivityDriver.selectParamValue(paramKey, level)
        if jump
            $scope.backToActivity()
    # Menu for questions
    $scope.testStar = false;

    $scope.menuShowOptions = () -> $scope.toOptions()
    $scope.menuShowOptions_has = () -> ActivityDriver.currentActivity.parameters != undefined
    $scope.menuAddNote = () -> 1
    $scope.menuAddNote_has = () -> false
    $scope.menuToggleStar = () -> $scope.testStar = ! $scope.testStar
    $scope.menuToggleStar_has = () -> $scope.testStar


    ActivityDriver.start($scope)

    ]
