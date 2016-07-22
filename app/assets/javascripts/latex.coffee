document.aaa = 3
angular.module 'Latex', ['ngRoute']


angular.module 'Latex'
.controller 'LatexCtrl', ['$scope', '$location', '$route', '$sce', '$q', '$http', ($scope, $location, $route, $sce, $q, $http ) ->
    $scope.filename = "result.pdf"
    $scope.raw_latex = ""
    $scope.logs = ""
    $scope.show_errors = false

    $scope.clear_tex = () ->
        $scope.raw_latex = ""
                
    $scope.generate_pdf = () ->
        console.log("generating PDF")
        senddata()

    uintToString = (uintArray) ->
        encodedString = String.fromCharCode.apply(null, uintArray)
        console.log(encodedString)
        decodedString = decodeURIComponent(escape(encodedString))
        decodedString
     
    senddata = () ->
        $scope.logs = ""
        $scope.show_errors = false
        deferred = $q.defer()
        arr = window.location.href.split('/')
        server = arr[0] + '//' + arr[2]
        url = server + '/latex/convert2pdf'
        data = $scope.raw_latex
        $http.post(url, data, {responseType: "arraybuffer", headers: { 'Content-Type': 'plain/text'} })
        .then (response) =>
            if response.headers('Content-Type') != 'application/pdf'
                document.aaa = response
                $scope.logs = new TextDecoder("UTF-8").decode(response.data)
                $scope.show_errors = true
            else
                data = response.data
                blob = new Blob([data], { type: 'application/pdf' })
                console.log(blob)
                if navigator.msSaveBlob
                   navigator.msSaveBlob(blob, $scope.filename)
                else
                   #saveBlob = navigator.webkitSaveBlob || navigator.mozSaveBlob || navigator.saveBlob
                   #saveBlob = window.saveAs || window.webkitSaveAs || window.mozSaveAs || window.msSaveAs
                   a = document.createElement("a")
                   document.body.appendChild(a)
                   a.style = "display: none"
                   url = window.URL.createObjectURL(blob)
                   a.href = url
                   a.download = $scope.filename
                   a.click()
                   setTimeout \
                      (=> \
                        document.body.removeChild(a) \
                        window.URL.revokeObjectURL(url)), \
                      100
            deferred.resolve("ok")
        .catch (e) => deferred.reject(e)
        
        deferred.promise
                  
]
