angular.module('AppOne')

.controller 'HomeCtrl', ['$scope', '$rootScope', '$routeParams', ($scope, $rootScope, $routeParams) ->
    ]

.controller 'TaskListCtrl', ['$scope', '$rootScope', '$location', 'ActivityManager', ($scope, $rootScope, $location, ActivityManager ) ->
    $scope.tableOfAvailableActivities = ActivityManager.getInstalledActivitiesMeta()
    $scope.noActivities = (Object.keys($scope.tableOfAvailableActivities).length < 1)
    ]

# history (some reports maybe at some point somewhere)
.controller 'HistoryCtrl', ['$scope', ($scope) ->
    $scope.test = 'todo: history...'
    ]

.controller 'TestCtrl', ['$scope', '$rootScope', '$routeParams', '$http', 'ActivityManager', 'FS', ($scope, $rootScope, $routeParams, $http, ActivityManager, FS ) ->
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

    #   read write
    $scope.writeToFile = () -> FS.writeToFile('testdata.txt', 'hsellodata')
    $scope.readFromFile = () ->
        FS.readFromFile('testdata.txt')
        .then(
            (data) -> $scope.readData = data
        )

    $scope.getContents = (path) -> FS.getContents(document.numeric.url.base.fs + document.numeric.path[path])




    ]
