angular.module('AppOne')

.controller 'AddTeacherCtrl', ['$scope', ($scope ) ->
    $scope.scan = () ->
        cordova.plugins.barcodeScanner.scan(
            (result) -> $scope.teacherId = result.text
            (error) -> $scope.error = error
        )
]

.controller 'TeachersCtrl', ['$scope', 'DeviceId', ($scope, DeviceId ) ->
    $scope.myId = DeviceId.devicePublicId
]


.controller 'MyIdentityCtrl', ['$scope', 'DeviceId', ($scope, DeviceId ) ->
    $scope.myId = DeviceId.devicePublicId
]
