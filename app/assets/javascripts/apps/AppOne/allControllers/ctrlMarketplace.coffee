angular.module('AppOne')

.controller 'TasksMarketplaceCtrl', ['$scope', '$location', 'Settings', 'Tracker', 'Marketplace', 'ActivityManager', ($scope, $location, Settings, Tracker, Marketplace, ActivityManager ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('marketplace')

    # tabs (ui)
    if Object.keys(ActivityManager.getInstalledActivitiesMeta()).length < 1
        $scope.currentTab = 'available'
    else
        $scope.currentTab = 'installed'
    $scope.selectTab = (tab) ->
        $scope.currentTab = tab
        $scope.confirmRemoveId = undefined
        $scope.confirmAddId = undefined
        $scope.detailsId = undefined

    # see more details
    $scope.toggleDetailsId = (activityId) ->
        if $scope.confirmRemoveId != undefined
            $scope.confirmRemoveId = undefined
            return
        if $scope.confirmAddId != undefined
            $scope.confirmAddId = undefined
            return
        if $scope.confirmUpdateId != undefined
            $scope.confirmUpdateId = undefined
            return
        if $scope.detailsId == activityId
            $scope.detailsId = undefined
            return
        $scope.detailsId = activityId

    # install/uninstall
    $scope.mapOfAvailableActivities = ActivityManager.getInstalledActivitiesMeta()
    $scope.somethingInstalled = -> Object.keys(ActivityManager.getInstalledActivitiesMeta()).length > 0

    $scope.isInstalled = (activityId) -> ActivityManager.isInstalled(activityId)
    $scope.needsUpdate = (activityId, meta) ->
        if !meta.version
            return false
        installedMeta = ActivityManager.getInstalledActivityMeta(activityId)
        if !installedMeta.version
            return true
        meta.version > installedMeta.version

    $scope.uninstallActivity = (activityId) -> ActivityManager.uninstallActivity(activityId)
    $scope.installNewActivity = (activityId, meta) ->
        $scope.loadingActivity = activityId
        ActivityManager.installActivity(activityId, meta)
        .catch((status) => console.log('error installing: ' + status))
        .then(-> $scope.loadingActivity = undefined)
    $scope.updateActivity = (activityId, meta) ->
        $scope.loadingActivity = activityId
        ActivityManager.updateActivity(activityId, meta)
        .catch((status) => console.log('error updating: ' + status))
        .then(-> $scope.loadingActivity = undefined)


    # search/listing public activities
    # still a lot of work needs to be done here, in conjunction with the server work
    $scope.pageNumber = 0

    getPublicActivities = (searchTerm)->
        $scope.loadingList = true
        Marketplace
        .getPublicActivitiesMeta($scope.pageNumber, searchTerm)
        .then((response) ->
            $scope.errorStatus = undefined
            $scope.availableActivitiesMeta = response.data.activities
        )
        .catch((status) ->
            console.log('Could not get list of activity metas from server, status: ' + status)
            $scope.errorStatus = status
            Marketplace
            .getLocalActivitiesMeta()
            .then((response) -> $scope.availableActivitiesMeta = response.data.activities)
            .catch((status) -> console.log('error getting local available activities list: ' + status)))
        .then(-> $scope.loadingList = false)

    getPublicActivities($scope.searchTermPublic)
    $scope.tryGettingPublicAgain = () -> getPublicActivities($scope.searchTermPublic)

    $scope.searchPublic = () ->
        term = $scope.searchTermPublic
        if term == undefined
            return
        term = term.trim()
        if term.length < 3
            return
        getPublicActivities(term)

    ]
