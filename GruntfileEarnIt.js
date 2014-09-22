module.exports = function(grunt) {
    var appName = 'earnIt';
    var appLoc = 'EarnIt';

    var appConcat = appName + '.concat';
    var appCordovaConcat = appName + 'Cordova.concat';

    var sourceJs = '/Users/renatb/projects/90_scratch/numeric-base/target/web/public/main/javascripts/';
    var distDest = '/Users/renatb/projects/90_scratch/numeric-base/public/javascripts/';

    var appJsSources = [
                    sourceJs + 'qrcode.js',
                    sourceJs + 'rawdeflate.js',

                    sourceJs + 'libs/image/ImageLib/**',
                    sourceJs + 'libs/data/DataPack/**',
                    sourceJs + 'libs/data/DataUtilities/**',
                    sourceJs + 'libs/present/BaseLib/**',
                    sourceJs + 'libs/settings/SettingsLib/**',
                    sourceJs + 'libs/persist/PersistenceLib/**',

                    sourceJs + 'libs/identity/IdentityLib/**',
                    sourceJs + 'libs/communication/HttpLib/**',
                    sourceJs + 'libs/communication/MessageLib/**',

                    sourceJs + 'apps/' + appLoc + '/**',
                    ];
    var appJsSourcesCordova = appJsSources.concat( [ sourceJs + 'apps/' + appLoc + 'Cordova/**' ] );

    grunt.initConfig({
        concat: {
            appJs: {
                src: appJsSources,
                dest: sourceJs + appConcat,
                filter: function(path) { return path.indexOf('.js') > -1 }
            },
            appJsCordova: {
                src: appJsSourcesCordova,
                dest: sourceJs + appCordovaConcat,
                filter: function(path) { return path.indexOf('.js') > -1 }
            }
        },
        uglify: {
          appJs: {
            src: '<%= concat.appJs.dest %>', 
            dest: sourceJs + appName + '.min.js'
          },
          appJsCordova: {
            src: '<%= concat.appJsCordova.dest %>', 
            dest: sourceJs + appName + 'Cordova.min.js'
          }
        },
        copy: {
          appJs: {
            src: '<%= uglify.appJs.dest %>', 
            dest: distDest + appName + '.dist.min.js'
          },
          appJsCordova: {
            src: '<%= uglify.appJsCordova.dest %>', 
            dest: distDest + appName + 'Cordova.dist.min.js'
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
            'copy:appJs', 
            'concat:appJsCordova',
            'uglify:appJsCordova',
            'copy:appJsCordova',
        ]);
        
    grunt.registerTask('default', ['numeric'])
    
};


