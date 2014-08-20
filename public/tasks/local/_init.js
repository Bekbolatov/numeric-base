document.numeric = {
    numericTasks: {}, // needed when js loading new activities

    key: {
        activitiesMeta: 'numericActivitiesMeta',
        bookmarkedActivities: 'numericBookmarkedActivities',
        currentActivitySummary: 'numericCurrentActivitySummary'
    },
    url: {
        base: {
            fs: 'cdvfile://localhost/persistent/',
            local: '/assets/tasks/local/',
            server: 'https://www.vicinitalk.com/plainmedia/numeric/server/'
            // server: 'http://console.sparkydots.com:8080/numeric/server/'
            // https://www.vicinitalk.com/plainmedia/numeric/server/
            // http://console.sparkydots.com:8080/numeric/server/
        }
    },
    path: {
        meta: 'meta/',
        body: 'body/',
        list: 'list' // Marketplace: list of public activities -> url.base.server + path.meta + path.list
    },

    defaultActivitiesList: [
        'com.sparkydots.numeric.tasks.t.basic_math',     //Bookmarks (default list)
        'com.sparkydots.numeric.tasks.t.quiz'
    ]
}