angular.module('adminActivities')

.controller 'activityAdd', ['$scope', ($scope) ->
    console.log("add activity")
]

.controller 'activityEdit', ['$scope', ($scope) ->
    console.log("edit activity")
]

.controller 'activityList', ['$scope', '$location', '$route', 'DeviceId', 'ServerHttp', ($scope, $location, $route, DeviceId, ServerHttp ) ->
    console.log("list activities")
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