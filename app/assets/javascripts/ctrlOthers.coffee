angular.module('AppOne')

.controller 'HomeCtrl', ['$scope', '$rootScope', '$routeParams', ($scope, $rootScope, $routeParams) ->
    ]

.controller 'TaskListCtrl', ['$scope', '$rootScope', '$location', 'ActivityManager', ($scope, $rootScope, $location, ActivityManager ) ->
    $scope.tableOfAvailableActivities = ActivityManager.getInstalledActivitiesMeta()
    if Object.keys($scope.tableOfAvailableActivities).length < 1
        $scope.noActivities = true
    ]

# statistics and reports
.controller 'StatsCtrl', ['$scope', ($scope) ->
    $scope.test = 'todo: stats...'
    ]

.controller 'TestCtrl', ['$scope', '$rootScope', '$routeParams', '$http', 'ActivityManager', ($scope, $rootScope, $routeParams, $http, ActivityManager ) ->
    $scope.activityManager = ActivityManager
    $scope.test = 'testt'

    $scope.showScriptsInHead = () ->
        tags = document.getElementsByTagName('script')
        $scope.scripts = []
        for tag in tags
            if tag.id != undefined && tag.id != ''
                $scope.scripts.push(tag)

    $scope.getHttpsData = () ->
             $http.get('https://www.vicinitalk.com/api/v1/post/375/?format=json')
             .then(
                (response) ->
                    console.log(response)
                    $scope.httpsdata = response.data
                (status) -> console.log('error: ' + status)
             )
    ]
