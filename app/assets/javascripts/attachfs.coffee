angular.module('AppOne').run( ->
    FastClick.attach(document.body)

    if window.navigator.notification != undefined
      window.alert = (message) ->
          navigator.notification.alert( \
              message,
              null,
              "Workshop",
              'OK'
          )
    )
