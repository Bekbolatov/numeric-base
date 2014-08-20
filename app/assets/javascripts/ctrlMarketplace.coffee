angular.module('AppOne')

# managing Activities (aka Tasks),getting new, removing old etc
.controller 'TasksManagingCtrl', ['$scope', ($scope) -> ]

.controller 'TasksMarketplaceCtrl', ['$scope', 'Marketplace', 'ActivityManager', ($scope, Marketplace, ActivityManager ) ->
    # tabs (ui)
    if Object.keys(ActivityManager.getInstalledActivitiesMeta()).length < 1
        $scope.currentTab = 'available'
    else
        $scope.currentTab = 'installed'
    $scope.isTabSelected = (tab) -> $scope.currentTab == tab
    $scope.tabSelected = (tab) -> $scope.currentTab = tab

    # see more details
    $scope.toggleDetailsId = (activityId) ->
        if $scope.confirmRemoveId != undefined
            $scope.confirmRemoveId = undefined
            return
        if $scope.confirmAddId != undefined
            $scope.confirmAddId = undefined
            return


        if $scope.detailsId != activityId
            $scope.detailsId = activityId
        else
            $scope.detailsId = undefined

    # install/uninstall
    $scope.mapOfAvailableActivities = ActivityManager.getInstalledActivitiesMeta()
    $scope.isInstalled = (activityId) -> ActivityManager.isInstalled(activityId)
    $scope.somethingInstalled = -> Object.keys(ActivityManager.getInstalledActivitiesMeta()).length > 0
    $scope.uninstallActivity = (activityId) -> ActivityManager.uninstallActivity(activityId)
    $scope.installNewActivity = (activityId) ->
        $scope.loadingActivity = activityId
        ActivityManager.installActivity(activityId)
        .then(
            () => $scope.loadingActivity = undefined
        )


    # search/listing public activities
    # still a lot of work needs to be done here, in conjunction with the server work
    $scope.pageNumber = 0

    writeToScopePublicActivities = (searchTerm)->
        $scope.loadingList = true
        Marketplace.getPublicActivitiesMeta($scope.pageNumber, searchTerm)
            .then(
                (response) ->
                    $scope.publicActivitiesMeta = response.data.activities
                    $scope.loadingList = false
                (status) ->
                    console.log('could not get list of activity metas from server, status: ' + status)
                    $scope.errorStatus = status
                    $scope.loadingList = false
            )
    writeToScopePublicActivities($scope.searchTermPublic)
    $scope.tryGettingPublicAgain = () -> writeToScopePublicActivities($scope.searchTermPublic)

    $scope.searchPublic = () ->
        term = $scope.searchTermPublic
        if term == undefined
            return
        term = term.trim()
        if term.length < 3
            return
        writeToScopePublicActivities(term)

    ]
