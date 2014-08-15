document.numeric = {
    keys: {
        numericActivitiesMeta: 'numericActivitiesMeta'
    },

    urlActivityMetaListServer: '/assets/tasks/server/activitiesPublic',

    urlActivityMetaServer: 'http://console.sparkydots.com:8080/numeric/server/meta/',
    urlActivityBodyServer: 'http://console.sparkydots.com:8080/numeric/server/body/',

    urlActivityMetaLocal: '/assets/tasks/local/meta/',
    urlActivityBodyLocal: '/assets/tasks/local/body/',

    directoryActivityBody: 'cdvfile://localhost/persistent/activities/body/',
    directoryActivityBodyFS: 'file:///activities/body/',

    numericTasks: {},
    defaultActivitiesList: [
        'com.sparkydots.numeric.tasks.t.basic_math',
        'com.sparkydots.numeric.tasks.t.quiz'
    ]
}