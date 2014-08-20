document.numeric = {
    numericTasks: {}, // needed when js loading new activities
    keys: {
        activitiesMeta: 'numericActivitiesMeta',
        bookmarkedActivities: 'numericBookmarkedActivities',
        currentActivitySummary: 'numericCurrentActivitySummary'
    },

    urlActivityMetaListServer: 'http://console.sparkydots.com:8080/numeric/server/meta/activitiesPublic', // Marketplace

    urlActivityMetaLocal: '/assets/tasks/local/meta/',
    urlActivityMetaServer: 'http://console.sparkydots.com:8080/numeric/server/meta/',     // Meta

    urlActivityBodyLocal: '/assets/tasks/local/body/',
    urlActivityBodyServer: 'http://console.sparkydots.com:8080/numeric/server/body/',    // Body
    directoryActivityBody: 'cdvfile://localhost/persistent/activities/body/',

    defaultActivitiesList: [
        'com.sparkydots.numeric.tasks.t.basic_math',     //Bookmarks (default list)
        'com.sparkydots.numeric.tasks.t.quiz'
    ]
}