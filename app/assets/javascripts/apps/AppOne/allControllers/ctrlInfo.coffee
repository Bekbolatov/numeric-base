angular.module('AppOne')

.controller 'InfoCtrl', ['$scope', '$rootScope', '$location', '$routeParams', 'Settings', 'Tracker', ($scope, $rootScope, $location, $routeParams, Settings, Tracker ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('info')
]
