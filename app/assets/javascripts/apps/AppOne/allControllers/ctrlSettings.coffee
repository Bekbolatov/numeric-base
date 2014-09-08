angular.module('AppOne')

# app settings
.controller 'SettingsCtrl', ['$scope', '$location', 'Settings', 'ActivityMeta', 'ActivityBody', 'Bookmarks', ($scope, $location, Settings, ActivityMeta, ActivityBody, Bookmarks ) ->

    if !Settings.ready
        $location.path('/')

    $scope.getAttr = (attr) -> Settings.get(attr)
    $scope.setAttr = (attr, newVal) -> Settings.set(attr, newVal)


    $scope.defaultMainServerAddress = Settings.getDefault('mainServerAddress')
    $scope.mainServerAddress = Settings.get('mainServerAddress')
    $scope.newMainServerAddress = Settings.get('mainServerAddress')

    $scope.mainServerAddress_set = () ->
        newVal = $scope.newMainServerAddress.trim().replace('http://', 'https://')
        if newVal.length == 0
            return
        if newVal[newVal.length - 1] != '/'
            newVal = newVal + '/'
        Settings.set('mainServerAddress', newVal)
        $scope.mainServerAddress = Settings.get('mainServerAddress')
        $scope.newMainServerAddress = $scope.mainServerAddress
    $scope.mainServerAddress_reset = () ->
        Settings.unset('mainServerAddress')
        $scope.mainServerAddress = Settings.get('mainServerAddress')
        $scope.newMainServerAddress = Settings.get('mainServerAddress')




    $scope.clearLocalStorage = -> window.localStorage.clear()

    ]

