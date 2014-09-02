(function() {
  angular.module('ImagePng', []).factory('GenerateImagePng', [
    function() {
      var Chunker, Data, Encoder;
      Chunker = (function() {
        function Chunker(functions) {
          this._initTable();
        }

        Chunker.prototype._initTable = function() {
          var c, k, n, _i, _j;
          this.table = [];
          for (n = _i = 0; _i < 256; n = ++_i) {
            c = n;
            for (k = _j = 0; _j < 8; k = ++_j) {
              if (c & 1) {
                c = 0xedb88320 ^ (c >>> 1);
              } else {
                c = c >>> 1;
              }
            }
            this.table[n] = c;
          }
          return this.table;
        };

        Chunker.prototype._update_crc = function(c, buf) {
          var b, n, _i, _ref;
          for (n = _i = 0, _ref = buf.length; 0 <= _ref ? _i < _ref : _i > _ref; n = 0 <= _ref ? ++_i : --_i) {
            b = buf.charCodeAt(n);
            c = this.table[(c ^ b) & 0xff] ^ (c >>> 8);
          }
          return c;
        };

        Chunker.prototype._crc = function(buf) {
          return this._update_crc(0xffffffff, buf) ^ 0xffffffff;
        };

        Chunker.prototype._byte = function(dword, num) {
          if (num === 0) {
            return (dword & 0xFF000000) >>> 24;
          } else if (num === 1) {
            return (dword & 0x00FF0000) >>> 16;
          } else if (num === 2) {
            return (dword & 0x0000FF00) >>> 8;
          } else {
            return dword & 0x000000FF;
          }
        };

        Chunker.prototype._word = function(r) {
          return String.fromCharCode(this._byte(r, 0), this._byte(r, 1), this._byte(r, 2), this._byte(r, 3));
        };

        Chunker.prototype._createChunk = function(type, data) {
          return this._word(data.length) + type + data + this._word(this._crc(type + data));
        };

        Chunker.prototype.SIGNATURE = function() {
          return String.fromCharCode(137, 80, 78, 71, 13, 10, 26, 10);
        };

        Chunker.prototype.IHDR = function(width, height, bitDepth, colorType) {
          var IHDRdata;
          IHDRdata = this._word(width) + this._word(height);
          IHDRdata += String.fromCharCode(bitDepth);
          IHDRdata += String.fromCharCode(colorType);
          IHDRdata += String.fromCharCode(0);
          IHDRdata += String.fromCharCode(0);
          IHDRdata += String.fromCharCode(0);
          return this._createChunk('IHDR', IHDRdata);
        };

        Chunker.prototype.PLTE = function(palette) {
          return this._createChunk('PLTE', palette);
        };

        Chunker.prototype.IDAT = function(compressedData) {
          return this._createChunk('IDAT', compressedData);
        };

        Chunker.prototype.IEND = function() {
          return this._createChunk('IEND', '');
        };

        return Chunker;

      })();
      Data = (function() {
        function Data(bitDepth, colorType, lineFilter, compression, inputData, width, height) {
          this.bitDepth = bitDepth;
          this.colorType = colorType;
          this.lineFilter = lineFilter;
          this.compression = compression;
          this.inputData = inputData;
          this.width = width;
          this.height = height;
          this.chunker = new Chunker();
          if (this.colorType === 0 || this.colorType === 2) {
            this.channels = this.colorType + 1;
          } else {
            this.channels = this.colorType - 2;
          }
          this.colorDepth = this.bitDepth * this.channels;
          this.LINE_FILTER = String.fromCharCode(lineFilter);
          if (this.bitDepth === 1) {
            this.BITDEPTH = 0x00000001;
          } else if (this.bitDepth === 2) {
            this.BITDEPTH = 0x00000003;
          } else if (this.bitDepth === 4) {
            this.BITDEPTH = 0x0000000F;
          } else {
            this.BITDEPTH = 0x000000FF;
          }
        }

        Data.prototype._getPixelChannel = function(pixel, channel) {
          var CHANNEL, f;
          CHANNEL = {
            RED: {
              mask: 0xFF000000,
              shift: 24
            },
            GREEN: {
              mask: 0x00FF0000,
              shift: 16
            },
            BLUE: {
              mask: 0x000000FF00,
              shift: 8
            },
            ALPHA: {
              mask: 0x00000000FF,
              shift: 0
            },
            GRAY: {
              mask: 0xFF000000,
              shift: 24
            }
          };
          f = CHANNEL[channel];
          return (pixel & f.mask) >>> f.shift;
        };

        Data.prototype._getPixelData = function(pixel) {
          var bits, converted;
          converted = 0;
          bits = 0;
          if (this.colorType === 2 || this.colorType === 6) {
            converted = (converted << this.BITDEPTH) | (this._getPixelChannel(pixel, 'RED') & this.BITDEPTH);
            converted = (converted << this.BITDEPTH) | (this._getPixelChannel(pixel, 'GREEN') & this.BITDEPTH);
            converted = (converted << this.BITDEPTH) | (this._getPixelChannel(pixel, 'BLUE') & this.BITDEPTH);
            bits += 3 * this.bitDepth;
          } else {
            converted = (converted << this.BITDEPTH) | (this._getPixelChannel(pixel, 'GRAY') & this.BITDEPTH);
            bits += this.bitDepth;
          }
          if (this.colorType === 4 || this.colorType === 6) {
            converted = (converted << this.BITDEPTH) | (this._getPixelChannel(pixel, 'ALPHA') & this.BITDEPTH);
            bits += this.bitDepth;
          }
          return [converted, bits];
        };

        Data.prototype._convertToByteArray = function() {
          var bits, fillByte, fillByteFilled, i, newPixel, remBits, takeData, _i, _ref, _ref1;
          this.data = '';
          fillByte = 0;
          fillByteFilled = 0;
          for (i = _i = 0, _ref = this.inputData.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
            _ref1 = this._getPixelData(this.inputData[i]), newPixel = _ref1[0], bits = _ref1[1];
            if (fillByteFilled + bits >= 8) {
              remBits = fillByteFilled + bits - 8;
              takeData = newPixel >>> remBits;
              this.data += String.fromCharCode(fillByte | takeData);
              fillByte = (newPixel << (8 - remBits)) & 0xFF;
              fillByteFilled = remBits;
            } else {
              takeData = newPixel << (8 - fillByteFilled - bits);
              fillByte = fillByte | takeData;
              fillByteFilled = fillByteFilled + bits;
            }
          }
          if (fillByteFilled > 0) {
            this.data += String.fromCharCode(fillByte);
          }
          this.byteArrayLineWidth = Math.ceil(this.width * this.colorDepth / 4);
          return console.log(this.data.length);
        };

        Data.prototype._filter = function() {
          var filteredData, y, _i, _ref;
          filteredData = '';
          console.log(this.data);
          console.log(this.width);
          if (this.lineFilter === 0) {
            for (y = _i = 0, _ref = this.height; 0 <= _ref ? _i < _ref : _i > _ref; y = 0 <= _ref ? ++_i : --_i) {
              filteredData += this.LINE_FILTER;
              filteredData += this.data.substr(y * this.byteArrayLineWidth, this.byteArrayLineWidth);
            }
          }
          return filteredData;
        };

        Data.prototype._adler32 = function(data) {
          var MOD_ADLER, a, b, i, _i, _ref;
          MOD_ADLER = 65521;
          a = 1;
          b = 0;
          for (i = _i = 0, _ref = data.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
            a = (a + data.charCodeAt(i)) % MOD_ADLER;
            b = (b + a) % MOD_ADLER;
          }
          return (b << 16) | a;
        };

        Data.prototype._byte = function(dword, num) {
          if (num === 0) {
            return (dword & 0xFF000000) >>> 24;
          } else if (num === 1) {
            return (dword & 0x00FF0000) >>> 16;
          } else if (num === 2) {
            return (dword & 0x0000FF00) >>> 8;
          } else {
            return dword & 0x000000FF;
          }
        };

        Data.prototype._word = function(r) {
          return String.fromCharCode(this._byte(r, 0), this._byte(r, 1), this._byte(r, 2), this._byte(r, 3));
        };

        Data.prototype._reverseEndianBottom16 = function(r) {
          return String.fromCharCode(this._byte(r, 3), this._byte(r, 2));
        };

        Data.prototype._deflate = function(data) {
          var DATA_COMPRESSION_METHOD, MAX_STORE_LENGTH, blockType, i, remaining, storeBuffer, _i, _ref;
          DATA_COMPRESSION_METHOD = String.fromCharCode(0x78, 0x01);
          MAX_STORE_LENGTH = 65535;
          storeBuffer = '';
          for (i = _i = 0, _ref = data.length; MAX_STORE_LENGTH > 0 ? _i < _ref : _i > _ref; i = _i += MAX_STORE_LENGTH) {
            remaining = data.length - i;
            if (remaining <= MAX_STORE_LENGTH) {
              blockType = String.fromCharCode(0x01);
            } else {
              remaining = MAX_STORE_LENGTH;
              blockType = String.fromCharCode(0x00);
            }
            storeBuffer += blockType + this._reverseEndianBottom16(remaining) + this._reverseEndianBottom16(~remaining);
            storeBuffer += data.substring(i, i + remaining);
          }
          return DATA_COMPRESSION_METHOD + storeBuffer + this._word(this._adler32(data));
        };

        Data.prototype.imageData = function() {
          var IDAT, IEND, IHDR, SIGNATURE, compressedData, filteredData;
          this._convertToByteArray();
          filteredData = this._filter();
          console.log(filteredData);
          compressedData = this._deflate(filteredData);
          console.log(compressedData);
          SIGNATURE = this.chunker.SIGNATURE();
          IHDR = this.chunker.IHDR(this.width, this.height, this.bitDepth, this.colorType);
          IDAT = this.chunker.IDAT(compressedData);
          IEND = this.chunker.IEND();
          return SIGNATURE + IHDR + IDAT + IEND;
        };

        return Data;

      })();
      Encoder = (function() {
        function Encoder() {
          this.Chunker = Chunker;
          this.Data = Data;
        }

        return Encoder;

      })();
      return new Encoder();
    }
  ]);

}).call(this);

