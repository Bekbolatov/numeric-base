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
    $scope.listOfAvailableActivities = ActivityManager.getAllActivities()
    $scope.removeInstalledActivity = (activityId) ->
        ActivityManager.deregisterTask(activityId)
    $rootScope.$on 'activitiesListUpdated', (ev, data) ->
        $scope.$apply()


    $scope.pageNumber = 0
    Marketplace.writeToScopePublicActivities($scope, 'publicActivities', 'errorStatus', $scope.searchTermPublic, $scope.pageNumber)
    $scope.tryGettingPublicAgain = () ->
        Marketplace.writeToScopePublicActivities($scope, 'publicActivities', 'errorStatus', $scope.searchTermPublic, $scope.pageNumber)

    ]

