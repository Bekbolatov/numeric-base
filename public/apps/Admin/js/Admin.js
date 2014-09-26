var e, _initLocal;

_initLocal = function(d) {
  var n;
  if (d.numeric === void 0) {
    console.log('wrong init order...');
    return;
  }
  n = d.numeric;
  n.appGroup = 'com.sparkydots.apps';
  n.appVersion = 1;
  n.appName = 'Admin';
  n.key.settings = 'numeric' + n.appName + 'Settings';
  n.key.deviceId = 'numeric' + n.appName + 'DeviceId';
  n.key.currentActivitySummary = 'numeric' + n.appName + 'CurrentActivitySummary';
  n.key.storedActivitySummaries = 'numeric' + n.appName + 'StoredActivitySummaries';
  n.key.messages = 'numeric' + n.appName + 'Messages';
  n.key.channelActivities = 'numeric' + n.appName + 'ChannelActivitiesCache';
  n.url.base.numeric = 'numericdata/';
  n.url.base.fs = 'numericdata/' + n.appName + '/';
  n.path.touch = 'touch';
  n.path.channels = 'channels';
  n.path.list = 'activity/list';
  n.path.activity = 'activity/';
  n.path.body = 'activity/body/';
  n.path.result = 'result/';
  if (n.defaultSettings === void 0) {
    n.defaultSettings === {};
  }
  n.defaultSettings.defaultChannel = 'public.1000';
  n.defaultSettings.stringTitle = n.appName;
  n.defaultSettings.stringActivities = 'Activities';
  n.defaultSettings.stringHistory = 'History';
  n.defaultSettings.stringHistoryItem = 'Activity Summary';
  n.defaultSettings.showTabPractice = false;
  n.defaultSettings.showTabHistory = false;
  n.defaultSettings.showSettings = true;
  return n.customTabs = [
    {
      page: 'activities',
      text: 'Activities'
    }, {
      page: 'channels',
      text: 'Channels'
    }, {
      page: 'endUserProfiles',
      text: 'EndUserProfiles'
    }
  ];
};

_initLocal(document);

try {
  (function(w) {
    var port, protocol, server, servername;
    protocol = location.protocol;
    server = location.hostname;
    port = location.port;
    if (port.length > 0) {
      port = ":" + port;
    }
    servername = protocol + "//" + server + port;
    w.document.numeric.url.base.chrome = w.document.numeric.url.base.chrome.replace("SERVERNAME", servername);
    if (server === 'localhost' && port === ':9000') {
      w.document.numeric.url.base.chrome = "filesystem:http://localhost:9000/temporary/";
      w.document.numeric.defaultSettings.mainServerAddress = "http://localhost:9000/activityServer/data/";
      return w.document.numeric.defaultSettings.showSettings = true;
    }
  })(this);
} catch (_error) {
  e = _error;
  console.log(e);
}

angular.module('Admin', ['ngRoute', 'ngMd5', 'timer', 'ModulePersistence', 'ModuleSettings', 'ModuleMessage', 'BaseLib', 'ModuleIdentity', 'ModuleCommunication', 'ModuleDataPack', 'ModuleDataUtilities', 'ActivityLib']);


angular.module('Admin').controller('ActivitiesCtrl', [
  '$scope', '$location', '$route', '$sce', 'Settings', 'Application', 'ServerHttp', function($scope, $location, $route, $sce, Settings, Application, ServerHttp) {
    $scope.showHtmlData = false;
    ServerHttp.get('/activityServer/admin/activity?startIndex=0&size=100').then(function(response) {
      return $scope.activities = response.data.activities;
    });
    $scope.editForm = function(activityId) {
      $scope.showHtmlData = true;
      return ServerHttp.get("/activityServer/admin/activity/" + activityId).then(function(response) {
        return $scope.htmlData = $sce.trustAsHtml(response.data);
      })["catch"](function(status) {
        console.log(status);
        return $scope.showHtmlData = false;
      });
    };
    $scope.saveForm = function() {
      var form;
      form = angular.element(document.querySelector('#serverForm'));
      console.log(form);
      window.rr = form;
      $scope.showHtmlData = false;
      return $scope.htmlData = '';
    };
    $scope.backButton = function() {
      if ($scope.showHtmlData === true) {
        $scope.showHtmlData = false;
        return $scope.htmlData = '';
      } else {
        return $location.path('/');
      }
    };
    return $scope.deleteActivity = function(url, id) {
      var port, protocol, server, servername;
      protocol = location.protocol;
      server = location.hostname;
      port = location.port;
      if (port.length > 0) {
        port = ":" + port;
      }
      servername = protocol + "//" + server + port;
      return ServerHttp["delete"](servername + url, id).then(function(response) {
        return console.log('ok');
      })["catch"](function(status) {
        return console.log(status);
      }).then(function(r) {
        return window.location.reload();
      });
    };
  }
]);

