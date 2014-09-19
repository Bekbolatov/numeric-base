angular.module('AppOne')

.controller 'ChannelCtrl', ['$scope', '$routeParams', '$location', '$sce', 'Settings', 'Tracker', 'Channels', 'ActivityDriver',  'StarPracticeApi', ($scope, $routeParams, $location, $sce, Settings, Tracker, Channels, ActivityDriver, StarPracticeApi ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('channel', Channels.current.id)

    $scope.toggleDetailsId = (activityId) ->
        if $scope.detailsId == activityId
            $scope.detailsId = undefined
            return
        $scope.detailsId = activityId

    $scope.channelName = Channels.current.name
    $scope.Channels = Channels

    getActivities = (searchTerm)->
        $scope.loadingList = true
        $scope.errorStatus = false
        $scope.availableActivities = Channels.getChannelActivitiesFromCache($scope.startIndex, $scope.pageSize, searchTerm)
        if $scope.availableActivities.activities != undefined
            $scope.endIndex = $scope.startIndex + $scope.availableActivities.activities.length
            $scope.littleHistory = ( $scope.availableActivities.activities.length < Settings.get('pageSize') && $scope.startIndex == 0 )
        else
            $scope.endIndex = 0
            $scope.littleHistory = true
        Channels
        .getChannelActivities($scope.startIndex, $scope.pageSize, searchTerm)
        .then (response) =>
            $scope.errorStatus = undefined
            $scope.availableActivities.activities = response.data.activities
#            if $scope.availableActivities.length < 1 && $scope.startIndex >= Settings.get('pageSize')
#                $scope.startIndex = $scope.startIndex - Settings.get('pageSize')
#                return getActivities()
            if $scope.availableActivities.activities != undefined
                $scope.endIndex = $scope.startIndex + $scope.availableActivities.activities.length
                $scope.littleHistory = ( $scope.availableActivities.activities.length < Settings.get('pageSize') && $scope.startIndex == 0 )
            else
                $scope.endIndex = 0
                $scope.littleHistory = true
        .catch (status) ->
            console.log('Could not get list of activity metas from server, status: ' + status)
            if $scope.availableActivities.activities == undefined || $scope.availableActivities.activities.length < 1
                $scope.errorStatus = status
        .then -> $scope.loadingList = false
    $scope.tryGettingAgain = () -> getActivities($scope.searchTerm)
    $scope.searchPublic = () ->
        term = $scope.searchTerm
        if term == undefined
            return
        term = term.trim()
        if term.length < 3
            return
        getActivities(term)

    $scope.littleHistory = true
    $scope.startIndex = Channels.newFirst
    $scope.pageSize = Settings.get('pageSize')
    $scope.endIndex = $scope.startIndex + $scope.pageSize

    $scope.turnPage = (distance) ->
        if $scope.startIndex + distance <= 0
            if $scope.startIndex == 0
                return 1
            else
                $scope.startIndex = 0
        else if distance < 0
            $scope.startIndex = $scope.startIndex - $scope.pageSize
        else if $scope.endIndex < $scope.startIndex + $scope.pageSize
            return 1
        else
            $scope.startIndex = $scope.startIndex + $scope.pageSize
        $scope.endIndex = $scope.startIndex + $scope.pageSize
        $scope.tryGettingAgain()

    $scope.tryGettingAgain()


    $scope.tryStartActivity = (activityId, version) ->
        $scope.startingActivityId = activityId
        ActivityDriver.trySetActivity(activityId, version)
        .then (activity) ->
            $location.path('/task')
        .catch (status) ->
            console.log(status)
            $scope.startingActivityId = undefined
            alert('could not start activity')




]
