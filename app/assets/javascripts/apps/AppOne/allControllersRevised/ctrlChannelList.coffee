angular.module('AppOne')

.controller 'ChannelListCtrl', ['$scope', '$location', '$sce', 'Settings', 'Tracker', 'MessageDispatcher', 'Channels', ($scope, $location, $sce, Settings, Tracker , MessageDispatcher, Channels ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('channelList')

    # messaging
    msg = MessageDispatcher.getMessageToShow()
    if msg != undefined
        $scope.showMessage = true
        $scope.message = $sce.trustAsHtml(msg.content)
    else
        $scope.showMessage = false
        $scope.message = ''

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

    #navigate
    $scope.navigateToChannel = (id, name) ->
        Channels.setCurrentChannel(id, name)
        $location.path('/channel')
]
