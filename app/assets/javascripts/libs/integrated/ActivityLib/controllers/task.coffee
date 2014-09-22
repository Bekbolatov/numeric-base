angular.module('ActivityLib')

# Task Controller
.controller 'TaskCtrl', ['$scope', '$rootScope', '$location', 'Settings', 'Tracker', 'TaskCtrlState', 'ActivityDriver', 'ActivitySummary', 'StarPracticeApi', ($scope, $rootScope, $location, Settings, Tracker, TaskCtrlState, ActivityDriver, ActivitySummary, StarPracticeApi ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('task', ActivityDriver.currentActivity.id)


    $scope.activityDriver = ActivityDriver
    $scope.currentActivity = ActivityDriver.currentActivity

    $scope.state = TaskCtrlState.setScope($scope)

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

    $rootScope.$on('end-of-test', $scope.finishActivity)

    # Navigation
    $scope.toPrevQuestion = (toSave) =>
        document.getElementById('problemContainer').scrollTop = 0
        document.getElementById('optionsContainer').scrollTop = 0
        document.getElementById('prevQuestionContainer').scrollTop = 0
        $scope.state.isOnReviewLast = true
        $scope.state.isOnOptions = false
        $scope.state.isOnNote = false
        $scope.state = TaskCtrlState
        if toSave != undefined && toSave.note && $scope.noteToAdd != undefined
            val = $scope.noteToAdd.trim()
            if val.length > 0
                ActivityDriver.addNotePrev(val)
            else
                ActivityDriver.addNotePrev(false)
        true
    $scope.toOptions = () =>
        document.getElementById('problemContainer').scrollTop = 0
        document.getElementById('optionsContainer').scrollTop = 0
        document.getElementById('prevQuestionContainer').scrollTop = 0
        $scope.state.optionsChanged = false
        $scope.state.isOnReviewLast = false
        $scope.state.isOnOptions = true
        $scope.state.isOnNote = false

    $scope.toExitWindow = () =>
        $scope.state.optionsChanged = false
        $scope.state.isOnReviewLast = false
        $scope.state.isOnOptions = false
        $scope.state.isOnNote = false
        $scope.state.isOnExit = true

    $scope.toAddNote = (options) =>
        document.getElementById('problemContainer').scrollTop = 0
        document.getElementById('optionsContainer').scrollTop = 0
        document.getElementById('prevQuestionContainer').scrollTop = 0
        $scope.state.optionsChanged = false
        $scope.state.isOnReviewLast = false
        $scope.state.isOnOptions = false
        $scope.state.isOnNote = true
        if options != undefined && options.prev
            prevNote = ActivityDriver.addedNotePrev()
            if prevNote != false
                $scope.noteToAdd = prevNote
            else
                $scope.noteToAdd = ''
            $scope.state.noteToAddDestinationCurrent = false
        else
            if ActivityDriver.addedNote != false
                $scope.noteToAdd = ActivityDriver.addedNote
            else
                $scope.noteToAdd = ''
            $scope.state.noteToAddDestinationCurrent = true
        $scope.noteToAddOrig = $scope.noteToAdd
    $scope.noteHasChanged = () -> $scope.noteToAdd != $scope.noteToAddOrig
    $scope.backToActivity = (toSave) =>
        document.getElementById('problemContainer').scrollTop = 0
        document.getElementById('optionsContainer').scrollTop = 0
        document.getElementById('prevQuestionContainer').scrollTop = 0
        if $scope.state.optionsChanged && $scope.state.isOnOptions
            $scope.state.optionsChanged = false
            ActivityDriver.newQuestion(true)
        $scope.state.isOnOptions = false
        $scope.state.isOnReviewLast = false
        $scope.state.isOnNote = false
        $scope.state.isOnExit = false
        if toSave != undefined && toSave.note
            if $scope.noteToAdd != undefined && (val = $scope.noteToAdd.trim() ).length > 0
                ActivityDriver.addNote(val)
            else
                ActivityDriver.addNote(false)
        true

    $scope.selectParamValue = (paramKey, level) =>
        $scope.state.optionsChanged = true
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
