module.exports = (grunt) ->
    distDir = '/Users/renatb/projects/90_scratch/Bekbolatov/ActivityClient/target/dist/'
    publicDir = 'public/'
    appDir = 'public/apps/'

    apps = ['appOne','earnIt', 'admin', 'testApp']
    appFiles = []

    for app in apps
        appFiles.push
            expand: true
            cwd: distDir + 'js/'
            src: [app + '.min.js']
            dest: appDir + 'javascripts/'
        appFiles.push
            expand: true
            cwd: distDir + 'templates/apps/'
            src: [app + '/**/*']
            dest: appDir + 'templates/'
    appFiles.push
        expand: true
        cwd: distDir + 'js/'
        src: ['library.min.js']
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
            common:
                files: appFiles

    grunt.loadNpmTasks 'grunt-contrib-copy'

    grunt.registerTask 'default', [ 'copy:common' ]



