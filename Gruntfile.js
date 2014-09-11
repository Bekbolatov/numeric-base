module.exports = function(grunt) {
    var sourceCoffee = '/Users/renatb/projects/90_scratch/numeric-base/app/assets/javascripts/';

    var sourceInitJs = '/Users/renatb/projects/90_scratch/numeric-base/target/web/public/main/tasks/local/_init.js';
    var sourceJs = '/Users/renatb/projects/90_scratch/numeric-base/target/web/public/main/javascripts/';
    var oneAppFile = 'oneApp.concat';
    var oneAppCordovaFile = 'oneAppCordova.concat';
    var distDest = '/Users/renatb/projects/90_scratch/numeric-base/public/javascripts/';

    // Used for task generations
    var taskgenSources = sourceCoffee + 'ActivityGenerations/';

    var appJsSources = [
                    sourceInitJs,
                    sourceJs + 'qrcode.js',
                    sourceJs + 'rawdeflate.js',

                    sourceJs + 'libs/settings/SettingsLib/**',
                    sourceJs + 'libs/identity/IdentityLib/**',
                    sourceJs + 'libs/image/ImageLib/**',
                    sourceJs + 'libs/present/BaseLib/**',
                    sourceJs + 'libs/communication/HttpLib/**',
                    sourceJs + 'libs/communication/MessageLib/**',
                    sourceJs + 'libs/persist/PersistenceLib/**',

                    sourceJs + 'libs/data/DataPack/**',
                    sourceJs + 'libs/data/DataUtilities/**',
                    
                    sourceJs + 'apps/AppOne/**',
                    sourceJs + 'ActivityGenerations/Krista/**'   // decide whether to include a module here
                    ];
    var appJsSourcesCordova = appJsSources.concat( [ sourceJs + 'apps/AppOneCordova/**' ] );

    var testSources = [
                    sourceCoffee + 'libs/present/BaseLib/image/ImagePng/*.coffee',
                    sourceCoffee + 'apps/TestApp/*.coffee'
                    ];

    grunt.initConfig({
        coffee: {
            taskgen: {
                options: {
                  join: true
                },
                files: {
                    '/Users/renatb/projects/90_scratch/numeric-base/public/tasks/remote/server/activity/body/com.sparkydots.numeric.tasks.ssat.b.q00' : taskgenSources + 'Renat/SSAT/com/sparkydots/numeric/tasks/ssat/b/' + 'body/*',
                }
            },
            test: {
                files: {
                    '/Users/renatb/projects/90_scratch/numeric-base/public/test/png.js' : testSources
                }
            }
        },
        concat: {
            appJs: {
                src: appJsSources,
                dest: sourceJs + oneAppFile,
                filter: function(path) { return path.indexOf('.js') > -1 }
            },
            appJsCordova: {
                src: appJsSourcesCordova,
                dest: sourceJs + oneAppCordovaFile,
                filter: function(path) { return path.indexOf('.js') > -1 }
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
        copy: {
          taskgen: {
            src: taskgenSources + 'Renat/SSAT/com/sparkydots/numeric/tasks/ssat/b/q00.meta',
            dest: '/Users/renatb/projects/90_scratch/numeric-base/public/tasks/remote/server/activity/meta/com.sparkydots.numeric.tasks.ssat.b.q00'
          },
          appJs: {
            src: '<%= uglify.appJs.dest %>', 
            dest: distDest + 'oneApp.dist.min.js'
          },
          appJsCordova: {
            src: '<%= uglify.appJsCordova.dest %>', 
            dest: distDest + 'oneAppCordova.dist.min.js'
          }
        },
        watch: {
            scripts: {
                files: testSources,
                tasks: ['test'],
            }
        }
    });



    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');

    grunt.registerTask('numeric', 
        [
            'concat:appJs',
            'uglify:appJs', 
            'concat:appJsCordova',
            'uglify:appJsCordova',
            'copy:appJs', 
            'copy:appJsCordova',
        ]);
        
    grunt.registerTask('test', [ 'coffee:test']);
    grunt.registerTask('taskgen', [ 'coffee:taskgen', 'copy:taskgen']);
    grunt.registerTask('default', ['numeric'])

    
    //cp target/web/public/main/javascripts/oneApp.min.js    public/javascripts/oneApp.comp.min.js
};


