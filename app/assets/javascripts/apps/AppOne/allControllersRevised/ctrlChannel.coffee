angular.module('AppOne')

.controller 'ChannelCtrl', ['$scope', '$routeParams', '$location', '$sce', 'Settings', 'Tracker', 'MessageDispatcher', 'Channels', 'ActivityDriver',  'StarPracticeApi', ($scope, $routeParams, $location, $sce, Settings, Tracker , MessageDispatcher, Channels, ActivityDriver, StarPracticeApi ) ->
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




    getActivities = (searchTerm)->
        $scope.loadingList = true
        Channels
        .getChannelActivities($scope.startIndex, $scope.pageSize, searchTerm)
        .then (response) =>
            $scope.errorStatus = undefined
            $scope.availableActivities = response.data.activities
#            if $scope.availableActivities.length < 1 && $scope.startIndex >= Settings.get('historyPageSize')
#                $scope.startIndex = $scope.startIndex - Settings.get('historyPageSize')
#                return getActivities()
            $scope.endIndex = $scope.startIndex + $scope.availableActivities.length
            $scope.littleHistory = ( $scope.availableActivities.length < Settings.get('historyPageSize') && $scope.startIndex == 0 )
        .catch (status) ->
            console.log('Could not get list of activity metas from server, status: ' + status)
            $scope.errorStatus = status
        .then -> $scope.loadingList = false

    getActivities($scope.searchTerm)
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
    $scope.pageSize = Settings.get('historyPageSize')

    $scope.turnPage = (distance) ->
        if $scope.startIndex + distance <= 0
            $scope.startIndex = 0
        else if distance < 0
            $scope.startIndex = $scope.startIndex - $scope.pageSize
        else
            $scope.startIndex = $scope.startIndex + $scope.pageSize
        $scope.endIndex = $scope.startIndex
        $scope.tryGettingAgain()

    $scope.turnPage(0)


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
