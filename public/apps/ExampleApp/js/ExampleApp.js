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
  n.appName = 'ExampleApp';
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
  n.defaultSettings.defaultChannel = 'public.1000';
  n.defaultSettings.stringTitle = n.appName;
  n.defaultSettings.showTabPractice = true;
  n.defaultSettings.stringPractice = 'Practice';
  n.defaultSettings.showTabHistory = true;
  n.defaultSettings.stringHistory = 'History';
  n.defaultSettings.stringActivities = 'Activities';
  return n.defaultSettings.stringHistoryItem = 'Activity Summary';
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

angular.module('ExampleApp', ['ngRoute', 'ngMd5', 'timer', 'ModulePersistence', 'ModuleSettings', 'ModuleMessage', 'BaseLib', 'ModuleIdentity', 'ModuleCommunication', 'ModuleDataPack', 'ModuleDataUtilities', 'ActivityLib']);


angular.module('ExampleApp').controller('ApplicationCtrl', [
  '$scope', '$location', 'Settings', 'Application', function($scope, $location, Settings, Application) {
    var initApplication;
    initApplication = function() {
      return $location.path('/home');
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

angular.module('ExampleApp').config([
  '$routeProvider', function($routeProvider) {
    return $routeProvider.when('/', {
      templateUrl: '/assets/apps/ExampleApp/templates/home.html',
      controller: 'ApplicationCtrl'
    }).when('/home', {
      templateUrl: '/assets/apps/ExampleApp/templates/home.html',
      controller: 'HomeCtrl'
    }).when('/info', {
      templateUrl: '/assets/apps/ExampleApp/templates/info.html',
      controller: 'InfoCtrl'
    }).when('/channelList', {
      templateUrl: '/assets/apps/ExampleApp/templates/channelList.html',
      controller: 'ChannelListCtrl'
    }).when('/channel', {
      templateUrl: '/assets/apps/ExampleApp/templates/channel.html',
      controller: 'ChannelCtrl'
    }).when('/tags', {
      templateUrl: '/assets/apps/ExampleApp/templates/tags.html',
      controller: 'TagsCtrl'
    }).when('/task', {
      templateUrl: '/assets/apps/ExampleApp/templates/task.html',
      controller: 'TaskCtrl'
    }).when('/history', {
      templateUrl: '/assets/apps/ExampleApp/templates/history.html',
      controller: 'HistoryCtrl'
    }).when('/historyItem', {
      templateUrl: '/assets/apps/ExampleApp/templates/historyItem.html',
      controller: 'HistoryItemCtrl'
    }).when('/settings', {
      templateUrl: '/assets/apps/ExampleApp/templates/settings.html',
      controller: 'SettingsCtrl'
    }).when('/connect', {
      templateUrl: '/assets/apps/ExampleApp/templates/connect.html',
      controller: 'ConnectCtrl'
    }).when('/myIdentity', {
      templateUrl: '/assets/apps/ExampleApp/templates/myIdentity.html',
      controller: 'MyIdentityCtrl'
    }).when('/teachers', {
      templateUrl: '/assets/apps/ExampleApp/templates/teachers.html',
      controller: 'TeachersCtrl'
    }).when('/addTeacher', {
      templateUrl: '/assets/apps/ExampleApp/templates/addTeacher.html',
      controller: 'AddTeacherCtrl'
    }).when('/test', {
      templateUrl: '/assets/apps/ExampleApp/templates/test.html',
      controller: 'TestCtrl'
    }).when('/sampleQuestion', {
      templateUrl: '/assets/apps/ExampleApp/templates/sampleQuestion.html',
      controller: 'SampleQuestionCtrl'
    }).otherwise({
      redirectTo: '/'
    });
  }
]).run([
  '$route', '$location', 'TaskCtrlState', function($route, $location, TaskCtrlState) {
    $route.reload();
    document.addEventListener("backbutton", (function(_this) {
      return function() {
        var currentPath;
        currentPath = $location.path();
        if (typeof currentPath !== 'undefined' && currentPath.substr(0, 5) === "/task") {
          return TaskCtrlState.backButton();
        }
        if (typeof currentPath !== 'undefined' && currentPath.substr(0, 12) === "/historyItem") {
          $location.path('/history');
        } else {
          $location.path('/');
        }
        return $route.reload();
      };
    })(this), false);
    return document.addEventListener("menubutton", (function(_this) {
      return function() {
        var currentPath;
        currentPath = $location.path();
        console.log('menu button, current: ' + currentPath);
        if (typeof currentPath !== 'undefined' && currentPath.substr(0, 5) === "/task") {
          return;
        }
        if (typeof currentPath !== 'undefined' && currentPath.substr(0, 9) === "/settings") {
          return;
        }
        $location.path('/settings');
        return $route.reload();
      };
    })(this), false);
  }
]).config([
  '$compileProvider', '$httpProvider', function($compileProvider, $httpProvider) {
    $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|cdvfile|ftp|mailto|file|tel):/);
    return $httpProvider.defaults.useXDomain = true;
  }
]);


angular.module('ExampleApp').factory('Application', [
  '$sce', 'Settings', function($sce, Settings) {
    var Application, application;
    Application = (function() {
      function Application() {}

      return Application;

    })();
    application = new Application;
    document.numeric.application = application;
    return application;
  }
]);
