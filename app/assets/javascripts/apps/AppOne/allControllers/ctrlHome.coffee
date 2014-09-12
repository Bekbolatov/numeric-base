angular.module('AppOne')

.controller 'HomeCtrl', ['$scope', '$rootScope', '$routeParams', 'Settings', 'Bookmarks', 'ActivityManager','Tracker', 'StarPracticeApi', ($scope, $rootScope, $routeParams, Settings, Bookmarks, ActivityManager, Tracker, StarPracticeApi ) ->

    setScopeVars = () ->
        Tracker.touch('home')
        $scope.settingsLoaded = true
        $scope.linkConnectShow = Settings.get('linkConnectShow')
        $scope.linkSubmitShow = Settings.get('linkSubmitShow')
        $scope.linkSettingsShow = Settings.get('linkSettingsShow')
        $scope.linkChannelsShow = Settings.get('linkChannelsShow')

    if Settings.ready
        setScopeVars()
    else
        $scope.settingsLoaded = false
        Settings.init(document.numeric.key.settings, document.numeric.defaultSettings)
        .then =>
            setScopeVars()

        .catch (t) => $scope.errorMessage = 'Application needs some local storage enabled to work.'



]
