(function() {
  angular.module('TestApp', ['ImagePng']).controller('TestCtrl', [
    '$scope', '$sce', 'GenerateImagePng', function($scope, $sce, GenerateImagePng) {
      var p, showBinary, showBit, showByte, showIntArrayBin, showStringBin, stringBinary, updateBin, updateD;
      showBit = function(integer, i) {
        return (integer >>> i) & 0x01;
      };
      showByte = function(integer) {
        var i, out, _i;
        out = '';
        for (i = _i = 7; _i >= 0; i = --_i) {
          out += showBit(integer, i);
          if (i % 8 === 0) {
            out += ' ';
          }
        }
        return out;
      };
      showBinary = function(integer) {
        var i, out, _i;
        out = '';
        for (i = _i = 31; _i >= 0; i = --_i) {
          out += showBit(integer, i);
          if (i % 8 === 0) {
            out += ' ';
          }
        }
        return out;
      };
      stringBinary = function(s) {
        var i, o, _i, _ref;
        if (s === void 0) {
          return '';
        }
        o = '';
        for (i = _i = 0, _ref = s.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
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
        var n, o, _i, _len;
        o = '';
        for (_i = 0, _len = ar.length; _i < _len; _i++) {
          n = ar[_i];
          o += showBinary(n) + '<br>';
        }
        return o;
      };
      showStringBin = function(str) {
        var i, o, _i, _ref;
        o = '';
        for (i = _i = 0, _ref = str.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
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
        var DD, bell, ddi, f, i, n, r, r1, r2, r3, r4, s, thisheight, thiswidth, w, x, y, _i, _j, _k, _ref, _ref1;
        if (o === 'in') {
          r = $scope.inputData.split(' ');
          $scope.D = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = r.length; _i < _len; _i++) {
              n = r[_i];
              if (r.length > 0) {
                _results.push(parseInt(n));
              }
            }
            return _results;
          })();
        } else if (o === 'inn') {
          r1 = (function() {
            var _i, _len, _ref, _results;
            _ref = $scope.inputData1.split(' ');
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              n = _ref[_i];
              if (n.length > 0) {
                _results.push(parseInt(n));
              }
            }
            return _results;
          })();
          r2 = (function() {
            var _i, _len, _ref, _results;
            _ref = $scope.inputData2.split(' ');
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              n = _ref[_i];
              if (n.length > 0) {
                _results.push(parseInt(n));
              }
            }
            return _results;
          })();
          r3 = (function() {
            var _i, _len, _ref, _results;
            _ref = $scope.inputData3.split(' ');
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              n = _ref[_i];
              if (n.length > 0) {
                _results.push(parseInt(n));
              }
            }
            return _results;
          })();
          r4 = (function() {
            var _i, _len, _ref, _results;
            _ref = $scope.inputData4.split(' ');
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              n = _ref[_i];
              if (n.length > 0) {
                _results.push(parseInt(n));
              }
            }
            return _results;
          })();
          w = [];
          s = '';
          for (i = _i = 0, _ref = r1.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
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
          _ref1 = [$scope.width, $scope.height], thiswidth = _ref1[0], thisheight = _ref1[1];
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
          for (y = _j = 0; 0 <= thisheight ? _j < thisheight : _j > thisheight; y = 0 <= thisheight ? ++_j : --_j) {
            for (x = _k = 0; 0 <= thiswidth ? _k < thiswidth : _k > thiswidth; x = 0 <= thiswidth ? ++_k : --_k) {
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

}).call(this);
