document.numeric =
    appVersion: 1
    appName: 'earnit'

    modules: {}
    numericTasks: {}

    key:
        settings: 'numericEarnItSettings'
        deviceId: 'numericEarnItDeviceId'
        currentActivitySummary: 'numericEarnItCurrentActivitySummary'
        storedActivitySummaries: 'numericEarnItStoredActivitySummaries'
        messages: 'numericEarnItMessages'
        channelActivities: 'numericEarnItChannelActivitiesCache'
    url:
        base:
            fs: 'numericdataEarnIt/'
            cdv: 'cdvfile://localhost/persistent/'
            chrome: 'filesystem:SERVERNAME/temporary/'
            server: 'https://www.sparkydots.com/activityServer/data/'
    path:
        touch: 'touch'
        channels: 'channels'
        list: 'activity/list'
        activity: 'activity/'
        body: 'activity/body/'
        result: 'result/'

    defaultSettings:
        defaultChannel: 1
        pageSize: 10
        historyServerSync: false
        mainServerAddress: 'https://www.sparkydots.com/activityServer/data/'

try
    ((w) ->
        protocol = location.protocol
        server = location.hostname
        port = location.port
        if port.length > 0
            port = ":" + port
        servername = protocol + "//" + server + port
        w.document.numeric.url.base.chrome = w.document.numeric.url.base.chrome.replace("SERVERNAME", servername)

        if  server == 'localhost' && port == ':9000'
            w.document.numeric.url.base.chrome = "filesystem:http://localhost:9000/temporary/"
            w.document.numeric.defaultSettings.mainServerAddress = "http://localhost:9000/activityServer/data/"
    )(this)
catch e
    console.log(e)
