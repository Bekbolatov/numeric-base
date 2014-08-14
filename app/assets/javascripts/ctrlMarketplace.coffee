angular.module('AppOne')

# managing Activities (aka Tasks),getting new, removing old etc
.controller 'TasksManagingCtrl', ['$scope', ($scope) -> ]

.controller 'TasksMarketplaceCtrl', ['$scope', '$rootScope', '$http', 'ActivityManager', 'Marketplace', ($scope, $rootScope, $http, ActivityManager, Marketplace ) ->
    $scope.test = 'todo: tasks marketplace'
    $scope.currentTab = 'installed'
    $scope.isTabSelected = (tab) ->
        $scope.currentTab == tab
    $scope.tabSelected = (tab) ->
        $scope.currentTab = tab

    # Utility methods
    $scope.isInstalled = (activityId) ->
        ActivityManager.getActivity(activityId) != undefined
    $scope.getInfo = (activityId) ->
        $scope.info = 'todo'

    # Removing/Uninstalling activities (tab: installed")
    ## population
    $scope.listOfAvailableActivities = ActivityManager.getAllActivities()
    $rootScope.$on 'activitiesListUpdated', (ev, data) ->
        $scope.$apply()
    ## actual removal
    $scope.confirmRemoveId = undefined
    $scope.uninstallActivity = (activityId) ->
        ActivityManager.deregisterTask(activityId)

    # Adding/Installing public activities (tab: public)
    ## population
    $scope.pageNumber = 0
    Marketplace.writeToScopePublicActivities($scope, 'publicActivities', 'errorStatus', $scope.searchTermPublic, $scope.pageNumber)
    $scope.tryGettingPublicAgain = () ->
        Marketplace.writeToScopePublicActivities($scope, 'publicActivities', 'errorStatus', $scope.searchTermPublic, $scope.pageNumber)
    ## actual install
    $scope.installNewActivity = (activityId) ->
        ActivityManager.installActivity(activityId)

    ]

.controller 'TaskDetailCtrl', ['$scope', '$routeParams', '$location', 'ActivityMeta', ($scope, $routeParams, $location, ActivityMeta ) ->
    activityId = $routeParams.taskId
    if activityId == undefined || activityId == ''
        $scope.noSuchTask = ''
        return

    ActivityMeta.get(activityId).then( \
        (data) ->
            $scope.activityMeta = data
        (status) ->
            $scope.noSuchTask = activityId
        )
    ]