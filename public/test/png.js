(function() {
  angular.module('ImagePng', []).factory('GenerateImagePng', [
    function() {
      var Chunker, Data, Encoder, Palette;
      Chunker = (function() {
        function Chunker(functions) {
          this._initTable();
        }

        Chunker.prototype._initTable = function() {
          var c, k, n, _i, _j, _results;
          this.table = [];
          _results = [];
          for (n = _i = 0; _i < 256; n = ++_i) {
            c = n;
            for (k = _j = 0; _j < 8; k = ++_j) {
              if (c & 1) {
                c = 0xedb88320 ^ (c >>> 1);
              } else {
                c = c >>> 1;
              }
            }
            _results.push(this.table[n] = c);
          }
          return _results;
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
      Palette = (function() {
        function Palette(bitDepth) {
          this.bitDepth = bitDepth;
          this.sizeMaxValue = Math.pow(2, this.bitDepth) - 1;
          this.size = 0;
          this.entries = {};
          this.colors = [];
        }

        Palette.prototype.color = function(y) {
          var entry, value;
          value = 0;
          entry = this.entries[y];
          if (entry !== void 0) {
            value = entry;
          } else if (this.size < this.sizeMaxValue) {
            value = this.size;
            this.entries[y] = value;
            this.colors.push(y);
            this.size += 1;
          }
          return value;
        };

        Palette.prototype.getData = function() {
          var color, s, _i, _len, _ref;
          s = '';
          _ref = this.colors;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            color = _ref[_i];
            s += String.fromCharCode(color >>> 24);
            s += String.fromCharCode((color << 8) >>> 24);
            s += String.fromCharCode((color << 16) >>> 24);
          }
          return s;
        };

        return Palette;

      })();
      Data = (function() {
        function Data(bitDepth, colorType, inputData, width, height) {
          var COLORTYPE;
          this.bitDepth = bitDepth;
          this.colorType = colorType;
          this.inputData = inputData;
          this.width = width;
          this.height = height;
          this.chunker = new Chunker();
          COLORTYPE = {
            0: {
              channels: 1
            },
            2: {
              channels: 3
            },
            3: {
              channels: 1
            },
            4: {
              channels: 2
            },
            6: {
              channels: 4
            }
          };
          this.channels = COLORTYPE[this.colorType].channels;
          if (this.colorType === 3) {
            this.palette = new Palette(this.bitDepth);
          }
          this.colorDepth = this.bitDepth * this.channels;
          if (this.bitDepth === 1) {
            this.BITDEPTHMASK = 0x00000001;
          } else if (this.bitDepth === 2) {
            this.BITDEPTHMASK = 0x00000003;
          } else if (this.bitDepth === 4) {
            this.BITDEPTHMASK = 0x0000000F;
          } else {
            this.BITDEPTHMASK = 0x000000FF;
          }
        }

        Data.prototype._getPixelChannel = function(pixel, channel) {
          var CHANNEL, f, sample;
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
          sample = ((pixel & f.mask) >>> f.shift) & this.BITDEPTHMASK;
          return sample;
        };

        Data.prototype._getPixelData = function(pixel) {
          var bits, converted;
          converted = 0x00000000;
          bits = 0;
          if (this.colorType === 2 || this.colorType === 6) {
            converted = (converted << this.bitDepth) | this._getPixelChannel(pixel, 'RED');
            converted = (converted << this.bitDepth) | this._getPixelChannel(pixel, 'GREEN');
            converted = (converted << this.bitDepth) | this._getPixelChannel(pixel, 'BLUE');
            bits += 3 * this.bitDepth;
          } else if (this.colorType === 3) {
            converted = (converted << this.bitDepth) | this.palette.color(pixel);
            bits += this.bitDepth;
          } else {
            converted = (converted << this.bitDepth) | this._getPixelChannel(pixel, 'GRAY');
            bits += this.bitDepth;
          }
          if (this.colorType === 4 || this.colorType === 6) {
            converted = (converted << this.bitDepth) | this._getPixelChannel(pixel, 'ALPHA');
            bits += this.bitDepth;
          }
          return [converted, bits];
        };

        Data.prototype._fillBytePushLeft = function(byte, index, word, bits) {
          var w;
          w = word;
          return [];
        };

        Data.prototype._convertToByteArray = function() {
          var bits, bitsNow, bitsNowLeftSide, bottomChop, fillByte, fillByteFilled, newByte, newPixel, takeBits, takeData, x, y, _i, _j, _ref, _ref1, _ref2;
          this.data = '';
          for (y = _i = 0, _ref = this.height; 0 <= _ref ? _i < _ref : _i > _ref; y = 0 <= _ref ? ++_i : --_i) {
            fillByte = 0x00;
            fillByteFilled = 0;
            for (x = _j = 0, _ref1 = this.width; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
              _ref2 = this._getPixelData(this.inputData[y * this.width + x]), newPixel = _ref2[0], bits = _ref2[1];
              while (fillByteFilled + bits >= 8) {
                takeBits = 8 - fillByteFilled;
                bottomChop = bits - takeBits;
                takeData = newPixel >>> bottomChop;
                newByte = (fillByte | takeData) & 0xFF;
                if (newByte > 255) {
                  console.log('OUT:' + x + ',' + y + ': ' + newByte);
                }
                this.data += String.fromCharCode(newByte);
                fillByte = 0x00;
                fillByteFilled = 0;
                bitsNow = bits - takeBits;
                bitsNowLeftSide = 32 - bitsNow;
                newPixel = (newPixel << bitsNowLeftSide) >>> bitsNowLeftSide;
                bits = bitsNow;
              }
              if (bits > 0) {
                fillByte = 0xFF & (fillByte | (newPixel << (8 - fillByteFilled - bits)));
                fillByteFilled = fillByteFilled + bits;
              }
            }
            if (fillByteFilled > 0) {
              this.data += String.fromCharCode(fillByte);
            }
          }
          return this.byteArrayLineWidth = Math.ceil(this.width * this.colorDepth / 8);
        };

        Data.prototype._filterSubAndUp = function() {
          return _filterSubAndUp();
        };

        Data.prototype._filterSubAndUp = function() {
          var LINE_FILTER_SUB, LINE_FILTER_UP, cur, filteredData, i, index, prev, step, x, y, _i, _j, _k, _l, _m, _ref, _ref1, _ref2;
          LINE_FILTER_SUB = String.fromCharCode(1);
          LINE_FILTER_UP = String.fromCharCode(2);
          if (this.colorDepth < 8) {
            step = 1;
          } else {
            step = this.colorDepth / 8;
          }
          filteredData = LINE_FILTER_SUB + this.data.substr(0, step);
          for (x = _i = step, _ref = this.byteArrayLineWidth; step > 0 ? _i < _ref : _i > _ref; x = _i += step) {
            for (i = _j = 0; 0 <= step ? _j < step : _j > step; i = 0 <= step ? ++_j : --_j) {
              index = x + i;
              cur = this.data.charCodeAt(index);
              prev = this.data.charCodeAt(index - step);
              filteredData += String.fromCharCode((cur - prev) & 0xFF);
            }
          }
          for (y = _k = 1, _ref1 = this.height; 1 <= _ref1 ? _k < _ref1 : _k > _ref1; y = 1 <= _ref1 ? ++_k : --_k) {
            filteredData += LINE_FILTER_UP;
            for (x = _l = 0, _ref2 = this.byteArrayLineWidth; step > 0 ? _l < _ref2 : _l > _ref2; x = _l += step) {
              for (i = _m = 0; 0 <= step ? _m < step : _m > step; i = 0 <= step ? ++_m : --_m) {
                index = y * this.byteArrayLineWidth + x + i;
                cur = this.data.charCodeAt(index);
                prev = this.data.charCodeAt(index - this.byteArrayLineWidth);
                filteredData += String.fromCharCode((cur - prev) & 0xFF);
              }
            }
          }
          return filteredData;
        };

        Data.prototype._filterZero = function() {
          var LINE_FILTER, filteredData, y, _i, _ref;
          LINE_FILTER = String.fromCharCode(0);
          filteredData = '';
          for (y = _i = 0, _ref = this.height; 0 <= _ref ? _i < _ref : _i > _ref; y = 0 <= _ref ? ++_i : --_i) {
            filteredData += LINE_FILTER + this.data.substr(y * this.byteArrayLineWidth, this.byteArrayLineWidth);
          }
          return filteredData;
        };

        Data.prototype._adler32 = function(data) {
          var FLUSH, MOD_ADLER, a, b, i, n, _i, _ref;
          MOD_ADLER = 65521;
          FLUSH = 5550;
          a = 1;
          b = 0;
          n = 0;
          for (i = _i = 0, _ref = data.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
            a += data.charCodeAt(i);
            b += a;
            if ((n += 1) > FLUSH) {
              a = a % MOD_ADLER;
              b = b % MOD_ADLER;
              n = 0;
            }
          }
          a = a % MOD_ADLER;
          b = b % MOD_ADLER;
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

        Data.prototype._littleEndianShort = function(r) {
          return String.fromCharCode(this._byte(r, 3), this._byte(r, 2));
        };

        Data.prototype._deflate = function(data) {
          var DATA_COMPRESSION_METHOD, MAX_STORE_LENGTH, blockType, i, remaining, storeBuffer, _i, _ref;
          DATA_COMPRESSION_METHOD = String.fromCharCode(0x08, 0x1D);
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
            storeBuffer += blockType + this._littleEndianShort(remaining) + this._littleEndianShort(~remaining);
            storeBuffer += data.substring(i, i + remaining);
          }
          return DATA_COMPRESSION_METHOD + storeBuffer + this._word(this._adler32(data));
        };

        Data.prototype._deflateNoCompression = function(data) {
          var DATA_COMPRESSION_METHOD, MAX_STORE_LENGTH, blockType, i, remaining, storeBuffer, _i, _ref;
          DATA_COMPRESSION_METHOD = String.fromCharCode(0x08, 0x1D);
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
            storeBuffer += blockType + this._littleEndianShort(remaining) + this._littleEndianShort(~remaining);
            storeBuffer += data.substring(i, i + remaining);
          }
          return DATA_COMPRESSION_METHOD + storeBuffer + this._word(this._adler32(data));
        };

        Data.prototype.hexStringOfByte = function(b) {
          var d1, d2, t;
          d1 = (b & 0x000000F0) >>> 4;
          d2 = b & 0x0000000F;
          t = function(d) {
            if (d < 10) {
              return '' + d;
            } else if (d === 10) {
              return 'A';
            } else if (d === 11) {
              return 'B';
            } else if (d === 12) {
              return 'C';
            } else if (d === 13) {
              return 'D';
            } else if (d === 14) {
              return 'E';
            } else {
              return 'F';
            }
          };
          return t(d1) + t(d2) + ' ';
        };

        Data.prototype.hex = function(ins, maybeName, hf) {
          var footer, header, i, s, _i, _ref;
          if (hf) {
            header = hf[0];
            footer = hf[1];
          }
          s = '';
          for (i = _i = 0, _ref = ins.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
            s += this.hexStringOfByte(ins.charCodeAt(i));
            if (hf && i === header - 1) {
              s += '[ ';
            }
            if (hf && i === ins.length - footer - 1) {
              s += '] ';
            }
          }
          return s;
        };

        Data.prototype.printHex = function(ins, maybeName, hf) {
          var s;
          s = this.hex(ins, maybeName, hf);
          s = '[' + maybeName + ', ' + ins.length + '] ' + s;
          return console.log(s);
        };

        Data.prototype.printHexOfListOfStrings = function(list, label) {
          var s, w, _i, _len;
          s = '';
          for (_i = 0, _len = list.length; _i < _len; _i++) {
            w = list[_i];
            s += this.hexOfString(w);
          }
          return console.log('[' + label + '] ' + s);
        };

        Data.prototype.printHexOfListOfInts = function(list, label) {
          var s, w, _i, _len;
          s = '';
          for (_i = 0, _len = list.length; _i < _len; _i++) {
            w = list[_i];
            s += this.hexOfInt(w);
          }
          return console.log('[' + label + '] ' + s);
        };

        Data.prototype.hexOfInt = function(word) {
          return this.hexStringOfByte(word >>> 24) + ' ' + this.hexStringOfByte((word << 8) >>> 24) + ' ' + this.hexStringOfByte((word << 16) >>> 24) + ' ' + this.hexStringOfByte((word << 24) >>> 24) + ' ';
        };

        Data.prototype.hexOfString = function(string, label) {
          var i, s, word, _i, _ref;
          s = '';
          for (i = _i = 0, _ref = string.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
            word = string.charCodeAt(i);
            s += this.hexOfInt(word);
          }
          return s;
        };

        Data.prototype.imageData = function() {
          var IDAT, IEND, IHDR, PLTE, SIGNATURE, compressedData, filteredData;
          this._convertToByteArray();
          filteredData = this._filter();
          compressedData = this._deflate(filteredData);
          SIGNATURE = this.chunker.SIGNATURE();
          IHDR = this.chunker.IHDR(this.width, this.height, this.bitDepth, this.colorType);
          if (this.colorType === 3) {
            PLTE = this.chunker.PLTE(this.palette.getData());
          } else {
            PLTE = '';
          }
          IDAT = this.chunker.IDAT(compressedData);
          IEND = this.chunker.IEND();
          if (this.printData) {
            this.printHexOfListOfInts(this.inputData, 'inputData');
            this.printHex(this.data, 'byteData');
            this.printHex(filteredData, 'filteredData');
            if (this.colorType === 3) {
              this.printHex(this.palette.getData(), 'palette');
            }
            this.printHex(compressedData, 'compresedData', [2, 4]);
            this.printHex(IDAT, 'IDAT');
          }
          return SIGNATURE + IHDR + PLTE + IDAT + IEND;
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
      $scope.bitDepth = 8;
      $scope.width = 2;
      $scope.height = 3;
      $scope.color = 0;
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
          $scope.D = w;
          ddi = [];
          _ref1 = [$scope.width, $scope.height], thiswidth = _ref1[0], thisheight = _ref1[1];
          bell = function(x, y) {
            var M, V, v;
            r = (1.0 * Math.sqrt(Math.pow(y - thisheight / 2, 2) + Math.pow(x - thiswidth / 2, 2))) / thisheight;
            M = Math.pow(2, $scope.bitDepth) - 1;
            v = Math.min(0.999, Math.max(0, 1 - Math.exp(-100 * r * r)));
            V = Math.round(M * v);
            return (V << 24) | (V << 16) | (V << 8) | M;
          };
          f = function(x, y) {
            var M, V, v;
            r = (1.0 * Math.sqrt(Math.pow(y - thisheight / 2, 2) + Math.pow(x - thiswidth / 2, 2))) / thisheight;
            M = Math.pow(2, $scope.bitDepth) - 1;
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
          DD = new p.Data(Number($scope.bitDepth), Number($scope.color), ddi, thiswidth, thisheight);
          DD.printData = false;
          window.DD = DD;
          $scope.imgdata = 'data:image/png;base64,' + btoa(DD.imageData());
        }
        updateD();
        return updateBin();
      };
    }
  ]);

}).call(this);
