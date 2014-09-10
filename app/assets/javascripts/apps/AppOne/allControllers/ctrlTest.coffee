angular.module('AppOne')

.controller 'TestCtrl', ['$scope', '$rootScope', '$routeParams', '$http', 'md5', 'FS', ($scope, $rootScope, $routeParams, $http, md5, FS ) ->

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
    $scope.getContentsRaw = (path) -> FS.getContents(path)

    $scope.getFromLocal = (key) -> $scope.localData = window.localStorage.getItem(key)
    $scope.testmd5 = (txt) -> $scope.localData = md5.createHash(txt)

]
