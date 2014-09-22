angular.module('adminActivities')

.controller 'channelAdd', ['$scope', ($scope) ->
    console.log("add channel")
]

.controller 'channelDetail', ['$scope', ($scope) ->
    console.log("detail channel")
    $scope.showEditName = false
    $scope.toggleEditName = () ->
        if $scope.showEditName
            # save...
            $scope.showEditName = false
        else
            $scope.showEditName = true
]

.controller 'channelList', ['$scope', 'ServerHttp', ($scope, ServerHttp) ->
    console.log("list channels")

    $scope.deleteChannel = (url, id) ->
        protocol = location.protocol
        server = location.hostname
        port = location.port
        if port.length > 0
            port = ":" + port
        servername = protocol + "//" + server + port
        ServerHttp.delete(servername + url, id)
        .then (response) -> console.log('ok')
        .catch (status) -> console.log(status)
        .then (r) ->
            window.location.reload()
]