(function() {
  angular.module('TestApp', ['ImagePng']).controller('TestCtrl', [
    '$scope', '$sce', 'GenerateImagePng', function($scope, $sce, GenerateImagePng) {
      var p, showBinary, showBit, showByte, showIntArrayBin, stringBinary, updateBin, updateD;
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
      updateD = function() {
        return $scope.dd = $sce.trustAsHtml(showIntArrayBin($scope.D));
      };
      $scope.D = [0, 1, 255, 256];
      updateD();
      $scope.inputData1 = "1 1 1 1 1 1";
      $scope.inputData2 = "1 1 1 1 1 1";
      $scope.inputData3 = "1 1 1 1 1 1";
      $scope.inputData4 = "1 1 1 1 1 1";
      return $scope.opera = function(o) {
        var ddi, i, n, r, r1, r2, r3, r4, s, w, x, y, _i, _j, _k, _ref;
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
          $scope.D = w;
          ddi = [];
          for (y = _j = 0; _j <= 128; y = ++_j) {
            for (x = _k = 0; _k <= 128; x = ++_k) {
              ddi[y * 128 + x] = 255 << 24;
            }
          }
          $scope.DD = new p.Data(8, 0, 0, 0, ddi, 128, 128);
          $scope.DD._convertToByteArray();
          window.DD = $scope.DD;
          $scope.Z = $scope.DD.data;
          $scope.imgdata = 'data:image/png;base64,' + btoa($scope.DD.imageData());
        }
        updateD();
        return updateBin();
      };
    }
  ]);

}).call(this);
