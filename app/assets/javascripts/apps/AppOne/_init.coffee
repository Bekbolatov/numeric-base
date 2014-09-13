document.numeric =
    modules: {}
    numericTasks: {}

    key:
        settings: 'numericSettings'
        connections: 'numericConnections'
        deviceId: 'numericDeviceId'
        activitiesMeta: 'numericActivitiesMeta'
        bookmarkedActivities: 'numericBookmarkedActivities'
        currentActivitySummary: 'numericCurrentActivitySummary'
        storedActivitySummaries: 'numericStoredActivitySummaries'
        messages: 'numericMessages'
    url:
        base:
            fs: 'numericdata/'
            cdv: 'cdvfile://localhost/persistent/'
            chrome: 'filesystem:SERVERNAME/temporary/'
            server: 'https://www.sparkydots.com/starpractice/data/'
    path:
        touch: 'touch'
        channels: 'channels'
        list: 'activity/list'

        connections: 'connections'

        activity: 'activity/'
        body: 'activity/body/'
        result: 'result/'
        persistence: 'persistence/'

    defaultActivitiesList: [
        'com.sparkydots.numeric.tasks.t.basic_math'
        'com.sparkydots.numeric.tasks.ssat.c.q00'
        'com.sparkydots.numeric.tasks.t.multiple_choice'
    ]

    defaultSettings:
        appVersion: 1
        historyPageSize: 10
        historyServerSync: false
        mainServerAddress: 'https://www.sparkydots.com/starpractice/data/'
        linkSubmitShow: false
        linkConnectShow: false
        linkSettingsShow: false

    defaultTeachersList: [
        {id: 0, name: 'Mr. Aleman', newItems: 1}
        {id: 2, name: '鬼塚 英吉', newItems: 3}
    ]

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
            w.document.numeric.defaultSettings.mainServerAddress = "http://localhost:9000/starpractice/data/"
    )(this)
catch e
    console.log(e)
