module.exports = function(grunt) {
    var sourceJs = '/Users/renatb/projects/90_scratch/numeric-base/target/web/public/main/javascripts/';
    var oneAppFile = 'oneApp.concat';
    var oneAppCordovaFile = 'oneAppCordova.concat';
    var distDest = '/Users/renatb/projects/90_scratch/numeric-base/public/javascripts/';

    var appJsSources = [
                    sourceJs + 'libs/BaseLib/**',
                    sourceJs + 'apps/AppOne/**',
                    sourceJs + 'modules/Krista/**',   // decide whether to include a module here
                    sourceJs + 'qrcode.js'
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
            'uglify:appJsCordova',
            'copy:appJs', 
            'copy:appJsCordova',
        ])
    grunt.registerTask('default', ['numeric'])

    
    //cp target/web/public/main/javascripts/oneApp.min.js    public/javascripts/oneApp.comp.min.js
};


