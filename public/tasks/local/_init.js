document.numeric = {
    numericTasks: {},

    key: {
        settings: 'numericSettings',
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
        result: 'result/' // Store activity summaries
    },

    defaultActivitiesList: [
        'com.sparkydots.numeric.tasks.t.basic_math'
    ]
}