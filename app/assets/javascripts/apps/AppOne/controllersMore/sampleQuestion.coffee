angular.module('AppOne')

.controller 'SampleQuestionCtrl', [ '$scope', '$sce', 'PersistenceManager', 'KristaQuestions', ($scope, $sce, PersistenceManager, KristaQuestions ) ->

    $scope.browserGood = typeof navigator.webkitPersistentStorage != 'undefined'
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
