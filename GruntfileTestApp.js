module.exports = function(grunt) {
    var sourceCoffee = '/Users/renatb/projects/90_scratch/numeric-base/app/assets/javascripts/';

    var testSources = [
                    sourceCoffee + 'libs/present/BaseLib/image/ImagePng/*.coffee',
                    sourceCoffee + 'apps/TestApp/*.coffee'
                    ];


    grunt.initConfig({
        coffee: {
            test: {
                files: {
                    '/Users/renatb/projects/90_scratch/numeric-base/public/templates/testApp/png.js' : testSources
                }
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
    grunt.loadNpmTasks('grunt-contrib-watch');

    grunt.registerTask('test', [ 'coffee:test']);
    grunt.registerTask('default', ['test'])

};


