var _initLocal, e, error;

_initLocal = function(d) {
  var n;
  if (d.numeric === void 0) {
    console.log('wrong init order...');
    return;
  }
  n = d.numeric;
  n.appVersion = 1;
  n.appName = 'AppOne';
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
  return n.defaultSettings.stringHistoryItem = 'Task Summary';
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
} catch (error) {
  e = error;
  console.log(e);
}

angular.module('AppOne', ['ngRoute', 'ngMd5', 'timer', 'ModulePersistence', 'ModuleSettings', 'ModuleMessage', 'BaseLib', 'ModuleIdentity', 'ModuleCommunication', 'ModuleDataPack', 'ModuleDataUtilities', 'ActivityLib']);


angular.module('AppOne').controller('ApplicationCtrl', [
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


angular.module('AppOne').controller('SampleQuestionCtrl', [
  '$scope', '$sce', 'PersistenceManager', 'KristaQuestions', function($scope, $sce, PersistenceManager, KristaQuestions) {
    $scope.browserGood = typeof navigator.webkitPersistentStorage !== 'undefined';
    window.pers = PersistenceManager;
    $scope.regen = function(num) {
      var choice, qa;
      PersistenceManager.save('testikl', {
        s: 1,
        b: 'as',
        c: {
          h: 'yello'
        }
      }).then(function() {
        return PersistenceManager.read('testikl').then(function(obj) {
          return $scope.testik = obj;
        });
      })["catch"](function(t) {
        return console.log(t);
      });
      $scope.showAnswer = false;
      qa = KristaQuestions.generate(num);
      $scope.question = $sce.trustAsHtml('' + qa[0][0]);
      if (qa[0].length > 1) {
        $scope.choices = (function() {
          var i, len, ref, results;
          ref = qa[0][1];
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            choice = ref[i];
            results.push($sce.trustAsHtml('' + choice));
          }
          return results;
        })();
        return $scope.answer = $sce.trustAsHtml('' + qa[0][1][qa[1]]);
      } else {
        $scope.choices = void 0;
        return $scope.answer = $sce.trustAsHtml('' + qa[1]);
      }
    };
    return $scope.regen(4);
  }
]);

angular.module('AppOne').controller('TestCtrl', [
  '$scope', '$rootScope', '$routeParams', '$http', 'md5', 'FS', 'Settings', function($scope, $rootScope, $routeParams, $http, md5, FS, Settings) {
    $scope.showScriptsInHead = function() {
      var i, len, results, tag, tags;
      tags = document.getElementsByTagName('script');
      $scope.scripts = [];
      results = [];
      for (i = 0, len = tags.length; i < len; i++) {
        tag = tags[i];
        if (tag.id !== void 0 && tag.id !== '') {
          results.push($scope.scripts.push(tag));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };
    $scope.getHttpsData = function() {
      return $http.get('https://www.vicinitalk.com/api/v1/post/375/?format=json').then(function(response) {
        console.log(response);
        return $scope.httpsdata = response.data;
      }, function(status) {
        return console.log('error: ' + status);
      });
    };
    $scope.writeToFile = function() {
      return FS.writeToFile('testdata.txt', 'hsellodata');
    };
    $scope.readFromFile = function() {
      return FS.readFromFile('testdata.txt').then(function(data) {
        return $scope.readData = data;
      });
    };
    $scope.getContentsRaw = function(path) {
      return FS.getContents(path);
    };
    $scope.getFromLocal = function(key) {
      return $scope.localData = window.localStorage.getItem(key);
    };
    $scope.testmd5 = function(txt) {
      return $scope.localData = md5.createHash(txt);
    };
    return $scope.setServerToLocalHost = function() {
      return Settings.set("mainServerAddress", "http://localhost:9000/starpractice/data/");
    };
  }
]);

angular.module('AppOne').config([
  '$routeProvider', function($routeProvider) {
    return $routeProvider.when('/', {
      templateUrl: '/assets/apps/AppOne/templates/home.html',
      controller: 'ApplicationCtrl'
    }).when('/home', {
      templateUrl: '/assets/apps/AppOne/templates/home.html',
      controller: 'HomeCtrl'
    }).when('/info', {
      templateUrl: '/assets/apps/AppOne/templates/info.html',
      controller: 'InfoCtrl'
    }).when('/channelList', {
      templateUrl: '/assets/apps/AppOne/templates/channelList.html',
      controller: 'ChannelListCtrl'
    }).when('/channel', {
      templateUrl: '/assets/apps/AppOne/templates/channel.html',
      controller: 'ChannelCtrl'
    }).when('/tags', {
      templateUrl: '/assets/apps/AppOne/templates/tags.html',
      controller: 'TagsCtrl'
    }).when('/task', {
      templateUrl: '/assets/apps/AppOne/templates/task.html',
      controller: 'TaskCtrl'
    }).when('/history', {
      templateUrl: '/assets/apps/AppOne/templates/history.html',
      controller: 'HistoryCtrl'
    }).when('/historyItem', {
      templateUrl: '/assets/apps/AppOne/templates/historyItem.html',
      controller: 'HistoryItemCtrl'
    }).when('/settings', {
      templateUrl: '/assets/apps/AppOne/templates/settings.html',
      controller: 'SettingsCtrl'
    }).when('/connect', {
      templateUrl: '/assets/apps/AppOne/templates/connect.html',
      controller: 'ConnectCtrl'
    }).when('/myIdentity', {
      templateUrl: '/assets/apps/AppOne/templates/myIdentity.html',
      controller: 'MyIdentityCtrl'
    }).when('/teachers', {
      templateUrl: '/assets/apps/AppOne/templates/teachers.html',
      controller: 'TeachersCtrl'
    }).when('/addTeacher', {
      templateUrl: '/assets/apps/AppOne/templates/addTeacher.html',
      controller: 'AddTeacherCtrl'
    }).when('/test', {
      templateUrl: '/assets/apps/AppOne/templates/test.html',
      controller: 'TestCtrl'
    }).when('/sampleQuestion', {
      templateUrl: '/assets/apps/AppOne/templates/sampleQuestion.html',
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


angular.module('AppOne').factory('Application', [
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
