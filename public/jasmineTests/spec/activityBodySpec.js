document.numeric.url.base.chrome = 'filesystem:http://localhost:9000/temporary/';

describe("Unit: ActivityLoader", function() {
  var activityLoader, $rootScope, $httpBackend, $q;
  var serverAddress = "https://www.sparkydots.com/public/data/";

  beforeEach(module('AppOne'));

  beforeEach(module(function ($provide) {
    var Settings = {};
    Settings.get = function (attr) {
        if (attr == 'mainServerAddress') {
            return serverAddress;
        } else {
            return "";
        }
    }
    $provide.value('Settings', Settings);
  }));
  beforeEach(module(function ($provide) {
    var ServerHttp ={};
    $provide.value('ServerHttp', ServerHttp);
  }));
  beforeEach(module(function ($provide) {
    var FS ={};
    $provide.value('FS', FS);
  }));

  beforeEach(inject(function (_$q_, _$rootScope_, _$httpBackend_, ActivityLoader) {
      $q = _$q_;
      $httpBackend = _$httpBackend_;
      $rootScope = _$rootScope_;

      activityLoader = ActivityLoader;
    }));

  it("should properly convert path to body: _pathToBody(id) -> 'activity/body/id' ", function() {
    var path = activityLoader._pathToBody('id')
    expect(path).toEqual("activity/body/id");
  });

  it("should properly create uri for cache when not in Cordova: _uriCache(id) -> 'filesystem:http://localhost:9000/temporary/numericdata/activity/body/id?cb=...' ", function() {
    activityLoader._inCordova = function() { return false; }
    var uriCache = activityLoader._uriCache('id')
    var cbi = uriCache.indexOf("cb=");
    expect(uriCache.substr(0, cbi)).toEqual("filesystem:http://localhost:9000/temporary/numericdata/activity/body/id?");
  });

  it("should properly create uri for cache when in Cordova: _uriCache(id) -> 'cdvfile://localhost/persistent/numericdata/activity/body/id?cb=...' ", function() {
    activityLoader._inCordova = function() { return true; }
    var uriCache = activityLoader._uriCache('id')
    var cbi = uriCache.indexOf("cb=");
    expect(uriCache.substr(0, cbi)).toEqual("cdvfile://localhost/persistent/numericdata/activity/body/id?");
  });

  it("should properly create uri for remote: _uriRemote(id) -> 'http://SERVER/ROOT/activity/body/id' ", function() {
    var uriRemote = activityLoader._uriRemote('id')
    expect(uriRemote).toEqual(serverAddress + "activity/body/id");
  });



  it("should reject at _loadScriptFromCache if _createScriptTagAndLoad rejects ", function(done) {

    activityLoader._createScriptTagAndLoad = function (uri, activityId) {
        var deferred = $q.defer();
        deferred.reject(1);
        return deferred.promise;
    }


    $httpBackend.whenGET('/assets/templates/home.html').respond( {} );
    $httpBackend.whenGET('activity/body/id').respond( {} );

    var message = 'as';
     activityLoader._loadScriptFromCache('id')

    .then( function (activity){
            expect(activity).not.toBeDefined();
        })


       .catch( function (error){
            expect(error).toEqual(1);
            })


        .finally(done);

    $httpBackend.flush();

  });

/*
  it("should be able to play a Song", function() {
    player.play(song);
    expect(player.currentlyPlayingSong).toEqual(song);

    //demonstrates use of custom matcher
    expect(player).toBePlaying(song);
  });

  describe("when song has been paused", function() {
    beforeEach(function() {
      player.play(song);
      player.pause();
    });

    it("should indicate that the song is currently paused", function() {
      expect(player.isPlaying).toBeFalsy();

      // demonstrates use of 'not' with a custom matcher
      expect(player).not.toBePlaying(song);
    });

    it("should be possible to resume", function() {
      player.resume();
      expect(player.isPlaying).toBeTruthy();
      expect(player.currentlyPlayingSong).toEqual(song);
    });
  });

  // demonstrates use of spies to intercept and test method calls
  it("tells the current song if the user has made it a favorite", function() {
    spyOn(song, 'persistFavoriteStatus');

    player.play(song);
    player.makeFavorite();

    expect(song.persistFavoriteStatus).toHaveBeenCalledWith(true);
  });

  //demonstrates use of expected exceptions
  describe("#resume", function() {
    it("should throw an exception if song is already playing", function() {
      player.play(song);

      expect(function() {
        player.resume();
      }).toThrowError("song is already playing");
    });
  });

  */
});
