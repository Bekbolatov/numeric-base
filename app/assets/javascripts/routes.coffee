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
    .when('/task', {
        templateUrl: 'assets/task.html'
        controller: 'TaskCtrl'
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

.run(['$route', ($route) ->
  $route.reload();
])

.config(['$compileProvider', '$httpProvider', ($compileProvider, $httpProvider) ->
    $compileProvider.aHrefSanitizationWhitelist /^\s*(https?|ftp|mailto|file|tel):/
    $httpProvider.defaults.useXDomain = true
])
