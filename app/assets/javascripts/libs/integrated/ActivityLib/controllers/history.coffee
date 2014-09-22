angular.module('ActivityLib')

.controller 'HistoryCtrl', ['$scope', '$location', 'Settings', 'ActivitySummary', 'Tracker', ($scope, $location, Settings, ActivitySummary, Tracker ) ->

    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('history')

    $scope.activitySummariesInfoAll = ActivitySummary.getAllSummaries()
    $scope.totalItems = $scope.activitySummariesInfoAll.length
    $scope.noHistory = $scope.activitySummariesInfoAll.length < 1
    $scope.littleHistory = $scope.activitySummariesInfoAll.length < Settings.get('pageSize')
    $scope.$watch(
        'activitySummariesInfoAll'
        (newValue, oldValue) ->
            $scope.noHistory = newValue.length < 1
            $scope.totalItems = newValue.length
        true)

    $scope.getPage = (start, end) =>
        $scope.activitySummariesInfo = ActivitySummary.getAllSummariesPage(start, end)
    $scope.refreshList = ->
        ActivitySummary.newFirst = $scope.startIndex
        $scope.getPage($scope.startIndex, $scope.endIndex)

    $scope.pageSize = Settings.get('pageSize')
    $scope.turnPage = (distance) ->
        if $scope.startIndex + distance < 0 || $scope.totalItems < 1
            $scope.startIndex = 0
        else if $scope.startIndex + distance >= $scope.totalItems
            $scope.startIndex = Math.floor( ($scope.totalItems - 1) / $scope.pageSize ) * $scope.pageSize
        else
            $scope.startIndex = $scope.startIndex + distance
        $scope.endIndex = Math.min($scope.startIndex + $scope.pageSize, $scope.totalItems)
        $scope.refreshList()

    $scope.startIndex = ActivitySummary.newFirst

    $scope.turnPage(0)

    $scope.navigateToItem = (timestamp) ->
        ActivitySummary.setCurrentItem(timestamp, '#/history')
        $location.path('/historyItem')


]

.controller 'HistoryItemCtrl', ['$scope', '$location', '$sce', 'Settings', 'Tracker', 'ActivitySummary', ($scope, $location, $sce, Settings, Tracker, ActivitySummary ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('historyitem', ActivitySummary.current.id)

    $scope.linkSubmitShow = Settings.get('linkSubmitShow')

    $scope.backButton = ActivitySummary.current.back
    $scope.searchAll = (value, index) -> true
    $scope.searchStarred = (value, index) -> value[5] != undefined && value[5][0]
    $scope.searchNoted = (value, index) -> (value[5] != undefined && value[5][1] != false)
    $scope.searchCorrect = (value, index) -> value[3]
    $scope.searchWrong = (value, index) -> !value[3]
    $scope.searchModel = $scope.searchAll


    ActivitySummary.getSummaryById(ActivitySummary.current.id)
    .then (data) ->
        if data == 'mismatch'
            $scope.mismatch = true
        else
            $scope.mismatch = false
            $scope.activityName = data.activityName
            $scope.timestamp = data.endTime
            # 0: question, 1: answer, 2: correct answer, 3: result, 4: time, 5: [starred, note]
            $scope.responses = ([ $sce.trustAsHtml('' + response[0]),  $sce.trustAsHtml('' + response[1]), $sce.trustAsHtml('' + response[2]), response[3], response[4], response[5] ]  for response in data.responses)

            $scope.correct = data.runningTotals.correct
            $scope.wrong = data.runningTotals.wrong
            $scope.total = data.runningTotals.correct + data.runningTotals.wrong
            $scope.totalSeconds = Math.round( (data.endTime - data.startTime) / 1000 )
            $scope.avgSeconds = Math.round(  ( (data.endTime - data.startTime) / $scope.total ) / 1000 )
        $scope.ready = true
    .catch (status) ->
        console.log(status)
        $scope.mismatch = true
        $scope.ready = true


    ]
