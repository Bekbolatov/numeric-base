angular.module('AppOne')

.controller 'TaskSummaryCtrlOld', ['$scope', '$location', 'ActivityDriver', 'ActivitySummary', ($scope, $location, ActivityDriver, ActivitySummary ) ->
    if ActivityDriver.currentActivity == undefined
        $location.path('/')
    $scope.task = ActivityDriver.currentTask
    $scope.numeric = ActivityDriver
    ]

# history (some reports maybe at some point somewhere)
.controller 'HistoryCtrl', ['$scope', 'ActivitySummary', ($scope, ActivitySummary ) ->
    $scope.activitySummariesInfo = ActivitySummary.getAllSummaries()
    $scope.noHistory = $scope.activitySummariesInfo.length < 1
    $scope.$watch(
        'activitySummariesInfo'
        (newValue, oldValue) ->
            $scope.noHistory = newValue.length < 1
        true)
]

.controller 'TaskSummaryCtrl', ['$scope', '$routeParams', '$location', 'ActivitySummary', ($scope, $routeParams, $location, ActivitySummary ) ->
    summaryId = $routeParams.summaryId
    if summaryId == undefined || summaryId == ''
        return $location.path('/')

    $scope.summaryId = summaryId
    console.log('in ctrl')
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
