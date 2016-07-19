angular.module('TestApp', ['ImageLib']).controller('TestCtrl', [
  '$scope', '$sce', 'GenerateImagePng', function($scope, $sce, GenerateImagePng) {
    var p, showBinary, showBit, showByte, showIntArrayBin, showStringBin, stringBinary, updateBin, updateD;
    showBit = function(integer, i) {
      return (integer >>> i) & 0x01;
    };
    showByte = function(integer) {
      var i, j, out;
      out = '';
      for (i = j = 7; j >= 0; i = --j) {
        out += showBit(integer, i);
        if (i % 8 === 0) {
          out += ' ';
        }
      }
      return out;
    };
    showBinary = function(integer) {
      var i, j, out;
      out = '';
      for (i = j = 31; j >= 0; i = --j) {
        out += showBit(integer, i);
        if (i % 8 === 0) {
          out += ' ';
        }
      }
      return out;
    };
    stringBinary = function(s) {
      var i, j, o, ref;
      if (s === void 0) {
        return '';
      }
      o = '';
      for (i = j = 0, ref = s.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        o += showByte(s.charCodeAt(i));
      }
      return o;
    };
    updateBin = function() {
      $scope.bA = showBinary($scope.A);
      $scope.bB = showBinary($scope.B);
      $scope.bC = showBinary($scope.C);
      $scope.zz = stringBinary($scope.Z);
      return $scope.Y = btoa($scope.Z);
    };
    $scope.clicked = function(letter) {
      if (letter === 'Z') {
        $scope.Z = $scope.inputData;
      }
      $scope[letter] = $scope.inputData;
      return updateBin();
    };
    $scope.A = 0;
    $scope.B = 0;
    $scope.C = 0;
    updateBin();
    $scope.oper = function(o) {
      var a, b, c;
      a = $scope.A;
      b = $scope.B;
      c = $scope.C;
      if (o === '<<') {
        a = a << 1;
      } else if (o === '>>') {
        a = a >> 1;
      } else if (o === '>>>') {
        a = a >>> 1;
      } else if (o === '~') {
        c = ~a;
      } else if (o === '&') {
        c = a & b;
      } else if (o === '|') {
        c = a | b;
      } else if (o === '^') {
        c = a ^ b;
      } else if (o === '0x0F') {
        a = 0x0F;
      } else if (o === '0xF0') {
        a = 0xF0;
      } else if (o === '0xFF') {
        a = 0xFF;
      } else if (o === '0xFF00') {
        a = 0xFF00;
      } else if (o === '0xFF0F00') {
        a = 0xFF0F00;
      } else if (o === '0xFF000000') {
        a = 0xFF000000;
      } else if (o === '0xF0000000') {
        a = 0xF0000000;
      } else if (o === '0x0F000000') {
        a = 0x0F000000;
      } else if (o === '0x1000100F') {
        a = 0x1000100F;
      } else if (o === 'B') {
        b = a;
      }
      $scope.A = a;
      $scope.B = b;
      $scope.C = c;
      return updateBin();
    };
    p = GenerateImagePng;
    showIntArrayBin = function(ar) {
      var j, len, n, o;
      o = '';
      for (j = 0, len = ar.length; j < len; j++) {
        n = ar[j];
        o += showBinary(n) + '<br>';
      }
      return o;
    };
    showStringBin = function(str) {
      var i, j, o, ref;
      o = '';
      for (i = j = 0, ref = str.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        o += showBinary(str.charCodeAt(i)) + ' ';
      }
      return o;
    };
    updateD = function() {
      return $scope.dd = $sce.trustAsHtml(showStringBin($scope.D));
    };
    $scope.D = [0, 1, 255, 256];
    $scope.inputData1 = "1 1 1 1 1 1";
    $scope.inputData2 = "1 1 1 1 1 1";
    $scope.inputData3 = "1 1 1 1 1 1";
    $scope.inputData4 = "1 1 1 1 1 1";
    $scope.bitDepth = 8;
    $scope.width = 2;
    $scope.height = 3;
    $scope.imgSize = 0;
    $scope.color = 0;
    $scope.printLogs = false;
    $scope.compress = false;
    $scope.filterMethod = 0;
    return $scope.opera = function(o) {
      var DD, bell, ddi, f, i, j, k, l, n, r, r1, r2, r3, r4, ref, ref1, ref2, ref3, s, thisheight, thiswidth, w, x, y;
      if (o === 'in') {
        r = $scope.inputData.split(' ');
        $scope.D = (function() {
          var j, len, results;
          results = [];
          for (j = 0, len = r.length; j < len; j++) {
            n = r[j];
            if (r.length > 0) {
              results.push(parseInt(n));
            }
          }
          return results;
        })();
      } else if (o === 'inn') {
        r1 = (function() {
          var j, len, ref, results;
          ref = $scope.inputData1.split(' ');
          results = [];
          for (j = 0, len = ref.length; j < len; j++) {
            n = ref[j];
            if (n.length > 0) {
              results.push(parseInt(n));
            }
          }
          return results;
        })();
        r2 = (function() {
          var j, len, ref, results;
          ref = $scope.inputData2.split(' ');
          results = [];
          for (j = 0, len = ref.length; j < len; j++) {
            n = ref[j];
            if (n.length > 0) {
              results.push(parseInt(n));
            }
          }
          return results;
        })();
        r3 = (function() {
          var j, len, ref, results;
          ref = $scope.inputData3.split(' ');
          results = [];
          for (j = 0, len = ref.length; j < len; j++) {
            n = ref[j];
            if (n.length > 0) {
              results.push(parseInt(n));
            }
          }
          return results;
        })();
        r4 = (function() {
          var j, len, ref, results;
          ref = $scope.inputData4.split(' ');
          results = [];
          for (j = 0, len = ref.length; j < len; j++) {
            n = ref[j];
            if (n.length > 0) {
              results.push(parseInt(n));
            }
          }
          return results;
        })();
        w = [];
        s = '';
        for (i = j = 0, ref = r1.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          s += String.fromCharCode(r1[i], r2[i], r3[i], r4[i]);
          w[i] = r1[i] << 24 | r2[i] << 16 | r3[i] << 8 | r4[i];
        }
        if ($scope.imgSize === 0) {
          $scope.width = 2;
          $scope.height = 3;
        } else if ($scope.imgSize === 1) {
          $scope.width = 30;
          $scope.height = 30;
        } else if ($scope.imgSize === 2) {
          $scope.width = 100;
          $scope.height = 101;
        } else if ($scope.imgSize === 3) {
          $scope.width = 230;
          $scope.height = 230;
        } else {
          $scope.width = 2;
          $scope.height = 3;
        }
        if ($scope.imgSize > 0) {
          $scope.printLogs = false;
        }
        ddi = [];
        ref1 = [$scope.width, $scope.height], thiswidth = ref1[0], thisheight = ref1[1];
        bell = function(x, y) {
          var M, V, v;
          r = (1.0 * Math.sqrt(Math.pow(y - thisheight / 2, 2) + Math.pow(x - thiswidth / 2, 2))) / thisheight;
          M = 255;
          v = Math.min(0.999, Math.max(0, 1 - Math.exp(-100 * r * r)));
          V = Math.round(M * v);
          return (V << 24) | (V << 16) | (V << 8) | M;
        };
        f = function(x, y) {
          var M, V, v;
          r = (1.0 * Math.sqrt(Math.pow(y - thisheight / 2, 2) + Math.pow(x - thiswidth / 2, 2))) / thisheight;
          M = 255;
          v = Math.min(0.999, Math.max(0, 1 - Math.exp(-100 * r * r)));
          V = Math.round(M * v);
          (V << 24) | (V << 16) | (V << 8) | M;
          (V << 16) * (x / thiswidth) | (V << 8) | M;
          return (V << 24) | M;
        };
        for (y = k = 0, ref2 = thisheight; 0 <= ref2 ? k < ref2 : k > ref2; y = 0 <= ref2 ? ++k : --k) {
          for (x = l = 0, ref3 = thiswidth; 0 <= ref3 ? l < ref3 : l > ref3; x = 0 <= ref3 ? ++l : --l) {
            ddi[y * thiswidth + x] = bell(x, y);
          }
        }
        DD = new p.Data(Number($scope.bitDepth), Number($scope.color), $scope.filterMethod, $scope.compress, ddi, thiswidth, thisheight);
        DD.printData = $scope.printLogs;
        window.DD = DD;
        $scope.imgdata = 'data:image/png;base64,' + btoa(DD.imageData());
        $scope.imgdatasize = ((0.75 * $scope.imgdata.length) / 1024).toFixed(3);
      }
      return updateBin();
    };
  }
]);
