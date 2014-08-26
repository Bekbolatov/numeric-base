angular.module('AppOne')

# app settings
.controller 'SettingsCtrl', ['$scope', 'Settings', 'ActivityMeta', 'ActivityBody', 'Bookmarks', ($scope, Settings, ActivityMeta, ActivityBody, Bookmarks ) ->

    $scope.getAttr = (attr) -> Settings.get(attr)
    $scope.setAttr = (attr, newVal) -> Settings.set(attr, newVal)

    $scope.clearLocalStorage = -> window.localStorage.clear()

    ]

