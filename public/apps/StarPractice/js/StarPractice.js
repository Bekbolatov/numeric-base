var e, _initLocal;

_initLocal = function(d) {
  var n;
  if (d.numeric === void 0) {
    console.log('wrong init order...');
    return;
  }
  n = d.numeric;
  n.appVersion = 1;
  n.appName = 'StarPractice';
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

try {
  if (!window.cordova) {
    facebookConnectPlugin.browserInit("627875354000812");
  }
} catch (_error) {
  e = _error;
  console.log(e);
}

angular.module('StarPractice', ['ngRoute', 'ngMd5', 'timer', 'ModulePersistence', 'ModuleSettings', 'ModuleMessage', 'BaseLib', 'ModuleIdentity', 'ModuleCommunication', 'ModuleDataPack', 'ModuleDataUtilities', 'ActivityLib']);


angular.module('StarPractice').controller('ApplicationCtrl', [
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

angular.module('StarPractice').config([
  '$routeProvider', function($routeProvider) {
    return $routeProvider.when('/', {
      templateUrl: '/assets/apps/StarPractice/templates/home.html',
      controller: 'ApplicationCtrl'
    }).when('/home', {
      templateUrl: '/assets/apps/StarPractice/templates/home.html',
      controller: 'HomeCtrl'
    }).when('/info', {
      templateUrl: '/assets/apps/StarPractice/templates/info.html',
      controller: 'InfoCtrl'
    }).when('/channelList', {
      templateUrl: '/assets/apps/StarPractice/templates/channelList.html',
      controller: 'ChannelListCtrl'
    }).when('/channel', {
      templateUrl: '/assets/apps/StarPractice/templates/channel.html',
      controller: 'ChannelCtrl'
    }).when('/tags', {
      templateUrl: '/assets/apps/StarPractice/templates/tags.html',
      controller: 'TagsCtrl'
    }).when('/task', {
      templateUrl: '/assets/apps/StarPractice/templates/task.html',
      controller: 'TaskCtrl'
    }).when('/history', {
      templateUrl: '/assets/apps/StarPractice/templates/history.html',
      controller: 'HistoryCtrl'
    }).when('/historyItem', {
      templateUrl: '/assets/apps/StarPractice/templates/historyItem.html',
      controller: 'HistoryItemCtrl'
    }).when('/settings', {
      templateUrl: '/assets/apps/StarPractice/templates/settings.html',
      controller: 'SettingsCtrl'
    }).when('/connect', {
      templateUrl: '/assets/apps/StarPractice/templates/connect.html',
      controller: 'ConnectCtrl'
    }).when('/myIdentity', {
      templateUrl: '/assets/apps/StarPractice/templates/myIdentity.html',
      controller: 'MyIdentityCtrl'
    }).when('/teachers', {
      templateUrl: '/assets/apps/StarPractice/templates/teachers.html',
      controller: 'TeachersCtrl'
    }).when('/addTeacher', {
      templateUrl: '/assets/apps/StarPractice/templates/addTeacher.html',
      controller: 'AddTeacherCtrl'
    }).when('/test', {
      templateUrl: '/assets/apps/StarPractice/templates/test.html',
      controller: 'TestCtrl'
    }).when('/sampleQuestion', {
      templateUrl: '/assets/apps/StarPractice/templates/sampleQuestion.html',
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


angular.module('StarPractice').factory('Application', [
  '$sce', 'Settings', function($sce, Settings) {
    var Application, application;
    Application = (function() {
      function Application() {
        var infoHtml;
        this.stringInfoTitle = 'About';
        infoHtml = '<p class="paramName"> <b>StarPractice</b> helps students, educators and parents by providing easy ways of generating new practice questions and tracking completed work. </p> <p class="paramName"> When you complete an activity, its history is automatically saved and can be reviewed later by going to "History". </p> <p class="paramName"> In customized versions of this service, educators are provided with additional functionalities: <ul class="ul-info"> <li>create own tests</li> <li>choose from provided question templates</li> <li>tailor practice sets for individual students or groups</li> <li>receive student responses</li> </ul> </p> <p class="paramName"> If you want to get these additional features, please contact <a href="mailto:info@sparkydots.com?subject=Customized%20Activities">info@sparkydots.com</a> for more information. </p>';
        this.stringInfoHtml = $sce.trustAsHtml(infoHtml);
      }

      return Application;

    })();
    application = new Application;
    document.numeric.application = application;
    return application;
  }
]);
