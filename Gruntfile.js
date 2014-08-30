module.exports = function(grunt) {
    var sourceMain = '/Users/renatb/projects/90_scratch/numeric-base/target/web/public/main/';
    var sourceJs = sourceMain + 'javascripts/';


    // Main app
    var appJsSources = [

                    sourceJs + 'filters.js', 
                    sourceJs + 'appOne.js', 

                    sourceJs + 'objectDeviceId.js', 
                    sourceJs + 'objectFileDownload.js', 
                    sourceJs + 'objectFS.js', 
                    sourceJs + 'objectQRSignature.js', 
                    sourceJs + 'objectGraphicsManager.js', 
                    sourceJs + 'objectConnections.js', 
                    sourceJs + 'objectActivityMeta.js', 
                    sourceJs + 'objectActivityBody.js', 
                    sourceJs + 'objectBookmarks.js', 
                    sourceJs + 'objectMarketplace.js', 
                    sourceJs + 'objectActivitySummary.js', 
                    sourceJs + 'objectSettings.js', 

                    sourceJs + 'activityManager.js', 
                    sourceJs + 'activityDriver.js',

                    sourceJs + 'ctrlTask.js', 
                    sourceJs + 'ctrlMarketplace.js', 
                    sourceJs + 'ctrlSettings.js', 
                    sourceJs + 'ctrlHistory.js', 
                    sourceJs + 'ctrlConnect.js', 
                    sourceJs + 'ctrlTest.js', 
                    sourceJs + 'ctrlOthers.js', 

                    sourceJs + 'routes.js' 
                    ];


    //  Krista Questions only
    var kristaJs = sourceJs + 'krista/';
    var kristaQuestionsJs = kristaJs + 'questions/';
    var kristaSources = [
                    kristaJs + 'module.js',
                    kristaJs + 'data.js',
                    kristaJs + 'util.js',

                    kristaQuestionsJs + 'm00.js',
                    kristaQuestionsJs + 'm01.js',
                    kristaQuestionsJs + 'm02.js',
                    kristaQuestionsJs + 'm03.js',
                    kristaQuestionsJs + 'm04.js',
                    kristaQuestionsJs + 'm05.js',
                    kristaQuestionsJs + 'm06.js',
                    kristaQuestionsJs + 'm07.js',
                    kristaQuestionsJs + 'm08.js',
                    kristaQuestionsJs + 'm09.js',
                    kristaQuestionsJs + 'm10.js',
                    kristaQuestionsJs + 'm11.js',
                    kristaQuestionsJs + 'm12.js',
                    kristaQuestionsJs + 'm13.js',
                    kristaQuestionsJs + 'm14.js',
                    kristaQuestionsJs + 'm15.js',
                    kristaQuestionsJs + 'm16.js',
                    kristaQuestionsJs + 'm17.js',
                    kristaQuestionsJs + 'm18.js',
                    kristaQuestionsJs + 'm19.js',
                    kristaQuestionsJs + 'm20.js',
                    kristaQuestionsJs + 'm21.js',
                    kristaQuestionsJs + 'm22.js',
                    kristaQuestionsJs + 'm23.js',
                    kristaQuestionsJs + 'm24.js',
                    kristaQuestionsJs + 'm25.js',
                    kristaQuestionsJs + 'm26.js',
                    kristaQuestionsJs + 'm27.js',
                    kristaQuestionsJs + 'm28.js',
                    kristaQuestionsJs + 'm29.js',
                    kristaQuestionsJs + 'm30.js',

                    ];
    // decide whether to include Krista files here:
    appJsSources = kristaSources.concat(appJsSources);

    var appJsSourcesCordova = appJsSources.concat([sourceJs + 'bootstrapApp.js']);

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
        },
        watch: {
            scripts: {
                files: appJsSourcesCordova,
                tasks: ['numeric'],
            }
        }
    });



    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');

    grunt.registerTask('numeric', 
        [
            'concat:appJs',
            'uglify:appJs', 
            'concat:appJsCordova',
            'uglify:appJsCordova'
        ])
    grunt.registerTask('default', ['numeric'])

    
    //cp target/web/public/main/javascripts/oneApp.min.js    public/javascripts/oneApp.comp.min.js
};


