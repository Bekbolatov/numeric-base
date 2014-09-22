console.log 'registering for deviceready'
document.addEventListener(
    'deviceready'
    ->
        baseElement = document.getElementsByTagName 'html'
        angular.bootstrap baseElement, ['EarnIt']
        console.log 'bootstrapped App'

        StatusBar.overlaysWebView( false );
        StatusBar.backgroundColorByHexString('#ffffff');
        StatusBar.styleDefault();

        FastClick.attach document.body

        if window.navigator.notification != undefined
            window.alert = (message) ->
              navigator.notification.alert(message, null, "EarnIt", 'OK')

    false
    )

