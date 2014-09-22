angular.module('ActivityLib')

.controller 'ChannelListCtrl', ['$scope', '$location', '$sce', 'Settings', 'Tracker', 'Channels', ($scope, $location, $sce, Settings, Tracker, Channels ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('channelList')

    # channels
    $scope.start = 0
    $scope.size = 10

    getChannels = (searchTerm)->
        $scope.loadingList = true
        Channels.getChannels($scope.start, $scope.size, searchTerm)
        .then (response) ->
            $scope.errorStatus = undefined
            $scope.channels = response.data.channels
        .catch (status) ->
            console.log('Could not get list of channels from server, status: ' + status)
            $scope.errorStatus = status
        .then -> $scope.loadingList = false

    getChannels($scope.searchTerm)
    $scope.tryGettingAgain = () -> getChannels($scope.searchTerm)

    $scope.searchPublic = () ->
        term = $scope.searchTerm
        if term == undefined
            return
        term = term.trim()
        if term.length < 3
            return
        getChannels(term)

    $scope.navigateToChannel = (id, name) -> Channels.navigateToChannel(id, name, '#/channelList')

]
