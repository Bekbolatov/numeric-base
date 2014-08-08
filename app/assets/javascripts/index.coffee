$ ->
    $.get "/clients", (clients) ->
        $.each clients, (index, client) ->
            $("#clients").append $("<li>").text client.name



