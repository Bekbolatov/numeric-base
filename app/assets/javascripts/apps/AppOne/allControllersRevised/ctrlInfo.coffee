angular.module('AppOne')

.controller 'InfoCtrl', ['$scope', '$rootScope', '$location', '$routeParams', 'Settings', 'Tracker', 'StarPracticeApi', ($scope, $rootScope, $location, $routeParams, Settings, Tracker, StarPracticeApi ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('info')
]
