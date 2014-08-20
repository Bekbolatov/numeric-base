module.exports = function(grunt) {
    var sourceMain = '/Users/renatb/projects/90_scratch/numeric-base/target/web/public/main/';
    var sourceJs = sourceMain + 'javascripts/';
    var appJsSources = [
                    sourceJs + 'filters.js', 
                    sourceJs + 'appOne.js', 

                    sourceJs + 'objectFileDownload.js', 
                    sourceJs + 'objectActivityMeta.js', 
                    sourceJs + 'objectActivityBody.js', 
                    sourceJs + 'objectBookmarks.js', 
                    sourceJs + 'objectMarketplace.js', 

                    sourceJs + 'activityManager.js', 
                    sourceJs + 'activityDriver.js',

                    sourceJs + 'ctrlTask.js', 
                    sourceJs + 'ctrlMarketplace.js', 
                    sourceJs + 'ctrlSettings.js', 
                    sourceJs + 'ctrlOthers.js', 

                    sourceJs + 'routes.js' 
                    ];
    var appJsSourcesCordova = appJsSources.concat([sourceJs + 'attachfs.js']);
    grunt.initConfig({
        concat: {
            appJs: {
                src: appJsSources,
                dest: sourceJs + 'oneApp.js',
            },
            appJsCordova: {
                src: appJsSourcesCordova,
                dest: sourceJs + 'oneAppCordova.js',
            }
        },
        uglify: {
          appJs: {
            src: '<%= concat.appJs.dest %>', 
            dest: sourceJs + 'oneApp.min.js'
          },
          appJsCordova: {
            src: '<%= concat.appJsCordova.dest %>', 
            dest: sourceJs + 'oneAppCordova.min.js'
          }
        }
    });


    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-uglify');

    grunt.registerTask('numeric', 
        [
            'concat:appJs',
            'uglify:appJs', 
            'concat:appJsCordova',
            'uglify:appJsCordova'
        ])
    grunt.registerTask('default', ['numeric'])

};

