angular.module('AppOne')

.config(['$routeProvider', ($routeProvider) ->
    $routeProvider
    .when('/', {
        templateUrl: '/assets/templates/oneApp/home.html'
        controller: 'HomeCtrl'
    })
    .when('/info', {
        templateUrl: '/assets/templates/oneApp/info.html'
        controller: 'InfoCtrl'
    })
    .when('/channelList', {
        templateUrl: '/assets/templates/activityLib/channelList.html'
        controller: 'ChannelListCtrl'
    })
    .when('/channel', {
        templateUrl: '/assets/templates/activityLib/channel.html'
        controller: 'ChannelCtrl'
    })
    .when('/tags', {
        templateUrl: '/assets/templates/oneApp/tags.html'
        controller: 'TagsCtrl'
    })
    .when('/task', {
        templateUrl: '/assets/templates/activityLib/task.html'
        controller: 'TaskCtrl'
    })
    .when('/history', {
        templateUrl: '/assets/templates/activityLib/history.html'
        controller: 'HistoryCtrl'
    })
    .when('/historyItem', {
        templateUrl: '/assets/templates/activityLib/historyItem.html'
        controller: 'HistoryItemCtrl'
    })

    # Settings
    .when('/settings', {
        templateUrl: '/assets/templates/oneApp/settings.html'
        controller: 'SettingsCtrl'
    })

    # Connect
    .when('/connect', {
        templateUrl: '/assets/templates/oneApp/connect.html'
        controller: 'ConnectCtrl'
    })
    .when('/myIdentity', {
        templateUrl: '/assets/templates/oneApp/myIdentity.html'
        controller: 'MyIdentityCtrl'
    })
    .when('/teachers', {
        templateUrl: '/assets/templates/oneApp/teachers.html'
        controller: 'TeachersCtrl'
    })
    .when('/addTeacher', {
        templateUrl: '/assets/templates/oneApp/addTeacher.html'
        controller: 'AddTeacherCtrl'
    })

    # for testing only
    .when('/test', {
        templateUrl: '/assets/templates/oneApp/test.html'
        controller: 'TestCtrl'
    })
    .when('/sampleQuestion', {
        templateUrl: '/assets/templates/oneApp/sampleQuestion.html'
        controller: 'SampleQuestionCtrl'
    })

    .otherwise({
        redirectTo: '/'
    })
])


.run(['$route', '$location', 'TaskCtrlState', ($route, $location, TaskCtrlState ) ->
  $route.reload()
  document.addEventListener(
    "backbutton"
    =>
        currentPath = $location.path()
        if typeof currentPath != 'undefined' && currentPath.substr(0,5) == "/task"
            return TaskCtrlState.backButton()
        if typeof currentPath != 'undefined' && currentPath.substr(0,12) == "/historyItem"
            $location.path('/history')
        else
            $location.path('/')
        $route.reload()
    false
    )
  document.addEventListener(
    "menubutton"
    =>
        currentPath = $location.path()
        console.log('menu button, current: ' + currentPath )
        if typeof currentPath != 'undefined' && currentPath.substr(0,5) == "/task"
            return
        if typeof currentPath != 'undefined' && currentPath.substr(0,9) == "/settings"
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

