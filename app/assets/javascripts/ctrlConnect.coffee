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


.controller 'MyIdentityCtrl', ['$scope', 'DeviceId', 'QRSignature', ($scope, DeviceId, QRSignature ) ->
    $scope.myId = DeviceId.devicePublicId
    $scope.myId_p1 = DeviceId.devicePublicId.substring(0,16)
    $scope.myId_p2 = DeviceId.devicePublicId.substring(16)

    $scope.size = 8

    $scope.showCode = () ->
        codeEl = QRSignature.encode(DeviceId.devicePublicId, $scope.size)
        element = document.getElementById("qrcode")
        if element.lastChild
            element.replaceChild(codeEl, element.lastChild)
        else
            element.appendChild(codeEl)
        1

    $scope.smaller = () ->
        $scope.size = Math.max($scope.size - 1, 5)
        $scope.showCode()

    $scope.bigger = () ->
        $scope.size = Math.min($scope.size + 1, 10)
        $scope.showCode()

    $scope.showCode()

]
