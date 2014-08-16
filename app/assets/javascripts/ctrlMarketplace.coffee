angular.module('AppOne')

# managing Activities (aka Tasks),getting new, removing old etc
.controller 'TasksManagingCtrl', ['$scope', ($scope) -> ]

.controller 'TasksMarketplaceCtrl', ['$scope', '$rootScope', '$http', 'ActivityBody', 'ActivityMeta', 'Marketplace', 'ActivityManager', ($scope, $rootScope, $http, ActivityBody, ActivityMeta, Marketplace, ActivityManager ) ->
    $scope.test = 'todo: tasks marketplace'
    $scope.currentTab = 'installed'
    $scope.isTabSelected = (tab) ->
        $scope.currentTab == tab
    $scope.tabSelected = (tab) ->
        $scope.currentTab = tab

    # Utility methods
    $scope.isInstalled = (activityId) ->
        ActivityBody.get(activityId) != undefined
    $scope.getInfo = (activityId) ->
        $scope.info = 'todo'

    # Removing/Uninstalling activities (tab: installed")
    ## population
    $scope.listOfAvailableActivities = ActivityBody.all()


    #$rootScope.$on 'activitiesListUpdated', (ev, data) ->
    #    $scope.$apply()



    ## actual removal
    $scope.confirmRemoveId = undefined
    $scope.uninstallActivity = (activityId) ->
        ActivityBody.unloadActivity(activityId)

    # Adding/Installing public activities (tab: public)
    ## population
    $scope.pageNumber = 0
    Marketplace.writeToScopePublicActivities($scope, 'publicActivities', 'errorStatus', $scope.searchTermPublic, $scope.pageNumber)
    $scope.tryGettingPublicAgain = () ->
        Marketplace.writeToScopePublicActivities($scope, 'publicActivities', 'errorStatus', $scope.searchTermPublic, $scope.pageNumber)
    ## actual install
    $scope.installNewActivity = (activityId) ->
        ActivityBody.loadActivity(activityId)

    $scope.getMeta = (activityId) ->
        ActivityMeta.get(activityId)
        .then(
            (data) -> $scope.detailsFor = data
            (status) -> $scope.detailsFor = undefined
        )



    $scope.open = () ->
        modalInstance = $modal.open({
          templateUrl: 'assets/taskDetail2.html'
          controller: ($scope, $modalInstance) ->
                          $scope.ok = () -> $modalInstance.close('close')
                          $scope.cancel = () -> $modalInstance.dismiss('cancel')
        })
        modalInstance.result
        .then(
            () -> $log.info('Modal closed at: ' + new Date())
            () -> $log.info('Modal dismissed at: ' + new Date())
        )
    ]

.controller 'ModalInstanceCtrl', ['$scope', '$modalInstance', ($scope, $modalInstance) ->
    $scope.ok = () -> $modalInstance.close('close')
    $scope.cancel = () -> $modalInstance.dismiss('cancel')
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