angular.module('Admin').controller('ApplicationCtrl', [
  '$scope', '$location', '$route', 'Settings', 'Application', function($scope, $location, $route, Settings, Application) {
    var initApplication;
    initApplication = function() {
      $location.path('/home');
      return $route.reload();
    };
    if (Settings.ready) {
      return initApplication();
    } else {
      $scope.settingsLoaded = false;
      return Settings.init(document.numeric.key.settings, document.numeric.defaultSettings).then((function(_this) {
        return function() {
          return initApplication();
        };
      })(this))["catch"]((function(_this) {
        return function(t) {
          return $scope.errorMessage = 'Application needs some local storage enabled to work.';
        };
      })(this));
    }
  }
]);

angular.module('Admin').controller('ChannelsCtrl', [
  '$scope', '$location', '$sce', 'Settings', 'Application', 'ServerHttp', function($scope, $location, $sce, Settings, Application, ServerHttp) {
    return ServerHttp.get('/activityServer/admin/channel?startIndex=0&size=100').then(function(response) {
      return $scope.channels = response.data.channels;
    });
  }
]);

angular.module('Admin').controller('EndUserProfilesCtrl', [
  '$scope', '$location', '$sce', 'Settings', 'Application', 'ServerHttp', function($scope, $location, $sce, Settings, Application, ServerHttp) {
    return ServerHttp.get('/activityServer/admin/profile?startIndex=0&size=100').then(function(response) {
      return $scope.endUserProfiles = response.data.endUserProfiles;
    });
  }
]);

angular.module('Admin').controller('activityAdd', [
  '$scope', function($scope) {
    return console.log("add activity");
  }
]).controller('activityEdit', [
  '$scope', function($scope) {
    return console.log("edit activity");
  }
]).controller('activityList', [
  '$scope', '$location', '$route', 'DeviceId', 'ServerHttp', function($scope, $location, $route, DeviceId, ServerHttp) {
    console.log("list activities");
    console.log(DeviceId.devicePublicId);
    return $scope.deleteActivity = function(url, id) {
      var port, protocol, server, servername;
      protocol = location.protocol;
      server = location.hostname;
      port = location.port;
      if (port.length > 0) {
        port = ":" + port;
      }
      servername = protocol + "//" + server + port;
      return ServerHttp["delete"](servername + url, id).then(function(response) {
        return console.log('ok');
      })["catch"](function(status) {
        return console.log(status);
      }).then(function(r) {
        return window.location.reload();
      });
    };
  }
]);

angular.module('Admin').config([
  '$routeProvider', function($routeProvider) {
    return $routeProvider.when('/jojo', {
      templateUrl: '/assets/apps/Admin/templates/history.html',
      controller: 'HistoryCtrl'
    });
  }
]);


angular.module('Admin').factory('Application', [
  '$sce', 'Settings', 'DeviceId', function($sce, Settings, DeviceId) {
    var Application, application;
    Application = (function() {
      function Application() {
        this.customDisplay = {};
        this.customDisplay.content = $sce.trustAsHtml('<span class="yourId">Your ID:<br>' + DeviceId.devicePublicId + '</span>');
      }

      return Application;

    })();
    application = new Application;
    document.numeric.application = application;
    return application;
  }
]);
