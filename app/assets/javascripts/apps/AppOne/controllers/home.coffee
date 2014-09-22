angular.module('AppOne')

.controller 'HomeCtrl', ['$scope', '$sce', 'Settings','Tracker', 'StarPracticeApi', 'MessageDispatcher', 'Channels', 'ActivitySummary', 'Tags', ($scope, $sce, Settings, Tracker, StarPracticeApi, MessageDispatcher, Channels, ActivitySummary, Tags ) ->

    setScopeVars = () ->
        Tracker.touch('home')
        $scope.settingsLoaded = true

        msg = MessageDispatcher.getMessageToShow()
        if msg != undefined
            $scope.showMessage = true
            $scope.message = $sce.trustAsHtml(msg.content)
        else
            $scope.showMessage = false
            $scope.message = ''

        $scope.navigateToTagsOrChannel = (id, name) ->
            if Tags.hasTags()
                Tags.navigateToTags()
            else
                if id == undefined || name == undefined
                    id = Settings.get('defaultChannel')
                    name = 'Public'
                Channels.navigateToChannel(id, name, '#/')

        $scope.hasHistory = ActivitySummary.hasHistory()
        $scope.title = Settings.get('title')

    if Settings.ready
        setScopeVars()
    else
        $scope.settingsLoaded = false
        Settings.init(document.numeric.key.settings, document.numeric.defaultSettings)
        .then => setScopeVars()
        .catch (t) => $scope.errorMessage = 'Application needs some local storage enabled to work.'



]
