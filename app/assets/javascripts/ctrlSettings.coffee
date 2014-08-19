angular.module('AppOne')

# app settings
.controller 'SettingsCtrl', ['$scope', 'ActivityMeta', 'ActivityBody', 'Bookmarks', ($scope, ActivityMeta, ActivityBody, Bookmarks ) ->

    $scope.clearLocalStorage = -> window.localStorage.clear()

    $scope.uninstallAllActivities = ->
        console.log('clear')
        Bookmarks.clear()


    $scope.downloadToFile1 = ->
        console.log('remove')
        ActivityBody.unloadActivity('com.sparkydots.numeric.tasks.t.basic_math')
        ActivityBody.unloadActivity('com.sparkydots.numeric.tasks.t.multiple_choice')



    $scope.downloadToFile3 = ->
        console.log('downloadtofile3')
        ActivityBody.loadActivity('com.sparkydots.numeric.tasks.t.multiple_choice')
        .then((result) -> console.log('result: ' + result))
        .catch((status) -> console.log('error status: ' + status))

    $scope.downloadJs = ->
        console.log('multiple_choiced')
        ActivityBody.loadActivity('com.sparkydots.numeric.tasks.t.multiple_choiced')
        .then((result) -> console.log('result: ' + result))
        .catch((status) -> console.log('error status: ' + status))
    ]

