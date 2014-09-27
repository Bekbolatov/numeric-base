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
    }, {
      page: 'permissions',
      text: 'Permissions'
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
  '$scope', '$location', '$route', '$sce', 'Settings', 'Tracker', 'Application', 'ServerHttp', function($scope, $location, $route, $sce, Settings, Tracker, Application, ServerHttp) {
    if (!Settings.ready) {
      return $location.path('/');
    } else {
      Tracker.touch('activities');
    }
    $scope.serverAddress = Settings.get('mainServerAddress').replace(/\/activityServer\/data\//, "");
    $scope.startIndex = Application.getVar('activitiesCurrentPage', 0);
    $scope.pageSize = Settings.get('pageSize');
    $scope.endIndex = $scope.startIndex + $scope.pageSize;
    $scope.turnPage = function(distance) {
      if ($scope.startIndex + distance <= 0) {
        if ($scope.startIndex === 0) {
          return 1;
        } else {
          $scope.startIndex = 0;
        }
      } else if (distance < 0) {
        $scope.startIndex = $scope.startIndex - $scope.pageSize;
      } else if ($scope.endIndex < $scope.startIndex + $scope.pageSize) {
        return 1;
      } else {
        $scope.startIndex = $scope.startIndex + $scope.pageSize;
      }
      Application.setVar('activitiesCurrentPage', $scope.startIndex);
      $scope.endIndex = $scope.startIndex + $scope.pageSize;
      return $scope.refreshView();
    };
    $scope.showFormEdit = false;
    $scope.editing = false;
    $scope.adding = false;
    $scope.deleting = false;
    $scope.refreshView = function() {
      return ServerHttp.get($scope.serverAddress + ("/activityServer/admin/activity?startIndex=" + $scope.startIndex + "&size=" + $scope.pageSize)).then(function(response) {
        var a, _i, _len, _ref, _results;
        $scope.activities = response.data.activities;
        _ref = $scope.activities;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          a = _ref[_i];
          console.log(a);
          _results.push(console.log(a.id));
        }
        return _results;
      });
    };
    $scope.showEditForm = function(activityId) {
      $scope.showFormEdit = true;
      $scope.editing = true;
      $scope.adding = false;
      $scope.deleting = false;
      return ServerHttp.get($scope.serverAddress + ("/activityServer/admin/activity/" + activityId)).then(function(response) {
        $scope.formData = response.data;
        return $scope.formDataOriginal = angular.copy($scope.formData);
      })["catch"](function(status) {
        console.log(status);
        $scope.showFormEdit = false;
        $scope.editing = false;
        $scope.adding = false;
        return $scope.deleting = false;
      });
    };
    $scope.updateForm = function() {
      $scope.formData.errors = {};
      $scope.formData.authorDate = "2014-09-14";
      return ServerHttp.post($scope.serverAddress + ("/activityServer/admin/activity/" + $scope.formDataOriginal.id), $scope.formData).then(function(response) {
        $scope.showFormEdit = false;
        $scope.editing = false;
        $scope.adding = false;
        $scope.deleting = false;
        return $scope.refreshView();
      })["catch"](function(status) {
        var error, field, _ref, _results;
        _ref = status.data;
        _results = [];
        for (field in _ref) {
          error = _ref[field];
          _results.push($scope.formData.errors[field] = 'error');
        }
        return _results;
      });
    };
    $scope.createForm = function() {
      $scope.formData.errors = {};
      $scope.formData.authorDate = (new Date()).format("yyyy-mm-dd");
      return ServerHttp.post($scope.serverAddress + "/activityServer/admin/activity", $scope.formData).then(function(response) {
        $scope.showFormEdit = false;
        $scope.editing = false;
        $scope.adding = false;
        $scope.deleting = false;
        return $scope.refreshView();
      })["catch"](function(status) {
        var error, field, _ref, _results;
        _ref = status.data;
        _results = [];
        for (field in _ref) {
          error = _ref[field];
          _results.push($scope.formData.errors[field] = 'error');
        }
        return _results;
      });
    };
    $scope.showDeleteActivity = function(id) {
      $scope.editing = false;
      $scope.adding = false;
      $scope.deleting = true;
      return $scope.deletingActivity = id;
    };
    $scope.deleteActivity = function(id) {
      var port, protocol, server, servername, url;
      protocol = location.protocol;
      server = location.hostname;
      port = location.port;
      if (port.length > 0) {
        port = ":" + port;
      }
      servername = protocol + "//" + server + port;
      url = "/activityServer/admin/activity/" + id;
      return ServerHttp["delete"]($scope.serverAddress + url).then(function(response) {
        console.log('ok');
        $scope.showFormEdit = false;
        $scope.editing = false;
        $scope.adding = false;
        return $scope.deleting = false;
      })["catch"](function(status) {
        return console.log(status);
      }).then(function(r) {
        return $scope.refreshView();
      });
    };
    $scope.showManageChannels = function(id) {
      $scope.channelsManage = {};
      $scope.channelsManageHere = {};
      $scope.managingChannel = id;
      $scope.managingChannels = true;
      return ServerHttp.get($scope.serverAddress + ("/activityServer/admin/activity/" + id + "/channels")).then(function(response) {
        var channel, _i, _len, _ref;
        $scope.channelsHere = response.data.channels;
        _ref = $scope.channelsHere;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          channel = _ref[_i];
          $scope.channelsManageHere[channel.id] = 1;
        }
        return ServerHttp.get($scope.serverAddress + "/activityServer/admin/channel").then(function(response) {
          var _j, _len1, _ref1, _results;
          $scope.channelsAll = response.data.channels;
          _ref1 = $scope.channelsAll;
          _results = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            channel = _ref1[_j];
            $scope.channelsManage[channel.id] = channel;
            if ($scope.channelsManageHere[channel.id] === 1) {
              _results.push($scope.channelsManage[channel.id].included = true);
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        });
      });
    };
    $scope.toggleMembership = function(id) {
      if ($scope.channelsManage[id].included) {
        $scope.channelsManage[id].included = false;
        return ServerHttp.post($scope.serverAddress + ("/activityServer/admin/channel/" + $scope.managingChannel + "/remove/" + id)).then(function(response) {
          return $scope.channelsManage[id].included = false;
        })["catch"](function(status) {
          console.log(status);
          return $scope.channelsManage[id].included = true;
        });
      } else {
        $scope.channelsManage[id].included = true;
        return ServerHttp.post($scope.serverAddress + ("/activityServer/admin/channel/" + $scope.managingChannel + "/add/" + id)).then(function(response) {
          return $scope.channelsManage[id].included = true;
        })["catch"](function(status) {
          console.log(status);
          return $scope.channelsManage[id].included = false;
        });
      }
    };
    $scope.backButton = function() {
      if ($scope.showFormEdit === true) {
        $scope.showFormEdit = false;
        $scope.editing = false;
        $scope.adding = false;
        return $scope.deleting = false;
      } else {
        return $location.path('/');
      }
    };
    return $scope.refreshView();
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
  '$scope', '$location', '$sce', 'Settings', 'Tracker', 'Application', 'ServerHttp', function($scope, $location, $sce, Settings, Tracker, Application, ServerHttp) {
    if (!Settings.ready) {
      return $location.path('/');
    } else {
      Tracker.touch('channels');
    }
    $scope.serverAddress = Settings.get('mainServerAddress').replace(/\/activityServer\/data\//, "");
    $scope.startIndex = Application.getVar('channelsCurrentPage', 0);
    $scope.pageSize = Settings.get('pageSize');
    $scope.endIndex = $scope.startIndex + $scope.pageSize;
    $scope.turnPage = function(distance) {
      if ($scope.startIndex + distance <= 0) {
        if ($scope.startIndex === 0) {
          return 1;
        } else {
          $scope.startIndex = 0;
        }
      } else if (distance < 0) {
        $scope.startIndex = $scope.startIndex - $scope.pageSize;
      } else if ($scope.endIndex < $scope.startIndex + $scope.pageSize) {
        return 1;
      } else {
        $scope.startIndex = $scope.startIndex + $scope.pageSize;
      }
      Application.setVar('channelsCurrentPage', $scope.startIndex);
      $scope.endIndex = $scope.startIndex + $scope.pageSize;
      return $scope.refreshView();
    };
    $scope.showFormEdit = false;
    $scope.editing = false;
    $scope.adding = false;
    $scope.deleting = false;
    $scope.managingActivities = false;
    $scope.refreshView = function() {
      return ServerHttp.get($scope.serverAddress + ("/activityServer/admin/channel?startIndex=" + $scope.startIndex + "&size=" + $scope.pageSize)).then(function(response) {
        return $scope.channels = response.data.channels;
      });
    };
    $scope.showEditForm = function(channelId) {
      $scope.showFormEdit = true;
      $scope.editing = true;
      $scope.adding = false;
      $scope.deleting = false;
      return ServerHttp.get($scope.serverAddress + ("/activityServer/admin/channel/" + channelId)).then(function(response) {
        $scope.formData = response.data;
        return $scope.formDataOriginal = angular.copy($scope.formData);
      })["catch"](function(status) {
        console.log(status);
        return $scope.showFormEdit = false;
      });
    };
    $scope.updateForm = function() {
      $scope.formData.errors = {};
      $scope.formData.createDate = "2014-09-14";
      return ServerHttp.post($scope.serverAddress + ("/activityServer/admin/channel/" + $scope.formDataOriginal.id), $scope.formData).then(function(response) {
        $scope.showFormEdit = false;
        $scope.editing = false;
        $scope.adding = false;
        $scope.deleting = false;
        return $scope.refreshView();
      })["catch"](function(status) {
        var error, field, _ref, _results;
        _ref = status.data;
        _results = [];
        for (field in _ref) {
          error = _ref[field];
          _results.push($scope.formData.errors[field] = 'error');
        }
        return _results;
      });
    };
    $scope.showCreateForm = function() {
      $scope.formData = {};
      $scope.formData.errors = {};
      $scope.formData.createDate = (new Date()).format("yyyy-mm-dd");
      $scope.showFormEdit = true;
      $scope.editing = false;
      $scope.adding = true;
      return $scope.deleting = false;
    };
    $scope.createForm = function() {
      $scope.formData.errors = {};
      $scope.formData.createDate = (new Date()).format("yyyy-mm-dd");
      return ServerHttp.post($scope.serverAddress + "/activityServer/admin/channel", $scope.formData).then(function(response) {
        $scope.showFormEdit = false;
        $scope.editing = false;
        $scope.adding = false;
        $scope.deleting = false;
        return $scope.refreshView();
      })["catch"](function(status) {
        var error, field, _ref, _results;
        _ref = status.data;
        _results = [];
        for (field in _ref) {
          error = _ref[field];
          _results.push($scope.formData.errors[field] = 'error');
        }
        return _results;
      });
    };
    $scope.showDeleteChannel = function(id) {
      $scope.editing = false;
      $scope.adding = false;
      $scope.deleting = true;
      return $scope.deletingChannel = id;
    };
    $scope.deleteChannel = function(id) {
      var port, protocol, server, servername, url;
      protocol = location.protocol;
      server = location.hostname;
      port = location.port;
      if (port.length > 0) {
        port = ":" + port;
      }
      servername = protocol + "//" + server + port;
      url = "/activityServer/admin/channel/" + id;
      return ServerHttp["delete"]($scope.serverAddress + url).then(function(response) {
        console.log('ok');
        $scope.showFormEdit = false;
        $scope.editing = false;
        $scope.adding = false;
        return $scope.deleting = false;
      })["catch"](function(status) {
        return console.log(status);
      }).then(function(r) {
        return $scope.refreshView();
      });
    };
    $scope.showManageActivities = function(id) {
      $scope.activitiesManage = {};
      $scope.activitiesManageHere = {};
      $scope.managingChannel = id;
      $scope.managingActivities = true;
      return ServerHttp.get($scope.serverAddress + ("/activityServer/admin/channel/" + id + "/activities")).then(function(response) {
        var activity, _i, _len, _ref;
        $scope.activitiesHere = response.data.activities;
        _ref = $scope.activitiesHere;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          activity = _ref[_i];
          $scope.activitiesManageHere[activity.id] = 1;
        }
        return ServerHttp.get($scope.serverAddress + "/activityServer/admin/activity").then(function(response) {
          var _j, _len1, _ref1, _results;
          $scope.activitiesAll = response.data.activities;
          _ref1 = $scope.activitiesAll;
          _results = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            activity = _ref1[_j];
            $scope.activitiesManage[activity.id] = activity;
            if ($scope.activitiesManageHere[activity.id] === 1) {
              _results.push($scope.activitiesManage[activity.id].included = true);
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        });
      });
    };
    $scope.toggleMembership = function(id) {
      if ($scope.activitiesManage[id].included) {
        $scope.activitiesManage[id].included = false;
        return ServerHttp.post($scope.serverAddress + ("/activityServer/admin/channel/" + $scope.managingChannel + "/remove/" + id)).then(function(response) {
          return $scope.activitiesManage[id].included = false;
        })["catch"](function(status) {
          console.log(status);
          return $scope.activitiesManage[id].included = true;
        });
      } else {
        $scope.activitiesManage[id].included = true;
        return ServerHttp.post($scope.serverAddress + ("/activityServer/admin/channel/" + $scope.managingChannel + "/add/" + id)).then(function(response) {
          return $scope.activitiesManage[id].included = true;
        })["catch"](function(status) {
          console.log(status);
          return $scope.activitiesManage[id].included = false;
        });
      }
    };
    $scope.backButton = function() {
      if ($scope.showFormEdit === true || $scope.adding === true) {
        $scope.showFormEdit = false;
        $scope.editing = false;
        $scope.adding = false;
        $scope.deleting = false;
        return $scope.managingActivities = false;
      } else {
        return $location.path('/');
      }
    };
    return $scope.refreshView();
  }
]);

angular.module('Admin').controller('EndUserProfilesCtrl', [
  '$scope', '$location', '$sce', 'Settings', 'Application', 'Tracker', 'ServerHttp', function($scope, $location, $sce, Settings, Application, Tracker, ServerHttp) {
    if (!Settings.ready) {
      return $location.path('/');
    } else {
      Tracker.touch('channels');
    }
    $scope.serverAddress = Settings.get('mainServerAddress').replace(/\/activityServer\/data\//, "");
    $scope.startIndex = Application.getVar('profilesCurrentPage', 0);
    $scope.pageSize = Settings.get('pageSize');
    $scope.endIndex = $scope.startIndex + $scope.pageSize;
    $scope.turnPage = function(distance) {
      if ($scope.startIndex + distance <= 0) {
        if ($scope.startIndex === 0) {
          return 1;
        } else {
          $scope.startIndex = 0;
        }
      } else if (distance < 0) {
        $scope.startIndex = $scope.startIndex - $scope.pageSize;
      } else if ($scope.endIndex < $scope.startIndex + $scope.pageSize) {
        return 1;
      } else {
        $scope.startIndex = $scope.startIndex + $scope.pageSize;
      }
      Application.setVar('profilesCurrentPage', $scope.startIndex);
      $scope.endIndex = $scope.startIndex + $scope.pageSize;
      return $scope.refreshView();
    };
    $scope.refreshView = function() {
      return ServerHttp.get($scope.serverAddress + ("/activityServer/admin/profile?startIndex=" + $scope.startIndex + "&size=" + $scope.pageSize)).then(function(response) {
        return $scope.endUserProfiles = response.data.endUserProfiles;
      });
    };
    return $scope.refreshView();
  }
]);


angular.module('Admin').directive('formatdate', [
  '$filter', function($filter) {
    return {
      restrict: 'A',
      require: 'ngModel',
      link: function(scope, element, attrs, ngModel) {
        ngModel.$formatters.push(function(modelValue) {
          return $filter('epochToDate')(modelValue);
        });
        return ngModel.$parsers.push(function(viewValue) {
          return viewValue;
        });
      }
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
        this.vars = {};
        this.customDisplay = {};
        this.customDisplay.content = $sce.trustAsHtml('<span class="yourId">Your ID:<br>' + DeviceId.devicePublicId + '</span>');
      }

      Application.prototype.getVar = function(varname, defaultValue) {
        var value;
        value = this.vars[varname];
        if (value === void 0) {
          value = defaultValue;
        }
        return value;
      };

      Application.prototype.setVar = function(varname, value) {
        return this.vars[varname] = value;
      };

      return Application;

    })();
    application = new Application;
    document.numeric.application = application;
    return application;
  }
]);
