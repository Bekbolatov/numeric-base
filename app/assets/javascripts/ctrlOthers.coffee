angular.module('AppOne')

.controller 'HomeCtrl', ['$scope', '$rootScope', '$routeParams', ($scope, $rootScope, $routeParams) ->
    ]

.controller 'TaskListCtrl', ['$scope', '$rootScope', '$location', 'ActivityManager', ($scope, $rootScope, $location, ActivityManager ) ->
    $scope.tableOfAvailableActivities = ActivityManager.getInstalledActivitiesMeta()
    if Object.keys($scope.tableOfAvailableActivities).length < 1
        $location.path('/tasksMarketplace')
    ]

.controller 'TaskSummaryCtrl', ['$scope', '$location', 'ActivityDriver', ($scope, $location, ActivityDriver ) ->
    if ActivityDriver.currentActivity == undefined
        $location.path('/')
    $scope.task = ActivityDriver.currentTask
    $scope.numeric = ActivityDriver
    ]


# statistics and reports
.controller 'StatsCtrl', ['$scope', ($scope) ->
    $scope.test = 'todo: stats...'
    ]

.controller 'TestCtrl', ['$scope', '$rootScope', '$routeParams', 'ActivityManager', ($scope, $rootScope, $routeParams, ActivityManager ) ->
    $scope.activityManager = ActivityManager
    $scope.test = 'testt'
    ]
