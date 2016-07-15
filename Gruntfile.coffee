module.exports = (grunt) ->
    watchFile = '../ActivityClient/.completed'
    distDir = '../ActivityClient/target/dist/'
    publicDir = 'public/'

    appFiles = []
    appFiles.push
        expand: true
        cwd: distDir
        src: ['**/*']
        dest: publicDir

    grunt.initConfig
        copy:
            modules:
                files: appFiles
        watch:
            modules:
                files: watchFile
                tasks: 'default'


    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    grunt.registerTask 'default', [ 'copy:modules' ]



