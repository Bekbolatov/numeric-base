angular.module('adminActivities')

.controller 'endUserProfileEdit', ['$scope', '$location', '$route', 'DeviceId', 'ServerHttp', ($scope, $location, $route, DeviceId, ServerHttp ) ->
]

.controller 'endUserProfileList', ['$scope', '$location', '$route', 'DeviceId', 'ServerHttp', ($scope, $location, $route, DeviceId, ServerHttp ) ->
    console.log("list profile")
    console.log(DeviceId.devicePublicId)

    $scope.deleteActivity = (url, id) ->
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
