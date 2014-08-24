angular.module('AppOne')

.controller 'TaskSummaryCtrlOld', ['$scope', '$location', 'ActivityDriver', 'ActivitySummary', ($scope, $location, ActivityDriver, ActivitySummary ) ->
    if ActivityDriver.currentActivity == undefined
        $location.path('/')
    $scope.task = ActivityDriver.currentTask
    $scope.numeric = ActivityDriver
    ]

# history (some reports maybe at some point somewhere)
.controller 'HistoryCtrl', ['$scope', 'Settings', 'ActivitySummary', ($scope, Settings, ActivitySummary ) ->
    $scope.activitySummariesInfoAll = ActivitySummary.getAllSummaries()
    $scope.totalItems = $scope.activitySummariesInfoAll.length
    $scope.noHistory = $scope.activitySummariesInfoAll.length < 1
    $scope.$watch(
        'activitySummariesInfoAll'
        (newValue, oldValue) ->
            $scope.noHistory = newValue.length < 1
            $scope.totalItems = newValue.length
        true)

    $scope.getPage = (start, end) =>
        $scope.activitySummariesInfo = ActivitySummary.getAllSummariesPage(start, end)
    $scope.refreshList = -> $scope.getPage($scope.startIndex, $scope.endIndex)

    $scope.pageSize = Settings.getHistoryPageSize()
    $scope.turnPage = (distance) ->
        if $scope.startIndex + distance < 0 || $scope.totalItems < 1
            $scope.startIndex = 0
        else if $scope.startIndex + distance >= $scope.totalItems
            $scope.startIndex = Math.floor( ($scope.totalItems - 1) / $scope.pageSize ) * $scope.pageSize
        else
            $scope.startIndex = $scope.startIndex + distance
        $scope.endIndex = Math.min($scope.startIndex + $scope.pageSize, $scope.totalItems)
        $scope.refreshList()

    $scope.startIndex = -1
    $scope.turnPage(0)



]

.controller 'TaskSummaryCtrl', ['$scope', '$routeParams', '$location', 'ActivitySummary', ($scope, $routeParams, $location, ActivitySummary ) ->
    summaryId = $routeParams.summaryId
    if summaryId == undefined || summaryId == ''
        return $location.path('/')

    ActivitySummary.getSummaryById(summaryId)
    .then(
        (data) ->
            if data == 'mismatch'
                $scope.mismatch = true
            else
                $scope.mismatch = false
                $scope.activityName = data.activityName
                $scope.responses = data.responses

                $scope.correct = data.runningTotals.correct
                $scope.wrong = data.runningTotals.wrong
                $scope.total = data.runningTotals.correct + data.runningTotals.wrong
                $scope.totalSeconds = Math.round( (data.endTime - data.startTime) / 1000 )
                $scope.avgSeconds = Math.round(  ( (data.endTime - data.startTime) / $scope.total ) / 1000 )
            $scope.ready = true
    )
    .catch((status) ->
        console.log(status)
        $scope.mismatch = true
        $scope.ready = true
    )


    ]
