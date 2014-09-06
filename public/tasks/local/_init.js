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
        storedActivitySummaries: 'numericStoredActivitySummaries'
    },
    url: {
        base: {
            fs: 'numericdata/',
            cdv: 'cdvfile://localhost/persistent/',
            local: '/assets/tasks/local/',
            server: 'https://www.vicinitalk.com/plainmedia/numeric/server/'
            // server: 'http://console.sparkydots.com:8080/numeric/server/'
        }
    },
    path: {
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

    defaultTeachersList: [
        {id: 0, name: 'Mr. Aleman', newItems: 1},
        {id: 2, name: '鬼塚 英吉', newItems: 3}
    ]
}