angular.module 'AppOne', ['ngRoute', 'timer', 'filters']

.controller 'HomeCtrl', ['$scope', '$rootScope', '$routeParams', ($scope, $rootScope, $routeParams) ->
    $rootScope.$on 'activitiesListUpdated', (ev, data) ->
        $scope.$apply()
]

.controller 'TaskListCtrl', ['$scope', '$rootScope', 'ActivityManager', ($scope, $rootScope, ActivityManager ) ->
    $scope.listOfAvailableActivities = ActivityManager.getAllActivities()
    $rootScope.$on 'activitiesListUpdated', (ev, data) ->
        $scope.$apply()
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
