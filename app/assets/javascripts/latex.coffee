
angular.module 'Latex', ['ngRoute']


angular.module 'Latex'
.controller 'LatexCtrl', ['$scope', '$location', '$route', '$sce', '$q', '$http', ($scope, $location, $route, $sce, $q, $http ) ->
    $scope.filename = "result.pdf"
    $scope.generate_pdf = () ->
        console.log("ok")
        console.log($scope.raw_latex)
        senddata()
                

     
    senddata = () ->
        deferred = $q.defer()

        url = 'http://localhost:9000/latex/convert2pdf'
        data = $scope.raw_latex
        $http.post(url, data, {responseType: "arraybuffer", headers: { 'Content-Type': 'application/plain-text'} })
        .then (response) =>
            data = response.data
            blob = new Blob([data], { type: 'application/pdf' })
            console.log(blob);
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
