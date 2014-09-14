angular.module('AppOne')

.controller 'TagsCtrl', ['$scope', '$routeParams', '$location', '$sce', 'Settings', 'Tracker', 'Channels', 'ActivityDriver',  'StarPracticeApi', ($scope, $routeParams, $location, $sce, Settings, Tracker, Channels, ActivityDriver, StarPracticeApi ) ->
    if !Settings.ready
        return $location.path('/')
    else
        Tracker.touch('tags')

]
