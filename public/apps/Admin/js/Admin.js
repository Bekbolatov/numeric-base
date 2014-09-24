var e, _initLocal;

_initLocal = function(d) {
  var n;
  if (d.numeric === void 0) {
    console.log('wrong init order...');
    return;
  }
  n = d.numeric;
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
  n.defaultSettings.defaultChannel = 0;
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
      return w.document.numeric.defaultSettings.mainServerAddress = "http://localhost:9000/activityServer/data/";
    }
  })(this);
} catch (_error) {
  e = _error;
  console.log(e);
}

angular.module('adminActivities', ['ngRoute', 'ModuleIdentity', 'ModuleCommunication']);

angular.module('adminActivities').controller('mainPage', [
  '$scope', function($scope) {
    return console.log("gello");
  }
]);


angular.module('adminActivities').controller('activityAdd', [
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

angular.module('adminActivities').controller('channelAdd', [
  '$scope', function($scope) {
    return console.log("add channel");
  }
]).controller('channelDetail', [
  '$scope', function($scope) {
    console.log("detail channel");
    $scope.showEditName = false;
    return $scope.toggleEditName = function() {
      if ($scope.showEditName) {
        return $scope.showEditName = false;
      } else {
        return $scope.showEditName = true;
      }
    };
  }
]).controller('channelList', [
  '$scope', 'ServerHttp', function($scope, ServerHttp) {
    console.log("list channels");
    return $scope.deleteChannel = function(url, id) {
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

angular.module('adminActivities').controller('endUserProfileEdit', ['$scope', '$location', '$route', 'DeviceId', 'ServerHttp', function($scope, $location, $route, DeviceId, ServerHttp) {}]).controller('endUserProfileList', [
  '$scope', '$location', '$route', 'DeviceId', 'ServerHttp', function($scope, $location, $route, DeviceId, ServerHttp) {
    console.log("list profile");
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
