document.numeric = {
    modules: {},
    numericTasks: {},

    key: {
        settings: 'numericSettings',
        connections: 'numericConnections',
        deviceId: 'numericDeviceId',
        activitiesMeta: 'numericActivitiesMeta',
        bookmarkedActivities: 'numericBookmarkedActivities',
        currentActivitySummary: 'numericCurrentActivitySummary',
        storedActivitySummaries: 'numericStoredActivitySummaries',
        messages: 'numericMessages'
    },
    url: {
        base: {
            fs: 'numericdata/',
            cdv: 'cdvfile://localhost/persistent/',
            chrome: 'filesystem:SERVERNAME/persistent/',
            local: '/assets/tasks/local/',
            server: 'https://www.sparkydots.com/starpractice/data/'
            // server: 'http://console.sparkydots.com:8080/numeric/server/'
        }
    },
    path: {
        activity: 'touch',
        activity: 'activity/',
        list: 'activity/meta/list', // Marketplace: list of public activities
        meta: 'activity/meta/',
        body: 'activity/body/',
        result: 'result/', // Store activity summaries
        persistence: 'persistence/', // Store activity summaries
        connections: 'connections'
    },

    defaultActivitiesList: [
        'com.sparkydots.numeric.tasks.t.basic_math',
        'com.sparkydots.numeric.tasks.ssat.a.q00'
    ],

    defaultSettings: {
        appVersion: 1,
        historyPageSize: 10,
        historyServerSync: false,
        mainServerAddress: 'https://www.sparkydots.com/starpractice/data/',
        //mainServerAddress: 'http://localhost:9000/starpractice/data/',
        linkSubmitShow: false,
        linkConnectShow: false,
        linkSettingsShow: false
    },

    defaultTeachersList: [
        {id: 0, name: 'Mr. Aleman', newItems: 1},
        {id: 2, name: '鬼塚 英吉', newItems: 3}
    ]
}

try {
    (function(w) {
        var protocol = location.protocol;
        var server = location.hostname;
        var port = location.port;
        if (port.length > 0) {
            port = ":" + port;
        }
        var servername = protocol + "//" + server + port;
        w.document.numeric.url.base.chrome = w.document.numeric.url.base.chrome.replace("SERVERNAME", servername);
    })(this);
} catch(e) {
    console.log(e)
}