angular.module('AppOne')

.controller 'TasksMarketplaceCtrl', ['$scope', '$location', 'Settings', 'Tracker', 'Marketplace', ($scope, $location, Settings, Tracker, Marketplace ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('marketplace')

    # tabs (ui)
    $scope.currentTab = 'available'

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
