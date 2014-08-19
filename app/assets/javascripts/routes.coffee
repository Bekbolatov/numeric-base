angular.module('AppOne')

.config(['$routeProvider', ($routeProvider) ->
    $routeProvider
    .when('/', {
        templateUrl: 'assets/home.html'
        controller: 'HomeCtrl'
    })
    .when('/tasksList', {
        templateUrl: 'assets/tasksList.html'
        controller: 'TaskListCtrl'
    })
    .when('/task/:taskId', {
        templateUrl: 'assets/task.html'
        controller: 'TaskCtrl'
    })
    .when('/taskSummary', {
        templateUrl: 'assets/taskSummary.html'
        controller: 'TaskSummaryCtrl'
    })

    # Activity Marketplace Hookups
    .when('/tasksManaging', {
        templateUrl: 'assets/tasksManaging.html'
        controller: 'TasksManagingCtrl'
    })
    .when('/tasksMarketplace', {
        templateUrl: 'assets/tasksMarketplace.html'
        controller: 'TasksMarketplaceCtrl'
    })
    .when('/taskDetail/:taskId', {
        templateUrl: 'assets/taskDetail.html'
        controller: 'TaskDetailCtrl'
    })

    # Stats/Reports
    .when('/stats', {
        template: '<h1> {{ test }} </h1>'
        controller: 'StatsCtrl'
    })
    # Settings
    .when('/settings', {
        templateUrl: 'assets/settings.html'
        controller: 'SettingsCtrl'
    })
    .when('/settings/:section', {
        templateUrl: 'assets/settings.html'
        controller: 'SettingsCtrl'
    })

    # for testing only
    .when('/test', {
        templateUrl: 'assets/test.html'
        controller: 'TestCtrl'
    })

    .otherwise({
        redirectTo: '/'
    })
])


.run(['$route', '$location', 'ActivityDriver', ($route, $location, ActivityDriver ) ->
  $route.reload()
  document.addEventListener(
    "backbutton"
    =>
        currentPath = $location.path()
        console.log('back button, current: ' + currentPath )
        if currentPath != undefined && (currentPath.substr(0,6) == "/task/" || currentPath.substr(0,12) == "/taskSummary")
            return
        $location.path('/')
        $route.reload()
    false
    )
  document.addEventListener(
    "menubutton"
    =>
        currentPath = $location.path()
        console.log('menu button, current: ' + currentPath )
        if currentPath != undefined && (currentPath.substr(0,6) == "/task/" || currentPath.substr(0,12) == "/taskSummary")
            return
        if currentPath != undefined && currentPath.substr(0,9) == "/settings"
            return
        $location.path('/settings')
        $route.reload()
    false
    )
])

.config(['$compileProvider', '$httpProvider', ($compileProvider, $httpProvider) ->
    $compileProvider.aHrefSanitizationWhitelist /^\s*(https?|cdvfile|ftp|mailto|file|tel):/
    $httpProvider.defaults.useXDomain = true
])

