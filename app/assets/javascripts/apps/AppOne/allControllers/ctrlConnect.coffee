angular.module('AppOne')

.controller 'ConnectCtrl', ['$scope', '$rootScope', '$location', '$routeParams', 'Settings', 'Tracker', 'Connections', ($scope, $rootScope, $location, $routeParams, Settings, Tracker, Connections ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('connect')

    $scope.teachers = Connections.getAll()
    $scope.noTeachers = false

]

.controller 'AddTeacherCtrl', ['$scope', '$location', 'Settings', 'Tracker', 'Connections', ($scope, $location, Settings, Tracker, Connections ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('addteacher')

    $scope.teacherId = ''
    $scope.scan = () ->
        cordova.plugins.barcodeScanner.scan(
            (result) ->
                $scope.teacherId = result.text
                console.log('scanned: ' + result.text)
            (error) ->
                $scope.error = error
                console.log('scanned-error: ' + error)
        )

    validateId = (id) -> id.length == 32
    validateName = (name) -> name.length > 1 && name.length < 30

    $scope.addTeacher = () =>
        console.log('adding')
        if validateId($scope.teacherId) && validateName($scope.teacherName)
            console.log('passed')
            Connections.add({
                    id: $scope.teacherId
                    name: $scope.teacherName
                    newItems: 0
                })
            $location.path('/connect')

]

.controller 'TeachersCtrl', ['$scope', '$location', 'Settings', 'Tracker', 'DeviceId', ($scope, $location, Settings, Tracker, DeviceId ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('teachers')
    $scope.myId = DeviceId.devicePublicId
]


.controller 'MyIdentityCtrl', ['$scope', '$location', 'Settings', 'Tracker', 'DeviceId', 'QRSignature', ($scope, $location, Settings, Tracker, DeviceId, QRSignature ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('myid')
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
