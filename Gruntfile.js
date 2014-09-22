module.exports = function(grunt) {
    var sourceCoffee = '/Users/renatb/projects/90_scratch/numeric-base/app/assets/javascripts/';

    var sourceJs = '/Users/renatb/projects/90_scratch/numeric-base/target/web/public/main/javascripts/';
    var oneAppFile = 'oneApp.concat';
    var oneAppCordovaFile = 'oneAppCordova.concat';
    var distDest = '/Users/renatb/projects/90_scratch/numeric-base/public/javascripts/dists/';

    var appJsSources = [
                    sourceJs + 'rawlibs/qrcode.js',
                    sourceJs + 'rawlibs/rawdeflate.js',

                    sourceJs + 'libs/image/ImageLib/**',
                    sourceJs + 'libs/data/DataPack/**',
                    sourceJs + 'libs/data/DataUtilities/**',
                    sourceJs + 'libs/present/BaseLib/**',
                    sourceJs + 'libs/settings/SettingsLib/**',
                    sourceJs + 'libs/persist/PersistenceLib/**',

                    sourceJs + 'libs/identity/IdentityLib/**',
                    sourceJs + 'libs/communication/HttpLib/**',
                    sourceJs + 'libs/communication/MessageLib/**',

                    
                    sourceJs + 'apps/AppOne/**',
                    ];
    var appJsSourcesCordova = appJsSources.concat( [ sourceJs + 'apps/AppOneCordova/**' ] );

    grunt.initConfig({
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
          appJs: {
            src: '<%= uglify.appJs.dest %>', 
            dest: distDest + 'oneApp.dist.min.js'
          },
          appJsCordova: {
            src: '<%= uglify.appJsCordova.dest %>', 
            dest: distDest + 'oneAppCordova.dist.min.js'
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
            'uglify:appJsCordova',
            'copy:appJs', 
            'copy:appJsCordova',
        ]);
        
    grunt.registerTask('default', ['numeric'])

};


