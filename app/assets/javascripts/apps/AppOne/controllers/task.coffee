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
    $scope.isOnNote = false
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
    $scope.toPrevQuestion = (toSave) =>
        document.getElementById('problemContainer').scrollTop = 0
        document.getElementById('optionsContainer').scrollTop = 0
        document.getElementById('prevQuestionContainer').scrollTop = 0
        $scope.isOnReviewLast = true
        $scope.isOnOptions = false
        $scope.isOnNote = false
        if toSave != undefined && toSave.note && $scope.noteToAdd != undefined
            val = $scope.noteToAdd.trim()
            if val.length > 0
                ActivityDriver.addNotePrev(val)
    $scope.toOptions = () =>
        document.getElementById('problemContainer').scrollTop = 0
        document.getElementById('optionsContainer').scrollTop = 0
        document.getElementById('prevQuestionContainer').scrollTop = 0
        $scope.optionsChanged = false
        $scope.isOnReviewLast = false
        $scope.isOnOptions = true
        $scope.isOnNote = false
    $scope.toAddNote = (options) =>
        document.getElementById('problemContainer').scrollTop = 0
        document.getElementById('optionsContainer').scrollTop = 0
        document.getElementById('prevQuestionContainer').scrollTop = 0
        $scope.optionsChanged = false
        $scope.isOnReviewLast = false
        $scope.isOnOptions = false
        $scope.isOnNote = true
        if options != undefined && options.prev
            prevNote = ActivityDriver.addedNotePrev()
            if prevNote != false
                $scope.noteToAdd = prevNote
            else
                $scope.noteToAdd = ''
            $scope.noteToAddDestinationCurrent = false
        else
            if ActivityDriver.addedNote != false
                $scope.noteToAdd = ActivityDriver.addedNote
            else
                $scope.noteToAdd = ''
            $scope.noteToAddDestinationCurrent = true
    $scope.backToActivity = (toSave) =>
        document.getElementById('problemContainer').scrollTop = 0
        document.getElementById('optionsContainer').scrollTop = 0
        document.getElementById('prevQuestionContainer').scrollTop = 0
        if $scope.optionsChanged && $scope.isOnOptions
            $scope.optionsChanged = false
            ActivityDriver.newQuestion(true)
        $scope.isOnOptions = false
        $scope.isOnReviewLast = false
        $scope.isOnNote = false
        if toSave != undefined && toSave.note && $scope.noteToAdd != undefined
            val = $scope.noteToAdd.trim()
            if val.length > 0
                ActivityDriver.addNote(val)
    $scope.selectParamValue = (paramKey, level) =>
        $scope.optionsChanged = true
        jump = ActivityDriver.selectParamValue(paramKey, level)
        if jump
            $scope.backToActivity()
    # Menu for questions
    $scope.testStar = false;

    $scope.menuShowOptions = () -> $scope.toOptions()
    $scope.menuShowOptions_has = () -> ActivityDriver.currentActivity.parameters != undefined
    $scope.menuToggleStar = () -> ActivityDriver.toggleStar()
    $scope.menuToggleStar_has = () -> ActivityDriver.toggledStar
    $scope.menuToggleStarPrev = () ->
        if $scope.hasAnswers() && !ActivityDriver.finishing
            ActivityDriver.toggleStarPrev()
        else
            false
    $scope.menuToggleStarPrev_has = () ->
        if $scope.hasAnswers() && !ActivityDriver.finishing
            ActivityDriver.toggledStarPrev()
        else
            false


    ActivityDriver.start($scope)

    ]
