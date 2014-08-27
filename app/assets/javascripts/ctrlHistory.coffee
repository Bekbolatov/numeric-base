angular.module('AppOne')

.controller 'HistoryCtrl', ['$scope', '$routeParams', 'Settings', 'ActivitySummary', ($scope, $routeParams, Settings, ActivitySummary ) ->
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
    $scope.refreshList = ->
        ActivitySummary.setFirstIndex($scope.startIndex)
        $scope.getPage($scope.startIndex, $scope.endIndex)

    $scope.pageSize = Settings.get('historyPageSize')
    $scope.turnPage = (distance) ->
        if $scope.startIndex + distance < 0 || $scope.totalItems < 1
            $scope.startIndex = 0
        else if $scope.startIndex + distance >= $scope.totalItems
            $scope.startIndex = Math.floor( ($scope.totalItems - 1) / $scope.pageSize ) * $scope.pageSize
        else
            $scope.startIndex = $scope.startIndex + distance
        $scope.endIndex = Math.min($scope.startIndex + $scope.pageSize, $scope.totalItems)
        $scope.refreshList()

    containedItem = $routeParams.containedItem
    if containedItem != undefined && containedItem == 'continue'
        $scope.startIndex = ActivitySummary.getFirstIndex()
    else
        $scope.startIndex = -1

    $scope.turnPage(0)

]

.controller 'HistoryItemCtrl', ['$scope', '$routeParams', '$location', 'ActivitySummary', ($scope, $routeParams, $location, ActivitySummary ) ->
    itemId = $routeParams.itemId
    if itemId == undefined || itemId == '' || itemId == 'test'
        return $location.path('/')

    backButton = $routeParams.backButton
    if backButton != undefined && backButton != '' && backButton != 'test'
        $scope.backButton = '#/tasksList'
    else
        $scope.backButton = '#/history/continue'

    ActivitySummary.getSummaryById(itemId)
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
        $location.path('/')
    )


    ]
