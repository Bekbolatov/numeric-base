angular.module('AppOne')

.controller 'InfoCtrl', ['$scope', '$location', 'Settings', 'Tracker', ($scope, $location, Settings, Tracker ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('info')
]
