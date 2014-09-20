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

.controller 'channelList', ['$scope', ($scope) ->
    console.log("list channels")
]
