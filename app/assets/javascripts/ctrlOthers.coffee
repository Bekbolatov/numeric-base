angular.module('AppOne')

.controller 'HomeCtrl', ['$scope', '$rootScope', '$routeParams', ($scope, $rootScope, $routeParams) -> ]
.controller 'InfoCtrl', ['$scope', '$rootScope', '$routeParams', ($scope, $rootScope, $routeParams) -> ]

.controller 'TaskListCtrl', ['$scope', 'ActivityManager', ($scope, ActivityManager ) ->
    $scope.tableOfAvailableActivities = ActivityManager.getInstalledActivitiesMeta()
    $scope.noActivities = (Object.keys($scope.tableOfAvailableActivities).length < 1)
    $scope.$watch(
        'tableOfAvailableActivities'
        (newValue, oldValue) ->
            $scope.noActivities = (Object.keys($scope.tableOfAvailableActivities).length < 1)
        true)
]
