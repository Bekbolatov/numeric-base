module.exports = (grunt) ->
    watchFile = '/Users/renatb/projects/90_scratch/Bekbolatov/ActivityClient/.completed'
    distDir = '/Users/renatb/projects/90_scratch/Bekbolatov/ActivityClient/target/dist/'
    publicDir = 'public/'
    appDir = 'public/apps/'

    appFiles = []

    appFiles.push
        expand: true
        cwd: distDir + 'templates/apps/'
        src: ['**/*']
        dest: appDir + 'templates/'
    appFiles.push
        expand: true
        cwd: distDir + 'js/'
        src: ['**/*.min.js']
        dest: appDir + 'javascripts/'
    appFiles.push
        expand: true
        cwd: distDir + 'css/'
        src: ['**/*']
        dest: appDir + 'stylesheets/'

    appFiles.push
        expand: true
        cwd: distDir + 'images/'
        src: ['**/*']
        dest: publicDir + 'images/'

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



