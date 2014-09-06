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

.controller 'SampleQuestionCtrl', [ '$scope', '$sce', 'PersistenceManager', 'KristaQuestions', ($scope, $sce, PersistenceManager, KristaQuestions ) ->

    window.pers = PersistenceManager
    $scope.regen = (num) ->
        PersistenceManager.save('testikl', {s:1, b:'as', c: { h: 'yello'}})

        .then ->
             PersistenceManager.read('testikl')
             .then (obj) ->
                $scope.testik = obj
        .catch (t) -> console.log(t)




        $scope.showAnswer = false
        qa = KristaQuestions.generate(num)

        $scope.question = $sce.trustAsHtml('' + qa[0][0])

        if qa[0].length > 1
            $scope.choices = ($sce.trustAsHtml('' + choice) for choice in qa[0][1])
            $scope.answer = $sce.trustAsHtml('' + qa[0][1][qa[1]])
        else
            $scope.choices = undefined
            $scope.answer = $sce.trustAsHtml('' + qa[1])

    $scope.regen(4)

]
