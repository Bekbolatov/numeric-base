//---------------------------------------------------------------------
// QRCode for JavaScript
//
// Copyright (c) 2009 Kazuhiko Arase
//
// URL: http://www.d-project.com/
//
// Licensed under the MIT license:
//   http://www.opensource.org/licenses/mit-license.php
//
// The word "QR Code" is registered trademark of 
// DENSO WAVE INCORPORATED
//   http://www.denso-wave.com/qrcode/faqpatent-e.html
//
//---------------------------------------------------------------------

//---------------------------------------------------------------------
// QR8bitByte
//---------------------------------------------------------------------

function QR8bitByte(data) {
	this.mode = QRMode.MODE_8BIT_BYTE;
	this.data = data;
}

QR8bitByte.prototype = {

	getLength : function(buffer) {
		return this.data.length;
	},
	
	write : function(buffer) {
		for (var i = 0; i < this.data.length; i++) {
			// not JIS ...
			buffer.put(this.data.charCodeAt(i), 8);
		}
	}
};

//---------------------------------------------------------------------
// QRCode
//---------------------------------------------------------------------

function QRCode(typeNumber, errorCorrectLevel) {
	this.typeNumber = typeNumber;
	this.errorCorrectLevel = errorCorrectLevel;
	this.modules = null;
	this.moduleCount = 0;
	this.dataCache = null;
	this.dataList = new Array();
}

QRCode.prototype = {
	
	addData : function(data) {
		var newData = new QR8bitByte(data);
		this.dataList.push(newData);
		this.dataCache = null;
	},
	
	isDark : function(row, col) {
		if (row < 0 || this.moduleCount <= row || col < 0 || this.moduleCount <= col) {
			throw new Error(row + "," + col);
		}
		return this.modules[row][col];
	},

	getModuleCount : function() {
		return this.moduleCount;
	},
	
	make : function() {
		this.makeImpl(false, this.getBestMaskPattern() );
	},
	
	makeImpl : function(test, maskPattern) {
		
		this.moduleCount = this.typeNumber * 4 + 17;
		this.modules = new Array(this.moduleCount);
		
		for (var row = 0; row < this.moduleCount; row++) {
			
			this.modules[row] = new Array(this.moduleCount);
			
			for (var col = 0; col < this.moduleCount; col++) {
				this.modules[row][col] = null;//(col + row) % 3;
			}
		}
	
		this.setupPositionProbePattern(0, 0);
		this.setupPositionProbePattern(this.moduleCount - 7, 0);
		this.setupPositionProbePattern(0, this.moduleCount - 7);
		this.setupPositionAdjustPattern();
		this.setupTimingPattern();
		this.setupTypeInfo(test, maskPattern);
		
		if (this.typeNumber >= 7) {
			this.setupTypeNumber(test);
		}
	
		if (this.dataCache == null) {
			this.dataCache = QRCode.createData(this.typeNumber, this.errorCorrectLevel, this.dataList);
		}
	
		this.mapData(this.dataCache, maskPattern);
	},

	setupPositionProbePattern : function(row, col)  {
		
		for (var r = -1; r <= 7; r++) {
			
			if (row + r <= -1 || this.moduleCount <= row + r) continue;
			
			for (var c = -1; c <= 7; c++) {
				
				if (col + c <= -1 || this.moduleCount <= col + c) continue;
				
				if ( (0 <= r && r <= 6 && (c == 0 || c == 6) )
						|| (0 <= c && c <= 6 && (r == 0 || r == 6) )
						|| (2 <= r && r <= 4 && 2 <= c && c <= 4) ) {
					this.modules[row + r][col + c] = true;
				} else {
					this.modules[row + r][col + c] = false;
				}
			}		
		}		
	},
	
	getBestMaskPattern : function() {
	
		var minLostPoint = 0;
		var pattern = 0;
	
		for (var i = 0; i < 8; i++) {
			
			this.makeImpl(true, i);
	
			var lostPoint = QRUtil.getLostPoint(this);
	
			if (i == 0 || minLostPoint >  lostPoint) {
				minLostPoint = lostPoint;
				pattern = i;
			}
		}
	
		return pattern;
	},
	
	createMovieClip : function(target_mc, instance_name, depth) {
	
		var qr_mc = target_mc.createEmptyMovieClip(instance_name, depth);
		var cs = 1;
	
		this.make();

		for (var row = 0; row < this.modules.length; row++) {
			
			var y = row * cs;
			
			for (var col = 0; col < this.modules[row].length; col++) {
	
				var x = col * cs;
				var dark = this.modules[row][col];
			
				if (dark) {
					qr_mc.beginFill(0, 100);
					qr_mc.moveTo(x, y);
					qr_mc.lineTo(x + cs, y);
					qr_mc.lineTo(x + cs, y + cs);
					qr_mc.lineTo(x, y + cs);
					qr_mc.endFill();
				}
			}
		}
		
		return qr_mc;
	},

	setupTimingPattern : function() {
		
		for (var r = 8; r < this.moduleCount - 8; r++) {
			if (this.modules[r][6] != null) {
				continue;
			}
			this.modules[r][6] = (r % 2 == 0);
		}
	
		for (var c = 8; c < this.moduleCount - 8; c++) {
			if (this.modules[6][c] != null) {
				continue;
			}
			this.modules[6][c] = (c % 2 == 0);
		}
	},
	
	setupPositionAdjustPattern : function() {
	
		var pos = QRUtil.getPatternPosition(this.typeNumber);
		
		for (var i = 0; i < pos.length; i++) {
		
			for (var j = 0; j < pos.length; j++) {
			
				var row = pos[i];
				var col = pos[j];
				
				if (this.modules[row][col] != null) {
					continue;
				}
				
				for (var r = -2; r <= 2; r++) {
				
					for (var c = -2; c <= 2; c++) {
					
						if (r == -2 || r == 2 || c == -2 || c == 2 
								|| (r == 0 && c == 0) ) {
							this.modules[row + r][col + c] = true;
						} else {
							this.modules[row + r][col + c] = false;
						}
					}
				}
			}
		}
	},
	
	setupTypeNumber : function(test) {
	
		var bits = QRUtil.getBCHTypeNumber(this.typeNumber);
	
		for (var i = 0; i < 18; i++) {
			var mod = (!test && ( (bits >> i) & 1) == 1);
			this.modules[Math.floor(i / 3)][i % 3 + this.moduleCount - 8 - 3] = mod;
		}
	
		for (var i = 0; i < 18; i++) {
			var mod = (!test && ( (bits >> i) & 1) == 1);
			this.modules[i % 3 + this.moduleCount - 8 - 3][Math.floor(i / 3)] = mod;
		}
	},
	
	setupTypeInfo : function(test, maskPattern) {
	
		var data = (this.errorCorrectLevel << 3) | maskPattern;
		var bits = QRUtil.getBCHTypeInfo(data);
	
		// vertical		
		for (var i = 0; i < 15; i++) {
	
			var mod = (!test && ( (bits >> i) & 1) == 1);
	
			if (i < 6) {
				this.modules[i][8] = mod;
			} else if (i < 8) {
				this.modules[i + 1][8] = mod;
			} else {
				this.modules[this.moduleCount - 15 + i][8] = mod;
			}
		}
	
		// horizontal
		for (var i = 0; i < 15; i++) {
	
			var mod = (!test && ( (bits >> i) & 1) == 1);
			
			if (i < 8) {
				this.modules[8][this.moduleCount - i - 1] = mod;
			} else if (i < 9) {
				this.modules[8][15 - i - 1 + 1] = mod;
			} else {
				this.modules[8][15 - i - 1] = mod;
			}
		}
	
		// fixed module
		this.modules[this.moduleCount - 8][8] = (!test);
	
	},
	
	mapData : function(data, maskPattern) {
		
		var inc = -1;
		var row = this.moduleCount - 1;
		var bitIndex = 7;
		var byteIndex = 0;
		
		for (var col = this.moduleCount - 1; col > 0; col -= 2) {
	
			if (col == 6) col--;
	
			while (true) {
	
				for (var c = 0; c < 2; c++) {
					
					if (this.modules[row][col - c] == null) {
						
						var dark = false;
	
						if (byteIndex < data.length) {
							dark = ( ( (data[byteIndex] >>> bitIndex) & 1) == 1);
						}
	
						var mask = QRUtil.getMask(maskPattern, row, col - c);
	
						if (mask) {
							dark = !dark;
						}
						
						this.modules[row][col - c] = dark;
						bitIndex--;
	
						if (bitIndex == -1) {
							byteIndex++;
							bitIndex = 7;
						}
					}
				}
								
				row += inc;
	
				if (row < 0 || this.moduleCount <= row) {
					row -= inc;
					inc = -inc;
					break;
				}
			}
		}
		
	}

};

QRCode.PAD0 = 0xEC;
QRCode.PAD1 = 0x11;

QRCode.createData = function(typeNumber, errorCorrectLevel, dataList) {
	
	var rsBlocks = QRRSBlock.getRSBlocks(typeNumber, errorCorrectLevel);
	
	var buffer = new QRBitBuffer();
	
	for (var i = 0; i < dataList.length; i++) {
		var data = dataList[i];
		buffer.put(data.mode, 4);
		buffer.put(data.getLength(), QRUtil.getLengthInBits(data.mode, typeNumber) );
		data.write(buffer);
	}

	// calc num max data.
	var totalDataCount = 0;
	for (var i = 0; i < rsBlocks.length; i++) {
		totalDataCount += rsBlocks[i].dataCount;
	}

	if (buffer.getLengthInBits() > totalDataCount * 8) {
		throw new Error("code length overflow. ("
			+ buffer.getLengthInBits()
			+ ">"
			+  totalDataCount * 8
			+ ")");
	}

	// end code
	if (buffer.getLengthInBits() + 4 <= totalDataCount * 8) {
		buffer.put(0, 4);
	}

	// padding
	while (buffer.getLengthInBits() % 8 != 0) {
		buffer.putBit(false);
	}

	// padding
	while (true) {
		
		if (buffer.getLengthInBits() >= totalDataCount * 8) {
			break;
		}
		buffer.put(QRCode.PAD0, 8);
		
		if (buffer.getLengthInBits() >= totalDataCount * 8) {
			break;
		}
		buffer.put(QRCode.PAD1, 8);
	}

	return QRCode.createBytes(buffer, rsBlocks);
}

QRCode.createBytes = function(buffer, rsBlocks) {

	var offset = 0;
	
	var maxDcCount = 0;
	var maxEcCount = 0;
	
	var dcdata = new Array(rsBlocks.length);
	var ecdata = new Array(rsBlocks.length);
	
	for (var r = 0; r < rsBlocks.length; r++) {

		var dcCount = rsBlocks[r].dataCount;
		var ecCount = rsBlocks[r].totalCount - dcCount;

		maxDcCount = Math.max(maxDcCount, dcCount);
		maxEcCount = Math.max(maxEcCount, ecCount);
		
		dcdata[r] = new Array(dcCount);
		
		for (var i = 0; i < dcdata[r].length; i++) {
			dcdata[r][i] = 0xff & buffer.buffer[i + offset];
		}
		offset += dcCount;
		
		var rsPoly = QRUtil.getErrorCorrectPolynomial(ecCount);
		var rawPoly = new QRPolynomial(dcdata[r], rsPoly.getLength() - 1);

		var modPoly = rawPoly.mod(rsPoly);
		ecdata[r] = new Array(rsPoly.getLength() - 1);
		for (var i = 0; i < ecdata[r].length; i++) {
            var modIndex = i + modPoly.getLength() - ecdata[r].length;
			ecdata[r][i] = (modIndex >= 0)? modPoly.get(modIndex) : 0;
		}

	}
	
	var totalCodeCount = 0;
	for (var i = 0; i < rsBlocks.length; i++) {
		totalCodeCount += rsBlocks[i].totalCount;
	}

	var data = new Array(totalCodeCount);
	var index = 0;

	for (var i = 0; i < maxDcCount; i++) {
		for (var r = 0; r < rsBlocks.length; r++) {
			if (i < dcdata[r].length) {
				data[index++] = dcdata[r][i];
			}
		}
	}

	for (var i = 0; i < maxEcCount; i++) {
		for (var r = 0; r < rsBlocks.length; r++) {
			if (i < ecdata[r].length) {
				data[index++] = ecdata[r][i];
			}
		}
	}

	return data;

}

//---------------------------------------------------------------------
// QRMode
//---------------------------------------------------------------------

var QRMode = {
	MODE_NUMBER :		1 << 0,
	MODE_ALPHA_NUM : 	1 << 1,
	MODE_8BIT_BYTE : 	1 << 2,
	MODE_KANJI :		1 << 3
};

//---------------------------------------------------------------------
// QRErrorCorrectLevel
//---------------------------------------------------------------------
 
var QRErrorCorrectLevel = {
	L : 1,
	M : 0,
	Q : 3,
	H : 2
};

//---------------------------------------------------------------------
// QRMaskPattern
//---------------------------------------------------------------------

var QRMaskPattern = {
	PATTERN000 : 0,
	PATTERN001 : 1,
	PATTERN010 : 2,
	PATTERN011 : 3,
	PATTERN100 : 4,
	PATTERN101 : 5,
	PATTERN110 : 6,
	PATTERN111 : 7
};

//---------------------------------------------------------------------
// QRUtil
//---------------------------------------------------------------------
 
var QRUtil = {

    PATTERN_POSITION_TABLE : [
	    [],
	    [6, 18],
	    [6, 22],
	    [6, 26],
	    [6, 30],
	    [6, 34],
	    [6, 22, 38],
	    [6, 24, 42],
	    [6, 26, 46],
	    [6, 28, 50],
	    [6, 30, 54],		
	    [6, 32, 58],
	    [6, 34, 62],
	    [6, 26, 46, 66],
	    [6, 26, 48, 70],
	    [6, 26, 50, 74],
	    [6, 30, 54, 78],
	    [6, 30, 56, 82],
	    [6, 30, 58, 86],
	    [6, 34, 62, 90],
	    [6, 28, 50, 72, 94],
	    [6, 26, 50, 74, 98],
	    [6, 30, 54, 78, 102],
	    [6, 28, 54, 80, 106],
	    [6, 32, 58, 84, 110],
	    [6, 30, 58, 86, 114],
	    [6, 34, 62, 90, 118],
	    [6, 26, 50, 74, 98, 122],
	    [6, 30, 54, 78, 102, 126],
	    [6, 26, 52, 78, 104, 130],
	    [6, 30, 56, 82, 108, 134],
	    [6, 34, 60, 86, 112, 138],
	    [6, 30, 58, 86, 114, 142],
	    [6, 34, 62, 90, 118, 146],
	    [6, 30, 54, 78, 102, 126, 150],
	    [6, 24, 50, 76, 102, 128, 154],
	    [6, 28, 54, 80, 106, 132, 158],
	    [6, 32, 58, 84, 110, 136, 162],
	    [6, 26, 54, 82, 110, 138, 166],
	    [6, 30, 58, 86, 114, 142, 170]
    ],

    G15 : (1 << 10) | (1 << 8) | (1 << 5) | (1 << 4) | (1 << 2) | (1 << 1) | (1 << 0),
    G18 : (1 << 12) | (1 << 11) | (1 << 10) | (1 << 9) | (1 << 8) | (1 << 5) | (1 << 2) | (1 << 0),
    G15_MASK : (1 << 14) | (1 << 12) | (1 << 10)	| (1 << 4) | (1 << 1),

    getBCHTypeInfo : function(data) {
	    var d = data << 10;
	    while (QRUtil.getBCHDigit(d) - QRUtil.getBCHDigit(QRUtil.G15) >= 0) {
		    d ^= (QRUtil.G15 << (QRUtil.getBCHDigit(d) - QRUtil.getBCHDigit(QRUtil.G15) ) ); 	
	    }
	    return ( (data << 10) | d) ^ QRUtil.G15_MASK;
    },

    getBCHTypeNumber : function(data) {
	    var d = data << 12;
	    while (QRUtil.getBCHDigit(d) - QRUtil.getBCHDigit(QRUtil.G18) >= 0) {
		    d ^= (QRUtil.G18 << (QRUtil.getBCHDigit(d) - QRUtil.getBCHDigit(QRUtil.G18) ) ); 	
	    }
	    return (data << 12) | d;
    },

    getBCHDigit : function(data) {

	    var digit = 0;

	    while (data != 0) {
		    digit++;
		    data >>>= 1;
	    }

	    return digit;
    },

    getPatternPosition : function(typeNumber) {
	    return QRUtil.PATTERN_POSITION_TABLE[typeNumber - 1];
    },

    getMask : function(maskPattern, i, j) {
	    
	    switch (maskPattern) {
		    
	    case QRMaskPattern.PATTERN000 : return (i + j) % 2 == 0;
	    case QRMaskPattern.PATTERN001 : return i % 2 == 0;
	    case QRMaskPattern.PATTERN010 : return j % 3 == 0;
	    case QRMaskPattern.PATTERN011 : return (i + j) % 3 == 0;
	    case QRMaskPattern.PATTERN100 : return (Math.floor(i / 2) + Math.floor(j / 3) ) % 2 == 0;
	    case QRMaskPattern.PATTERN101 : return (i * j) % 2 + (i * j) % 3 == 0;
	    case QRMaskPattern.PATTERN110 : return ( (i * j) % 2 + (i * j) % 3) % 2 == 0;
	    case QRMaskPattern.PATTERN111 : return ( (i * j) % 3 + (i + j) % 2) % 2 == 0;

	    default :
		    throw new Error("bad maskPattern:" + maskPattern);
	    }
    },

    getErrorCorrectPolynomial : function(errorCorrectLength) {

	    var a = new QRPolynomial([1], 0);

	    for (var i = 0; i < errorCorrectLength; i++) {
		    a = a.multiply(new QRPolynomial([1, QRMath.gexp(i)], 0) );
	    }

	    return a;
    },

    getLengthInBits : function(mode, type) {

	    if (1 <= type && type < 10) {

		    // 1 - 9

		    switch(mode) {
		    case QRMode.MODE_NUMBER 	: return 10;
		    case QRMode.MODE_ALPHA_NUM 	: return 9;
		    case QRMode.MODE_8BIT_BYTE	: return 8;
		    case QRMode.MODE_KANJI  	: return 8;
		    default :
			    throw new Error("mode:" + mode);
		    }

	    } else if (type < 27) {

		    // 10 - 26

		    switch(mode) {
		    case QRMode.MODE_NUMBER 	: return 12;
		    case QRMode.MODE_ALPHA_NUM 	: return 11;
		    case QRMode.MODE_8BIT_BYTE	: return 16;
		    case QRMode.MODE_KANJI  	: return 10;
		    default :
			    throw new Error("mode:" + mode);
		    }

	    } else if (type < 41) {

		    // 27 - 40

		    switch(mode) {
		    case QRMode.MODE_NUMBER 	: return 14;
		    case QRMode.MODE_ALPHA_NUM	: return 13;
		    case QRMode.MODE_8BIT_BYTE	: return 16;
		    case QRMode.MODE_KANJI  	: return 12;
		    default :
			    throw new Error("mode:" + mode);
		    }

	    } else {
		    throw new Error("type:" + type);
	    }
    },

    getLostPoint : function(qrCode) {
	    
	    var moduleCount = qrCode.getModuleCount();
	    
	    var lostPoint = 0;
	    
	    // LEVEL1
	    
	    for (var row = 0; row < moduleCount; row++) {

		    for (var col = 0; col < moduleCount; col++) {

			    var sameCount = 0;
			    var dark = qrCode.isDark(row, col);

				for (var r = -1; r <= 1; r++) {

				    if (row + r < 0 || moduleCount <= row + r) {
					    continue;
				    }

				    for (var c = -1; c <= 1; c++) {

					    if (col + c < 0 || moduleCount <= col + c) {
						    continue;
					    }

					    if (r == 0 && c == 0) {
						    continue;
					    }

					    if (dark == qrCode.isDark(row + r, col + c) ) {
						    sameCount++;
					    }
				    }
			    }

			    if (sameCount > 5) {
				    lostPoint += (3 + sameCount - 5);
			    }
		    }
	    }

	    // LEVEL2

	    for (var row = 0; row < moduleCount - 1; row++) {
		    for (var col = 0; col < moduleCount - 1; col++) {
			    var count = 0;
			    if (qrCode.isDark(row,     col    ) ) count++;
			    if (qrCode.isDark(row + 1, col    ) ) count++;
			    if (qrCode.isDark(row,     col + 1) ) count++;
			    if (qrCode.isDark(row + 1, col + 1) ) count++;
			    if (count == 0 || count == 4) {
				    lostPoint += 3;
			    }
		    }
	    }

	    // LEVEL3

	    for (var row = 0; row < moduleCount; row++) {
		    for (var col = 0; col < moduleCount - 6; col++) {
			    if (qrCode.isDark(row, col)
					    && !qrCode.isDark(row, col + 1)
					    &&  qrCode.isDark(row, col + 2)
					    &&  qrCode.isDark(row, col + 3)
					    &&  qrCode.isDark(row, col + 4)
					    && !qrCode.isDark(row, col + 5)
					    &&  qrCode.isDark(row, col + 6) ) {
				    lostPoint += 40;
			    }
		    }
	    }

	    for (var col = 0; col < moduleCount; col++) {
		    for (var row = 0; row < moduleCount - 6; row++) {
			    if (qrCode.isDark(row, col)
					    && !qrCode.isDark(row + 1, col)
					    &&  qrCode.isDark(row + 2, col)
					    &&  qrCode.isDark(row + 3, col)
					    &&  qrCode.isDark(row + 4, col)
					    && !qrCode.isDark(row + 5, col)
					    &&  qrCode.isDark(row + 6, col) ) {
				    lostPoint += 40;
			    }
		    }
	    }

	    // LEVEL4
	    
	    var darkCount = 0;

	    for (var col = 0; col < moduleCount; col++) {
		    for (var row = 0; row < moduleCount; row++) {
			    if (qrCode.isDark(row, col) ) {
				    darkCount++;
			    }
		    }
	    }
	    
	    var ratio = Math.abs(100 * darkCount / moduleCount / moduleCount - 50) / 5;
	    lostPoint += ratio * 10;

	    return lostPoint;		
    }

};


//---------------------------------------------------------------------
// QRMath
//---------------------------------------------------------------------

var QRMath = {

	glog : function(n) {
	
		if (n < 1) {
			throw new Error("glog(" + n + ")");
		}
		
		return QRMath.LOG_TABLE[n];
	},
	
	gexp : function(n) {
	
		while (n < 0) {
			n += 255;
		}
	
		while (n >= 256) {
			n -= 255;
		}
	
		return QRMath.EXP_TABLE[n];
	},
	
	EXP_TABLE : new Array(256),
	
	LOG_TABLE : new Array(256)

};
	
for (var i = 0; i < 8; i++) {
	QRMath.EXP_TABLE[i] = 1 << i;
}
for (var i = 8; i < 256; i++) {
	QRMath.EXP_TABLE[i] = QRMath.EXP_TABLE[i - 4]
		^ QRMath.EXP_TABLE[i - 5]
		^ QRMath.EXP_TABLE[i - 6]
		^ QRMath.EXP_TABLE[i - 8];
}
for (var i = 0; i < 255; i++) {
	QRMath.LOG_TABLE[QRMath.EXP_TABLE[i] ] = i;
}

//---------------------------------------------------------------------
// QRPolynomial
//---------------------------------------------------------------------

function QRPolynomial(num, shift) {

	if (num.length == undefined) {
		throw new Error(num.length + "/" + shift);
	}

	var offset = 0;

	while (offset < num.length && num[offset] == 0) {
		offset++;
	}

	this.num = new Array(num.length - offset + shift);
	for (var i = 0; i < num.length - offset; i++) {
		this.num[i] = num[i + offset];
	}
}

QRPolynomial.prototype = {

	get : function(index) {
		return this.num[index];
	},
	
	getLength : function() {
		return this.num.length;
	},
	
	multiply : function(e) {
	
		var num = new Array(this.getLength() + e.getLength() - 1);
	
		for (var i = 0; i < this.getLength(); i++) {
			for (var j = 0; j < e.getLength(); j++) {
				num[i + j] ^= QRMath.gexp(QRMath.glog(this.get(i) ) + QRMath.glog(e.get(j) ) );
			}
		}
	
		return new QRPolynomial(num, 0);
	},
	
	mod : function(e) {
	
		if (this.getLength() - e.getLength() < 0) {
			return this;
		}
	
		var ratio = QRMath.glog(this.get(0) ) - QRMath.glog(e.get(0) );
	
		var num = new Array(this.getLength() );
		
		for (var i = 0; i < this.getLength(); i++) {
			num[i] = this.get(i);
		}
		
		for (var i = 0; i < e.getLength(); i++) {
			num[i] ^= QRMath.gexp(QRMath.glog(e.get(i) ) + ratio);
		}
	
		// recursive call
		return new QRPolynomial(num, 0).mod(e);
	}
};

//---------------------------------------------------------------------
// QRRSBlock
//---------------------------------------------------------------------

function QRRSBlock(totalCount, dataCount) {
	this.totalCount = totalCount;
	this.dataCount  = dataCount;
}

QRRSBlock.RS_BLOCK_TABLE = [

  // L
  // M
  // Q
  // H

  // 1
  [1, 26, 19],
  [1, 26, 16],
  [1, 26, 13],
  [1, 26, 9],

  // 2
  [1, 44, 34],
  [1, 44, 28],
  [1, 44, 22],
  [1, 44, 16],

  // 3
  [1, 70, 55],
  [1, 70, 44],
  [2, 35, 17],
  [2, 35, 13],

  // 4		
  [1, 100, 80],
  [2, 50, 32],
  [2, 50, 24],
  [4, 25, 9],

  // 5
  [1, 134, 108],
  [2, 67, 43],
  [2, 33, 15, 2, 34, 16],
  [2, 33, 11, 2, 34, 12],

  // 6
  [2, 86, 68],
  [4, 43, 27],
  [4, 43, 19],
  [4, 43, 15],

  // 7		
  [2, 98, 78],
  [4, 49, 31],
  [2, 32, 14, 4, 33, 15],
  [4, 39, 13, 1, 40, 14],

  // 8
  [2, 121, 97],
  [2, 60, 38, 2, 61, 39],
  [4, 40, 18, 2, 41, 19],
  [4, 40, 14, 2, 41, 15],

  // 9
  [2, 146, 116],
  [3, 58, 36, 2, 59, 37],
  [4, 36, 16, 4, 37, 17],
  [4, 36, 12, 4, 37, 13],

  // 10		
  [2, 86, 68, 2, 87, 69],
  [4, 69, 43, 1, 70, 44],
  [6, 43, 19, 2, 44, 20],
  [6, 43, 15, 2, 44, 16],

  // 11
  [4, 101, 81],
  [1, 80, 50, 4, 81, 51],
  [4, 50, 22, 4, 51, 23],
  [3, 36, 12, 8, 37, 13],

  // 12
  [2, 116, 92, 2, 117, 93],
  [6, 58, 36, 2, 59, 37],
  [4, 46, 20, 6, 47, 21],
  [7, 42, 14, 4, 43, 15],

  // 13
  [4, 133, 107],
  [8, 59, 37, 1, 60, 38],
  [8, 44, 20, 4, 45, 21],
  [12, 33, 11, 4, 34, 12],

  // 14
  [3, 145, 115, 1, 146, 116],
  [4, 64, 40, 5, 65, 41],
  [11, 36, 16, 5, 37, 17],
  [11, 36, 12, 5, 37, 13],

  // 15
  [5, 109, 87, 1, 110, 88],
  [5, 65, 41, 5, 66, 42],
  [5, 54, 24, 7, 55, 25],
  [11, 36, 12],

  // 16
  [5, 122, 98, 1, 123, 99],
  [7, 73, 45, 3, 74, 46],
  [15, 43, 19, 2, 44, 20],
  [3, 45, 15, 13, 46, 16],

  // 17
  [1, 135, 107, 5, 136, 108],
  [10, 74, 46, 1, 75, 47],
  [1, 50, 22, 15, 51, 23],
  [2, 42, 14, 17, 43, 15],

  // 18
  [5, 150, 120, 1, 151, 121],
  [9, 69, 43, 4, 70, 44],
  [17, 50, 22, 1, 51, 23],
  [2, 42, 14, 19, 43, 15],

  // 19
  [3, 141, 113, 4, 142, 114],
  [3, 70, 44, 11, 71, 45],
  [17, 47, 21, 4, 48, 22],
  [9, 39, 13, 16, 40, 14],

  // 20
  [3, 135, 107, 5, 136, 108],
  [3, 67, 41, 13, 68, 42],
  [15, 54, 24, 5, 55, 25],
  [15, 43, 15, 10, 44, 16],

  // 21
  [4, 144, 116, 4, 145, 117],
  [17, 68, 42],
  [17, 50, 22, 6, 51, 23],
  [19, 46, 16, 6, 47, 17],

  // 22
  [2, 139, 111, 7, 140, 112],
  [17, 74, 46],
  [7, 54, 24, 16, 55, 25],
  [34, 37, 13],

  // 23
  [4, 151, 121, 5, 152, 122],
  [4, 75, 47, 14, 76, 48],
  [11, 54, 24, 14, 55, 25],
  [16, 45, 15, 14, 46, 16],

  // 24
  [6, 147, 117, 4, 148, 118],
  [6, 73, 45, 14, 74, 46],
  [11, 54, 24, 16, 55, 25],
  [30, 46, 16, 2, 47, 17],

  // 25
  [8, 132, 106, 4, 133, 107],
  [8, 75, 47, 13, 76, 48],
  [7, 54, 24, 22, 55, 25],
  [22, 45, 15, 13, 46, 16],

  // 26
  [10, 142, 114, 2, 143, 115],
  [19, 74, 46, 4, 75, 47],
  [28, 50, 22, 6, 51, 23],
  [33, 46, 16, 4, 47, 17],

  // 27
  [8, 152, 122, 4, 153, 123],
  [22, 73, 45, 3, 74, 46],
  [8, 53, 23, 26, 54, 24],
  [12, 45, 15, 28, 46, 16],

  // 28
  [3, 147, 117, 10, 148, 118],
  [3, 73, 45, 23, 74, 46],
  [4, 54, 24, 31, 55, 25],
  [11, 45, 15, 31, 46, 16],

  // 29
  [7, 146, 116, 7, 147, 117],
  [21, 73, 45, 7, 74, 46],
  [1, 53, 23, 37, 54, 24],
  [19, 45, 15, 26, 46, 16],

  // 30
  [5, 145, 115, 10, 146, 116],
  [19, 75, 47, 10, 76, 48],
  [15, 54, 24, 25, 55, 25],
  [23, 45, 15, 25, 46, 16],

  // 31
  [13, 145, 115, 3, 146, 116],
  [2, 74, 46, 29, 75, 47],
  [42, 54, 24, 1, 55, 25],
  [23, 45, 15, 28, 46, 16],

  // 32
  [17, 145, 115],
  [10, 74, 46, 23, 75, 47],
  [10, 54, 24, 35, 55, 25],
  [19, 45, 15, 35, 46, 16],

  // 33
  [17, 145, 115, 1, 146, 116],
  [14, 74, 46, 21, 75, 47],
  [29, 54, 24, 19, 55, 25],
  [11, 45, 15, 46, 46, 16],

  // 34
  [13, 145, 115, 6, 146, 116],
  [14, 74, 46, 23, 75, 47],
  [44, 54, 24, 7, 55, 25],
  [59, 46, 16, 1, 47, 17],

  // 35
  [12, 151, 121, 7, 152, 122],
  [12, 75, 47, 26, 76, 48],
  [39, 54, 24, 14, 55, 25],
  [22, 45, 15, 41, 46, 16],

  // 36
  [6, 151, 121, 14, 152, 122],
  [6, 75, 47, 34, 76, 48],
  [46, 54, 24, 10, 55, 25],
  [2, 45, 15, 64, 46, 16],

  // 37
  [17, 152, 122, 4, 153, 123],
  [29, 74, 46, 14, 75, 47],
  [49, 54, 24, 10, 55, 25],
  [24, 45, 15, 46, 46, 16],

  // 38
  [4, 152, 122, 18, 153, 123],
  [13, 74, 46, 32, 75, 47],
  [48, 54, 24, 14, 55, 25],
  [42, 45, 15, 32, 46, 16],

  // 39
  [20, 147, 117, 4, 148, 118],
  [40, 75, 47, 7, 76, 48],
  [43, 54, 24, 22, 55, 25],
  [10, 45, 15, 67, 46, 16],

  // 40
  [19, 148, 118, 6, 149, 119],
  [18, 75, 47, 31, 76, 48],
  [34, 54, 24, 34, 55, 25],
  [20, 45, 15, 61, 46, 16]

];

QRRSBlock.getRSBlocks = function(typeNumber, errorCorrectLevel) {
	
	var rsBlock = QRRSBlock.getRsBlockTable(typeNumber, errorCorrectLevel);
	
	if (rsBlock == undefined) {
		throw new Error("bad rs block @ typeNumber:" + typeNumber + "/errorCorrectLevel:" + errorCorrectLevel);
	}

	var length = rsBlock.length / 3;
	
	var list = new Array();
	
	for (var i = 0; i < length; i++) {

		var count = rsBlock[i * 3 + 0];
		var totalCount = rsBlock[i * 3 + 1];
		var dataCount  = rsBlock[i * 3 + 2];

		for (var j = 0; j < count; j++) {
			list.push(new QRRSBlock(totalCount, dataCount) );	
		}
	}
	
	return list;
}

QRRSBlock.getRsBlockTable = function(typeNumber, errorCorrectLevel) {

	switch(errorCorrectLevel) {
	case QRErrorCorrectLevel.L :
		return QRRSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 0];
	case QRErrorCorrectLevel.M :
		return QRRSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 1];
	case QRErrorCorrectLevel.Q :
		return QRRSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 2];
	case QRErrorCorrectLevel.H :
		return QRRSBlock.RS_BLOCK_TABLE[(typeNumber - 1) * 4 + 3];
	default :
		return undefined;
	}
}

//---------------------------------------------------------------------
// QRBitBuffer
//---------------------------------------------------------------------

function QRBitBuffer() {
	this.buffer = new Array();
	this.length = 0;
}

QRBitBuffer.prototype = {

	get : function(index) {
		var bufIndex = Math.floor(index / 8);
		return ( (this.buffer[bufIndex] >>> (7 - index % 8) ) & 1) == 1;
	},
	
	put : function(num, length) {
		for (var i = 0; i < length; i++) {
			this.putBit( ( (num >>> (length - i - 1) ) & 1) == 1);
		}
	},
	
	getLengthInBits : function() {
		return this.length;
	},
	
	putBit : function(bit) {
	
		var bufIndex = Math.floor(this.length / 8);
		if (this.buffer.length <= bufIndex) {
			this.buffer.push(0);
		}
	
		if (bit) {
			this.buffer[bufIndex] |= (0x80 >>> (this.length % 8) );
		}
	
		this.length++;
	}
};

/*
 * $Id: rawdeflate.js,v 0.5 2013/04/09 14:25:38 dankogai Exp dankogai $
 *
 * GNU General Public License, version 2 (GPL-2.0)
 *   http://opensource.org/licenses/GPL-2.0
 * Original:
 *  http://www.onicos.com/staff/iz/amuse/javascript/expert/deflate.txt
 */

(function(ctx){

/* Copyright (C) 1999 Masanao Izumo <iz@onicos.co.jp>
 * Version: 1.0.1
 * LastModified: Dec 25 1999
 */

/* Interface:
 * data = zip_deflate(src);
 */

/* constant parameters */
var zip_WSIZE = 32768;		// Sliding Window size
var zip_STORED_BLOCK = 0;
var zip_STATIC_TREES = 1;
var zip_DYN_TREES    = 2;

/* for deflate */
var zip_DEFAULT_LEVEL = 6;
var zip_FULL_SEARCH = true;
var zip_INBUFSIZ = 32768;	// Input buffer size
var zip_INBUF_EXTRA = 64;	// Extra buffer
var zip_OUTBUFSIZ = 1024 * 8;
var zip_window_size = 2 * zip_WSIZE;
var zip_MIN_MATCH = 3;
var zip_MAX_MATCH = 258;
var zip_BITS = 16;
// for SMALL_MEM
var zip_LIT_BUFSIZE = 0x2000;
var zip_HASH_BITS = 13;
// for MEDIUM_MEM
// var zip_LIT_BUFSIZE = 0x4000;
// var zip_HASH_BITS = 14;
// for BIG_MEM
// var zip_LIT_BUFSIZE = 0x8000;
// var zip_HASH_BITS = 15;
if(zip_LIT_BUFSIZE > zip_INBUFSIZ)
    alert("error: zip_INBUFSIZ is too small");
if((zip_WSIZE<<1) > (1<<zip_BITS))
    alert("error: zip_WSIZE is too large");
if(zip_HASH_BITS > zip_BITS-1)
    alert("error: zip_HASH_BITS is too large");
if(zip_HASH_BITS < 8 || zip_MAX_MATCH != 258)
    alert("error: Code too clever");
var zip_DIST_BUFSIZE = zip_LIT_BUFSIZE;
var zip_HASH_SIZE = 1 << zip_HASH_BITS;
var zip_HASH_MASK = zip_HASH_SIZE - 1;
var zip_WMASK = zip_WSIZE - 1;
var zip_NIL = 0; // Tail of hash chains
var zip_TOO_FAR = 4096;
var zip_MIN_LOOKAHEAD = zip_MAX_MATCH + zip_MIN_MATCH + 1;
var zip_MAX_DIST = zip_WSIZE - zip_MIN_LOOKAHEAD;
var zip_SMALLEST = 1;
var zip_MAX_BITS = 15;
var zip_MAX_BL_BITS = 7;
var zip_LENGTH_CODES = 29;
var zip_LITERALS =256;
var zip_END_BLOCK = 256;
var zip_L_CODES = zip_LITERALS + 1 + zip_LENGTH_CODES;
var zip_D_CODES = 30;
var zip_BL_CODES = 19;
var zip_REP_3_6 = 16;
var zip_REPZ_3_10 = 17;
var zip_REPZ_11_138 = 18;
var zip_HEAP_SIZE = 2 * zip_L_CODES + 1;
var zip_H_SHIFT = parseInt((zip_HASH_BITS + zip_MIN_MATCH - 1) /
			   zip_MIN_MATCH);

/* variables */
var zip_free_queue;
var zip_qhead, zip_qtail;
var zip_initflag;
var zip_outbuf = null;
var zip_outcnt, zip_outoff;
var zip_complete;
var zip_window;
var zip_d_buf;
var zip_l_buf;
var zip_prev;
var zip_bi_buf;
var zip_bi_valid;
var zip_block_start;
var zip_ins_h;
var zip_hash_head;
var zip_prev_match;
var zip_match_available;
var zip_match_length;
var zip_prev_length;
var zip_strstart;
var zip_match_start;
var zip_eofile;
var zip_lookahead;
var zip_max_chain_length;
var zip_max_lazy_match;
var zip_compr_level;
var zip_good_match;
var zip_nice_match;
var zip_dyn_ltree;
var zip_dyn_dtree;
var zip_static_ltree;
var zip_static_dtree;
var zip_bl_tree;
var zip_l_desc;
var zip_d_desc;
var zip_bl_desc;
var zip_bl_count;
var zip_heap;
var zip_heap_len;
var zip_heap_max;
var zip_depth;
var zip_length_code;
var zip_dist_code;
var zip_base_length;
var zip_base_dist;
var zip_flag_buf;
var zip_last_lit;
var zip_last_dist;
var zip_last_flags;
var zip_flags;
var zip_flag_bit;
var zip_opt_len;
var zip_static_len;
var zip_deflate_data;
var zip_deflate_pos;

/* objects (deflate) */

var zip_DeflateCT = function() {
    this.fc = 0; // frequency count or bit string
    this.dl = 0; // father node in Huffman tree or length of bit string
}

var zip_DeflateTreeDesc = function() {
    this.dyn_tree = null;	// the dynamic tree
    this.static_tree = null;	// corresponding static tree or NULL
    this.extra_bits = null;	// extra bits for each code or NULL
    this.extra_base = 0;	// base index for extra_bits
    this.elems = 0;		// max number of elements in the tree
    this.max_length = 0;	// max bit length for the codes
    this.max_code = 0;		// largest code with non zero frequency
}

/* Values for max_lazy_match, good_match and max_chain_length, depending on
 * the desired pack level (0..9). The values given below have been tuned to
 * exclude worst case performance for pathological files. Better values may be
 * found for specific files.
 */
var zip_DeflateConfiguration = function(a, b, c, d) {
    this.good_length = a; // reduce lazy search above this match length
    this.max_lazy = b;    // do not perform lazy search above this match length
    this.nice_length = c; // quit search above this match length
    this.max_chain = d;
}

var zip_DeflateBuffer = function() {
    this.next = null;
    this.len = 0;
    this.ptr = new Array(zip_OUTBUFSIZ);
    this.off = 0;
}

/* constant tables */
var zip_extra_lbits = new Array(
    0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0);
var zip_extra_dbits = new Array(
    0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13);
var zip_extra_blbits = new Array(
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,7);
var zip_bl_order = new Array(
    16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15);
var zip_configuration_table = new Array(
	new zip_DeflateConfiguration(0,    0,   0,    0),
	new zip_DeflateConfiguration(4,    4,   8,    4),
	new zip_DeflateConfiguration(4,    5,  16,    8),
	new zip_DeflateConfiguration(4,    6,  32,   32),
	new zip_DeflateConfiguration(4,    4,  16,   16),
	new zip_DeflateConfiguration(8,   16,  32,   32),
	new zip_DeflateConfiguration(8,   16, 128,  128),
	new zip_DeflateConfiguration(8,   32, 128,  256),
	new zip_DeflateConfiguration(32, 128, 258, 1024),
	new zip_DeflateConfiguration(32, 258, 258, 4096));


/* routines (deflate) */

var zip_deflate_start = function(level) {
    var i;

    if(!level)
	level = zip_DEFAULT_LEVEL;
    else if(level < 1)
	level = 1;
    else if(level > 9)
	level = 9;

    zip_compr_level = level;
    zip_initflag = false;
    zip_eofile = false;
    if(zip_outbuf != null)
	return;

    zip_free_queue = zip_qhead = zip_qtail = null;
    zip_outbuf = new Array(zip_OUTBUFSIZ);
    zip_window = new Array(zip_window_size);
    zip_d_buf = new Array(zip_DIST_BUFSIZE);
    zip_l_buf = new Array(zip_INBUFSIZ + zip_INBUF_EXTRA);
    zip_prev = new Array(1 << zip_BITS);
    zip_dyn_ltree = new Array(zip_HEAP_SIZE);
    for(i = 0; i < zip_HEAP_SIZE; i++)
	zip_dyn_ltree[i] = new zip_DeflateCT();
    zip_dyn_dtree = new Array(2*zip_D_CODES+1);
    for(i = 0; i < 2*zip_D_CODES+1; i++)
	zip_dyn_dtree[i] = new zip_DeflateCT();
    zip_static_ltree = new Array(zip_L_CODES+2);
    for(i = 0; i < zip_L_CODES+2; i++)
	zip_static_ltree[i] = new zip_DeflateCT();
    zip_static_dtree = new Array(zip_D_CODES);
    for(i = 0; i < zip_D_CODES; i++)
	zip_static_dtree[i] = new zip_DeflateCT();
    zip_bl_tree = new Array(2*zip_BL_CODES+1);
    for(i = 0; i < 2*zip_BL_CODES+1; i++)
	zip_bl_tree[i] = new zip_DeflateCT();
    zip_l_desc = new zip_DeflateTreeDesc();
    zip_d_desc = new zip_DeflateTreeDesc();
    zip_bl_desc = new zip_DeflateTreeDesc();
    zip_bl_count = new Array(zip_MAX_BITS+1);
    zip_heap = new Array(2*zip_L_CODES+1);
    zip_depth = new Array(2*zip_L_CODES+1);
    zip_length_code = new Array(zip_MAX_MATCH-zip_MIN_MATCH+1);
    zip_dist_code = new Array(512);
    zip_base_length = new Array(zip_LENGTH_CODES);
    zip_base_dist = new Array(zip_D_CODES);
    zip_flag_buf = new Array(parseInt(zip_LIT_BUFSIZE / 8));
}

var zip_deflate_end = function() {
    zip_free_queue = zip_qhead = zip_qtail = null;
    zip_outbuf = null;
    zip_window = null;
    zip_d_buf = null;
    zip_l_buf = null;
    zip_prev = null;
    zip_dyn_ltree = null;
    zip_dyn_dtree = null;
    zip_static_ltree = null;
    zip_static_dtree = null;
    zip_bl_tree = null;
    zip_l_desc = null;
    zip_d_desc = null;
    zip_bl_desc = null;
    zip_bl_count = null;
    zip_heap = null;
    zip_depth = null;
    zip_length_code = null;
    zip_dist_code = null;
    zip_base_length = null;
    zip_base_dist = null;
    zip_flag_buf = null;
}

var zip_reuse_queue = function(p) {
    p.next = zip_free_queue;
    zip_free_queue = p;
}

var zip_new_queue = function() {
    var p;

    if(zip_free_queue != null)
    {
	p = zip_free_queue;
	zip_free_queue = zip_free_queue.next;
    }
    else
	p = new zip_DeflateBuffer();
    p.next = null;
    p.len = p.off = 0;

    return p;
}

var zip_head1 = function(i) {
    return zip_prev[zip_WSIZE + i];
}

var zip_head2 = function(i, val) {
    return zip_prev[zip_WSIZE + i] = val;
}

/* put_byte is used for the compressed output, put_ubyte for the
 * uncompressed output. However unlzw() uses window for its
 * suffix table instead of its output buffer, so it does not use put_ubyte
 * (to be cleaned up).
 */
var zip_put_byte = function(c) {
    zip_outbuf[zip_outoff + zip_outcnt++] = c;
    if(zip_outoff + zip_outcnt == zip_OUTBUFSIZ)
	zip_qoutbuf();
}

/* Output a 16 bit value, lsb first */
var zip_put_short = function(w) {
    w &= 0xffff;
    if(zip_outoff + zip_outcnt < zip_OUTBUFSIZ - 2) {
	zip_outbuf[zip_outoff + zip_outcnt++] = (w & 0xff);
	zip_outbuf[zip_outoff + zip_outcnt++] = (w >>> 8);
    } else {
	zip_put_byte(w & 0xff);
	zip_put_byte(w >>> 8);
    }
}

/* ==========================================================================
 * Insert string s in the dictionary and set match_head to the previous head
 * of the hash chain (the most recent string with same hash key). Return
 * the previous length of the hash chain.
 * IN  assertion: all calls to to INSERT_STRING are made with consecutive
 *    input characters and the first MIN_MATCH bytes of s are valid
 *    (except for the last MIN_MATCH-1 bytes of the input file).
 */
var zip_INSERT_STRING = function() {
    zip_ins_h = ((zip_ins_h << zip_H_SHIFT)
		 ^ (zip_window[zip_strstart + zip_MIN_MATCH - 1] & 0xff))
	& zip_HASH_MASK;
    zip_hash_head = zip_head1(zip_ins_h);
    zip_prev[zip_strstart & zip_WMASK] = zip_hash_head;
    zip_head2(zip_ins_h, zip_strstart);
}

/* Send a code of the given tree. c and tree must not have side effects */
var zip_SEND_CODE = function(c, tree) {
    zip_send_bits(tree[c].fc, tree[c].dl);
}

/* Mapping from a distance to a distance code. dist is the distance - 1 and
 * must not have side effects. dist_code[256] and dist_code[257] are never
 * used.
 */
var zip_D_CODE = function(dist) {
    return (dist < 256 ? zip_dist_code[dist]
	    : zip_dist_code[256 + (dist>>7)]) & 0xff;
}

/* ==========================================================================
 * Compares to subtrees, using the tree depth as tie breaker when
 * the subtrees have equal frequency. This minimizes the worst case length.
 */
var zip_SMALLER = function(tree, n, m) {
    return tree[n].fc < tree[m].fc ||
      (tree[n].fc == tree[m].fc && zip_depth[n] <= zip_depth[m]);
}

/* ==========================================================================
 * read string data
 */
var zip_read_buff = function(buff, offset, n) {
    var i;
    for(i = 0; i < n && zip_deflate_pos < zip_deflate_data.length; i++)
	buff[offset + i] =
	    zip_deflate_data.charCodeAt(zip_deflate_pos++) & 0xff;
    return i;
}

/* ==========================================================================
 * Initialize the "longest match" routines for a new file
 */
var zip_lm_init = function() {
    var j;

    /* Initialize the hash table. */
    for(j = 0; j < zip_HASH_SIZE; j++)
//	zip_head2(j, zip_NIL);
	zip_prev[zip_WSIZE + j] = 0;
    /* prev will be initialized on the fly */

    /* Set the default configuration parameters:
     */
    zip_max_lazy_match = zip_configuration_table[zip_compr_level].max_lazy;
    zip_good_match     = zip_configuration_table[zip_compr_level].good_length;
    if(!zip_FULL_SEARCH)
	zip_nice_match = zip_configuration_table[zip_compr_level].nice_length;
    zip_max_chain_length = zip_configuration_table[zip_compr_level].max_chain;

    zip_strstart = 0;
    zip_block_start = 0;

    zip_lookahead = zip_read_buff(zip_window, 0, 2 * zip_WSIZE);
    if(zip_lookahead <= 0) {
	zip_eofile = true;
	zip_lookahead = 0;
	return;
    }
    zip_eofile = false;
    /* Make sure that we always have enough lookahead. This is important
     * if input comes from a device such as a tty.
     */
    while(zip_lookahead < zip_MIN_LOOKAHEAD && !zip_eofile)
	zip_fill_window();

    /* If lookahead < MIN_MATCH, ins_h is garbage, but this is
     * not important since only literal bytes will be emitted.
     */
    zip_ins_h = 0;
    for(j = 0; j < zip_MIN_MATCH - 1; j++) {
//      UPDATE_HASH(ins_h, window[j]);
	zip_ins_h = ((zip_ins_h << zip_H_SHIFT) ^ (zip_window[j] & 0xff)) & zip_HASH_MASK;
    }
}

/* ==========================================================================
 * Set match_start to the longest match starting at the given string and
 * return its length. Matches shorter or equal to prev_length are discarded,
 * in which case the result is equal to prev_length and match_start is
 * garbage.
 * IN assertions: cur_match is the head of the hash chain for the current
 *   string (strstart) and its distance is <= MAX_DIST, and prev_length >= 1
 */
var zip_longest_match = function(cur_match) {
    var chain_length = zip_max_chain_length; // max hash chain length
    var scanp = zip_strstart; // current string
    var matchp;		// matched string
    var len;		// length of current match
    var best_len = zip_prev_length;	// best match length so far

    /* Stop when cur_match becomes <= limit. To simplify the code,
     * we prevent matches with the string of window index 0.
     */
    var limit = (zip_strstart > zip_MAX_DIST ? zip_strstart - zip_MAX_DIST : zip_NIL);

    var strendp = zip_strstart + zip_MAX_MATCH;
    var scan_end1 = zip_window[scanp + best_len - 1];
    var scan_end  = zip_window[scanp + best_len];

    /* Do not waste too much time if we already have a good match: */
    if(zip_prev_length >= zip_good_match)
	chain_length >>= 2;

//  Assert(encoder->strstart <= window_size-MIN_LOOKAHEAD, "insufficient lookahead");

    do {
//    Assert(cur_match < encoder->strstart, "no future");
	matchp = cur_match;

	/* Skip to next match if the match length cannot increase
	    * or if the match length is less than 2:
	*/
	if(zip_window[matchp + best_len]	!= scan_end  ||
	   zip_window[matchp + best_len - 1]	!= scan_end1 ||
	   zip_window[matchp]			!= zip_window[scanp] ||
	   zip_window[++matchp]			!= zip_window[scanp + 1]) {
	    continue;
	}

	/* The check at best_len-1 can be removed because it will be made
         * again later. (This heuristic is not always a win.)
         * It is not necessary to compare scan[2] and match[2] since they
         * are always equal when the other bytes match, given that
         * the hash keys are equal and that HASH_BITS >= 8.
         */
	scanp += 2;
	matchp++;

	/* We check for insufficient lookahead only every 8th comparison;
         * the 256th check will be made at strstart+258.
         */
	do {
	} while(zip_window[++scanp] == zip_window[++matchp] &&
		zip_window[++scanp] == zip_window[++matchp] &&
		zip_window[++scanp] == zip_window[++matchp] &&
		zip_window[++scanp] == zip_window[++matchp] &&
		zip_window[++scanp] == zip_window[++matchp] &&
		zip_window[++scanp] == zip_window[++matchp] &&
		zip_window[++scanp] == zip_window[++matchp] &&
		zip_window[++scanp] == zip_window[++matchp] &&
		scanp < strendp);

      len = zip_MAX_MATCH - (strendp - scanp);
      scanp = strendp - zip_MAX_MATCH;

      if(len > best_len) {
	  zip_match_start = cur_match;
	  best_len = len;
	  if(zip_FULL_SEARCH) {
	      if(len >= zip_MAX_MATCH) break;
	  } else {
	      if(len >= zip_nice_match) break;
	  }

	  scan_end1  = zip_window[scanp + best_len-1];
	  scan_end   = zip_window[scanp + best_len];
      }
    } while((cur_match = zip_prev[cur_match & zip_WMASK]) > limit
	    && --chain_length != 0);

    return best_len;
}

/* ==========================================================================
 * Fill the window when the lookahead becomes insufficient.
 * Updates strstart and lookahead, and sets eofile if end of input file.
 * IN assertion: lookahead < MIN_LOOKAHEAD && strstart + lookahead > 0
 * OUT assertions: at least one byte has been read, or eofile is set;
 *    file reads are performed for at least two bytes (required for the
 *    translate_eol option).
 */
var zip_fill_window = function() {
    var n, m;

    // Amount of free space at the end of the window.
    var more = zip_window_size - zip_lookahead - zip_strstart;

    /* If the window is almost full and there is insufficient lookahead,
     * move the upper half to the lower one to make room in the upper half.
     */
    if(more == -1) {
	/* Very unlikely, but possible on 16 bit machine if strstart == 0
         * and lookahead == 1 (input done one byte at time)
         */
	more--;
    } else if(zip_strstart >= zip_WSIZE + zip_MAX_DIST) {
	/* By the IN assertion, the window is not empty so we can't confuse
         * more == 0 with more == 64K on a 16 bit machine.
         */
//	Assert(window_size == (ulg)2*WSIZE, "no sliding with BIG_MEM");

//	System.arraycopy(window, WSIZE, window, 0, WSIZE);
	for(n = 0; n < zip_WSIZE; n++)
	    zip_window[n] = zip_window[n + zip_WSIZE];

	zip_match_start -= zip_WSIZE;
	zip_strstart    -= zip_WSIZE; /* we now have strstart >= MAX_DIST: */
	zip_block_start -= zip_WSIZE;

	for(n = 0; n < zip_HASH_SIZE; n++) {
	    m = zip_head1(n);
	    zip_head2(n, m >= zip_WSIZE ? m - zip_WSIZE : zip_NIL);
	}
	for(n = 0; n < zip_WSIZE; n++) {
	    /* If n is not on any hash chain, prev[n] is garbage but
	     * its value will never be used.
	     */
	    m = zip_prev[n];
	    zip_prev[n] = (m >= zip_WSIZE ? m - zip_WSIZE : zip_NIL);
	}
	more += zip_WSIZE;
    }
    // At this point, more >= 2
    if(!zip_eofile) {
	n = zip_read_buff(zip_window, zip_strstart + zip_lookahead, more);
	if(n <= 0)
	    zip_eofile = true;
	else
	    zip_lookahead += n;
    }
}

/* ==========================================================================
 * Processes a new input file and return its compressed length. This
 * function does not perform lazy evaluationof matches and inserts
 * new strings in the dictionary only for unmatched strings or for short
 * matches. It is used only for the fast compression options.
 */
var zip_deflate_fast = function() {
    while(zip_lookahead != 0 && zip_qhead == null) {
	var flush; // set if current block must be flushed

	/* Insert the string window[strstart .. strstart+2] in the
	 * dictionary, and set hash_head to the head of the hash chain:
	 */
	zip_INSERT_STRING();

	/* Find the longest match, discarding those <= prev_length.
	 * At this point we have always match_length < MIN_MATCH
	 */
	if(zip_hash_head != zip_NIL &&
	   zip_strstart - zip_hash_head <= zip_MAX_DIST) {
	    /* To simplify the code, we prevent matches with the string
	     * of window index 0 (in particular we have to avoid a match
	     * of the string with itself at the start of the input file).
	     */
	    zip_match_length = zip_longest_match(zip_hash_head);
	    /* longest_match() sets match_start */
	    if(zip_match_length > zip_lookahead)
		zip_match_length = zip_lookahead;
	}
	if(zip_match_length >= zip_MIN_MATCH) {
//	    check_match(strstart, match_start, match_length);

	    flush = zip_ct_tally(zip_strstart - zip_match_start,
				 zip_match_length - zip_MIN_MATCH);
	    zip_lookahead -= zip_match_length;

	    /* Insert new strings in the hash table only if the match length
	     * is not too large. This saves time but degrades compression.
	     */
	    if(zip_match_length <= zip_max_lazy_match) {
		zip_match_length--; // string at strstart already in hash table
		do {
		    zip_strstart++;
		    zip_INSERT_STRING();
		    /* strstart never exceeds WSIZE-MAX_MATCH, so there are
		     * always MIN_MATCH bytes ahead. If lookahead < MIN_MATCH
		     * these bytes are garbage, but it does not matter since
		     * the next lookahead bytes will be emitted as literals.
		     */
		} while(--zip_match_length != 0);
		zip_strstart++;
	    } else {
		zip_strstart += zip_match_length;
		zip_match_length = 0;
		zip_ins_h = zip_window[zip_strstart] & 0xff;
//		UPDATE_HASH(ins_h, window[strstart + 1]);
		zip_ins_h = ((zip_ins_h<<zip_H_SHIFT) ^ (zip_window[zip_strstart + 1] & 0xff)) & zip_HASH_MASK;

//#if MIN_MATCH != 3
//		Call UPDATE_HASH() MIN_MATCH-3 more times
//#endif

	    }
	} else {
	    /* No match, output a literal byte */
	    flush = zip_ct_tally(0, zip_window[zip_strstart] & 0xff);
	    zip_lookahead--;
	    zip_strstart++;
	}
	if(flush) {
	    zip_flush_block(0);
	    zip_block_start = zip_strstart;
	}

	/* Make sure that we always have enough lookahead, except
	 * at the end of the input file. We need MAX_MATCH bytes
	 * for the next match, plus MIN_MATCH bytes to insert the
	 * string following the next match.
	 */
	while(zip_lookahead < zip_MIN_LOOKAHEAD && !zip_eofile)
	    zip_fill_window();
    }
}

var zip_deflate_better = function() {
    /* Process the input block. */
    while(zip_lookahead != 0 && zip_qhead == null) {
	/* Insert the string window[strstart .. strstart+2] in the
	 * dictionary, and set hash_head to the head of the hash chain:
	 */
	zip_INSERT_STRING();

	/* Find the longest match, discarding those <= prev_length.
	 */
	zip_prev_length = zip_match_length;
	zip_prev_match = zip_match_start;
	zip_match_length = zip_MIN_MATCH - 1;

	if(zip_hash_head != zip_NIL &&
	   zip_prev_length < zip_max_lazy_match &&
	   zip_strstart - zip_hash_head <= zip_MAX_DIST) {
	    /* To simplify the code, we prevent matches with the string
	     * of window index 0 (in particular we have to avoid a match
	     * of the string with itself at the start of the input file).
	     */
	    zip_match_length = zip_longest_match(zip_hash_head);
	    /* longest_match() sets match_start */
	    if(zip_match_length > zip_lookahead)
		zip_match_length = zip_lookahead;

	    /* Ignore a length 3 match if it is too distant: */
	    if(zip_match_length == zip_MIN_MATCH &&
	       zip_strstart - zip_match_start > zip_TOO_FAR) {
		/* If prev_match is also MIN_MATCH, match_start is garbage
		 * but we will ignore the current match anyway.
		 */
		zip_match_length--;
	    }
	}
	/* If there was a match at the previous step and the current
	 * match is not better, output the previous match:
	 */
	if(zip_prev_length >= zip_MIN_MATCH &&
	   zip_match_length <= zip_prev_length) {
	    var flush; // set if current block must be flushed

//	    check_match(strstart - 1, prev_match, prev_length);
	    flush = zip_ct_tally(zip_strstart - 1 - zip_prev_match,
				 zip_prev_length - zip_MIN_MATCH);

	    /* Insert in hash table all strings up to the end of the match.
	     * strstart-1 and strstart are already inserted.
	     */
	    zip_lookahead -= zip_prev_length - 1;
	    zip_prev_length -= 2;
	    do {
		zip_strstart++;
		zip_INSERT_STRING();
		/* strstart never exceeds WSIZE-MAX_MATCH, so there are
		 * always MIN_MATCH bytes ahead. If lookahead < MIN_MATCH
		 * these bytes are garbage, but it does not matter since the
		 * next lookahead bytes will always be emitted as literals.
		 */
	    } while(--zip_prev_length != 0);
	    zip_match_available = 0;
	    zip_match_length = zip_MIN_MATCH - 1;
	    zip_strstart++;
	    if(flush) {
		zip_flush_block(0);
		zip_block_start = zip_strstart;
	    }
	} else if(zip_match_available != 0) {
	    /* If there was no match at the previous position, output a
	     * single literal. If there was a match but the current match
	     * is longer, truncate the previous match to a single literal.
	     */
	    if(zip_ct_tally(0, zip_window[zip_strstart - 1] & 0xff)) {
		zip_flush_block(0);
		zip_block_start = zip_strstart;
	    }
	    zip_strstart++;
	    zip_lookahead--;
	} else {
	    /* There is no previous match to compare with, wait for
	     * the next step to decide.
	     */
	    zip_match_available = 1;
	    zip_strstart++;
	    zip_lookahead--;
	}

	/* Make sure that we always have enough lookahead, except
	 * at the end of the input file. We need MAX_MATCH bytes
	 * for the next match, plus MIN_MATCH bytes to insert the
	 * string following the next match.
	 */
	while(zip_lookahead < zip_MIN_LOOKAHEAD && !zip_eofile)
	    zip_fill_window();
    }
}

var zip_init_deflate = function() {
    if(zip_eofile)
	return;
    zip_bi_buf = 0;
    zip_bi_valid = 0;
    zip_ct_init();
    zip_lm_init();

    zip_qhead = null;
    zip_outcnt = 0;
    zip_outoff = 0;
    zip_match_available = 0;

    if(zip_compr_level <= 3)
    {
	zip_prev_length = zip_MIN_MATCH - 1;
	zip_match_length = 0;
    }
    else
    {
	zip_match_length = zip_MIN_MATCH - 1;
	zip_match_available = 0;
        zip_match_available = 0;
    }

    zip_complete = false;
}

/* ==========================================================================
 * Same as above, but achieves better compression. We use a lazy
 * evaluation for matches: a match is finally adopted only if there is
 * no better match at the next window position.
 */
var zip_deflate_internal = function(buff, off, buff_size) {
    var n;

    if(!zip_initflag)
    {
	zip_init_deflate();
	zip_initflag = true;
	if(zip_lookahead == 0) { // empty
	    zip_complete = true;
	    return 0;
	}
    }

    if((n = zip_qcopy(buff, off, buff_size)) == buff_size)
	return buff_size;

    if(zip_complete)
	return n;

    if(zip_compr_level <= 3) // optimized for speed
	zip_deflate_fast();
    else
	zip_deflate_better();
    if(zip_lookahead == 0) {
	if(zip_match_available != 0)
	    zip_ct_tally(0, zip_window[zip_strstart - 1] & 0xff);
	zip_flush_block(1);
	zip_complete = true;
    }
    return n + zip_qcopy(buff, n + off, buff_size - n);
}

var zip_qcopy = function(buff, off, buff_size) {
    var n, i, j;

    n = 0;
    while(zip_qhead != null && n < buff_size)
    {
	i = buff_size - n;
	if(i > zip_qhead.len)
	    i = zip_qhead.len;
//      System.arraycopy(qhead.ptr, qhead.off, buff, off + n, i);
	for(j = 0; j < i; j++)
	    buff[off + n + j] = zip_qhead.ptr[zip_qhead.off + j];

	zip_qhead.off += i;
	zip_qhead.len -= i;
	n += i;
	if(zip_qhead.len == 0) {
	    var p;
	    p = zip_qhead;
	    zip_qhead = zip_qhead.next;
	    zip_reuse_queue(p);
	}
    }

    if(n == buff_size)
	return n;

    if(zip_outoff < zip_outcnt) {
	i = buff_size - n;
	if(i > zip_outcnt - zip_outoff)
	    i = zip_outcnt - zip_outoff;
	// System.arraycopy(outbuf, outoff, buff, off + n, i);
	for(j = 0; j < i; j++)
	    buff[off + n + j] = zip_outbuf[zip_outoff + j];
	zip_outoff += i;
	n += i;
	if(zip_outcnt == zip_outoff)
	    zip_outcnt = zip_outoff = 0;
    }
    return n;
}

/* ==========================================================================
 * Allocate the match buffer, initialize the various tables and save the
 * location of the internal file attribute (ascii/binary) and method
 * (DEFLATE/STORE).
 */
var zip_ct_init = function() {
    var n;	// iterates over tree elements
    var bits;	// bit counter
    var length;	// length value
    var code;	// code value
    var dist;	// distance index

    if(zip_static_dtree[0].dl != 0) return; // ct_init already called

    zip_l_desc.dyn_tree		= zip_dyn_ltree;
    zip_l_desc.static_tree	= zip_static_ltree;
    zip_l_desc.extra_bits	= zip_extra_lbits;
    zip_l_desc.extra_base	= zip_LITERALS + 1;
    zip_l_desc.elems		= zip_L_CODES;
    zip_l_desc.max_length	= zip_MAX_BITS;
    zip_l_desc.max_code		= 0;

    zip_d_desc.dyn_tree		= zip_dyn_dtree;
    zip_d_desc.static_tree	= zip_static_dtree;
    zip_d_desc.extra_bits	= zip_extra_dbits;
    zip_d_desc.extra_base	= 0;
    zip_d_desc.elems		= zip_D_CODES;
    zip_d_desc.max_length	= zip_MAX_BITS;
    zip_d_desc.max_code		= 0;

    zip_bl_desc.dyn_tree	= zip_bl_tree;
    zip_bl_desc.static_tree	= null;
    zip_bl_desc.extra_bits	= zip_extra_blbits;
    zip_bl_desc.extra_base	= 0;
    zip_bl_desc.elems		= zip_BL_CODES;
    zip_bl_desc.max_length	= zip_MAX_BL_BITS;
    zip_bl_desc.max_code	= 0;

    // Initialize the mapping length (0..255) -> length code (0..28)
    length = 0;
    for(code = 0; code < zip_LENGTH_CODES-1; code++) {
	zip_base_length[code] = length;
	for(n = 0; n < (1<<zip_extra_lbits[code]); n++)
	    zip_length_code[length++] = code;
    }
    // Assert (length == 256, "ct_init: length != 256");

    /* Note that the length 255 (match length 258) can be represented
     * in two different ways: code 284 + 5 bits or code 285, so we
     * overwrite length_code[255] to use the best encoding:
     */
    zip_length_code[length-1] = code;

    /* Initialize the mapping dist (0..32K) -> dist code (0..29) */
    dist = 0;
    for(code = 0 ; code < 16; code++) {
	zip_base_dist[code] = dist;
	for(n = 0; n < (1<<zip_extra_dbits[code]); n++) {
	    zip_dist_code[dist++] = code;
	}
    }
    // Assert (dist == 256, "ct_init: dist != 256");
    dist >>= 7; // from now on, all distances are divided by 128
    for( ; code < zip_D_CODES; code++) {
	zip_base_dist[code] = dist << 7;
	for(n = 0; n < (1<<(zip_extra_dbits[code]-7)); n++)
	    zip_dist_code[256 + dist++] = code;
    }
    // Assert (dist == 256, "ct_init: 256+dist != 512");

    // Construct the codes of the static literal tree
    for(bits = 0; bits <= zip_MAX_BITS; bits++)
	zip_bl_count[bits] = 0;
    n = 0;
    while(n <= 143) { zip_static_ltree[n++].dl = 8; zip_bl_count[8]++; }
    while(n <= 255) { zip_static_ltree[n++].dl = 9; zip_bl_count[9]++; }
    while(n <= 279) { zip_static_ltree[n++].dl = 7; zip_bl_count[7]++; }
    while(n <= 287) { zip_static_ltree[n++].dl = 8; zip_bl_count[8]++; }
    /* Codes 286 and 287 do not exist, but we must include them in the
     * tree construction to get a canonical Huffman tree (longest code
     * all ones)
     */
    zip_gen_codes(zip_static_ltree, zip_L_CODES + 1);

    /* The static distance tree is trivial: */
    for(n = 0; n < zip_D_CODES; n++) {
	zip_static_dtree[n].dl = 5;
	zip_static_dtree[n].fc = zip_bi_reverse(n, 5);
    }

    // Initialize the first block of the first file:
    zip_init_block();
}

/* ==========================================================================
 * Initialize a new block.
 */
var zip_init_block = function() {
    var n; // iterates over tree elements

    // Initialize the trees.
    for(n = 0; n < zip_L_CODES;  n++) zip_dyn_ltree[n].fc = 0;
    for(n = 0; n < zip_D_CODES;  n++) zip_dyn_dtree[n].fc = 0;
    for(n = 0; n < zip_BL_CODES; n++) zip_bl_tree[n].fc = 0;

    zip_dyn_ltree[zip_END_BLOCK].fc = 1;
    zip_opt_len = zip_static_len = 0;
    zip_last_lit = zip_last_dist = zip_last_flags = 0;
    zip_flags = 0;
    zip_flag_bit = 1;
}

/* ==========================================================================
 * Restore the heap property by moving down the tree starting at node k,
 * exchanging a node with the smallest of its two sons if necessary, stopping
 * when the heap property is re-established (each father smaller than its
 * two sons).
 */
var zip_pqdownheap = function(
    tree,	// the tree to restore
    k) {	// node to move down
    var v = zip_heap[k];
    var j = k << 1;	// left son of k

    while(j <= zip_heap_len) {
	// Set j to the smallest of the two sons:
	if(j < zip_heap_len &&
	   zip_SMALLER(tree, zip_heap[j + 1], zip_heap[j]))
	    j++;

	// Exit if v is smaller than both sons
	if(zip_SMALLER(tree, v, zip_heap[j]))
	    break;

	// Exchange v with the smallest son
	zip_heap[k] = zip_heap[j];
	k = j;

	// And continue down the tree, setting j to the left son of k
	j <<= 1;
    }
    zip_heap[k] = v;
}

/* ==========================================================================
 * Compute the optimal bit lengths for a tree and update the total bit length
 * for the current block.
 * IN assertion: the fields freq and dad are set, heap[heap_max] and
 *    above are the tree nodes sorted by increasing frequency.
 * OUT assertions: the field len is set to the optimal bit length, the
 *     array bl_count contains the frequencies for each bit length.
 *     The length opt_len is updated; static_len is also updated if stree is
 *     not null.
 */
var zip_gen_bitlen = function(desc) { // the tree descriptor
    var tree		= desc.dyn_tree;
    var extra		= desc.extra_bits;
    var base		= desc.extra_base;
    var max_code	= desc.max_code;
    var max_length	= desc.max_length;
    var stree		= desc.static_tree;
    var h;		// heap index
    var n, m;		// iterate over the tree elements
    var bits;		// bit length
    var xbits;		// extra bits
    var f;		// frequency
    var overflow = 0;	// number of elements with bit length too large

    for(bits = 0; bits <= zip_MAX_BITS; bits++)
	zip_bl_count[bits] = 0;

    /* In a first pass, compute the optimal bit lengths (which may
     * overflow in the case of the bit length tree).
     */
    tree[zip_heap[zip_heap_max]].dl = 0; // root of the heap

    for(h = zip_heap_max + 1; h < zip_HEAP_SIZE; h++) {
	n = zip_heap[h];
	bits = tree[tree[n].dl].dl + 1;
	if(bits > max_length) {
	    bits = max_length;
	    overflow++;
	}
	tree[n].dl = bits;
	// We overwrite tree[n].dl which is no longer needed

	if(n > max_code)
	    continue; // not a leaf node

	zip_bl_count[bits]++;
	xbits = 0;
	if(n >= base)
	    xbits = extra[n - base];
	f = tree[n].fc;
	zip_opt_len += f * (bits + xbits);
	if(stree != null)
	    zip_static_len += f * (stree[n].dl + xbits);
    }
    if(overflow == 0)
	return;

    // This happens for example on obj2 and pic of the Calgary corpus

    // Find the first bit length which could increase:
    do {
	bits = max_length - 1;
	while(zip_bl_count[bits] == 0)
	    bits--;
	zip_bl_count[bits]--;		// move one leaf down the tree
	zip_bl_count[bits + 1] += 2;	// move one overflow item as its brother
	zip_bl_count[max_length]--;
	/* The brother of the overflow item also moves one step up,
	 * but this does not affect bl_count[max_length]
	 */
	overflow -= 2;
    } while(overflow > 0);

    /* Now recompute all bit lengths, scanning in increasing frequency.
     * h is still equal to HEAP_SIZE. (It is simpler to reconstruct all
     * lengths instead of fixing only the wrong ones. This idea is taken
     * from 'ar' written by Haruhiko Okumura.)
     */
    for(bits = max_length; bits != 0; bits--) {
	n = zip_bl_count[bits];
	while(n != 0) {
	    m = zip_heap[--h];
	    if(m > max_code)
		continue;
	    if(tree[m].dl != bits) {
		zip_opt_len += (bits - tree[m].dl) * tree[m].fc;
		tree[m].fc = bits;
	    }
	    n--;
	}
    }
}

  /* ==========================================================================
   * Generate the codes for a given tree and bit counts (which need not be
   * optimal).
   * IN assertion: the array bl_count contains the bit length statistics for
   * the given tree and the field len is set for all tree elements.
   * OUT assertion: the field code is set for all tree elements of non
   *     zero code length.
   */
var zip_gen_codes = function(tree,	// the tree to decorate
		   max_code) {	// largest code with non zero frequency
    var next_code = new Array(zip_MAX_BITS+1); // next code value for each bit length
    var code = 0;		// running code value
    var bits;			// bit index
    var n;			// code index

    /* The distribution counts are first used to generate the code values
     * without bit reversal.
     */
    for(bits = 1; bits <= zip_MAX_BITS; bits++) {
	code = ((code + zip_bl_count[bits-1]) << 1);
	next_code[bits] = code;
    }

    /* Check that the bit counts in bl_count are consistent. The last code
     * must be all ones.
     */
//    Assert (code + encoder->bl_count[MAX_BITS]-1 == (1<<MAX_BITS)-1,
//	    "inconsistent bit counts");
//    Tracev((stderr,"\ngen_codes: max_code %d ", max_code));

    for(n = 0; n <= max_code; n++) {
	var len = tree[n].dl;
	if(len == 0)
	    continue;
	// Now reverse the bits
	tree[n].fc = zip_bi_reverse(next_code[len]++, len);

//      Tracec(tree != static_ltree, (stderr,"\nn %3d %c l %2d c %4x (%x) ",
//	  n, (isgraph(n) ? n : ' '), len, tree[n].fc, next_code[len]-1));
    }
}

/* ==========================================================================
 * Construct one Huffman tree and assigns the code bit strings and lengths.
 * Update the total bit length for the current block.
 * IN assertion: the field freq is set for all tree elements.
 * OUT assertions: the fields len and code are set to the optimal bit length
 *     and corresponding code. The length opt_len is updated; static_len is
 *     also updated if stree is not null. The field max_code is set.
 */
var zip_build_tree = function(desc) { // the tree descriptor
    var tree	= desc.dyn_tree;
    var stree	= desc.static_tree;
    var elems	= desc.elems;
    var n, m;		// iterate over heap elements
    var max_code = -1;	// largest code with non zero frequency
    var node = elems;	// next internal node of the tree

    /* Construct the initial heap, with least frequent element in
     * heap[SMALLEST]. The sons of heap[n] are heap[2*n] and heap[2*n+1].
     * heap[0] is not used.
     */
    zip_heap_len = 0;
    zip_heap_max = zip_HEAP_SIZE;

    for(n = 0; n < elems; n++) {
	if(tree[n].fc != 0) {
	    zip_heap[++zip_heap_len] = max_code = n;
	    zip_depth[n] = 0;
	} else
	    tree[n].dl = 0;
    }

    /* The pkzip format requires that at least one distance code exists,
     * and that at least one bit should be sent even if there is only one
     * possible code. So to avoid special checks later on we force at least
     * two codes of non zero frequency.
     */
    while(zip_heap_len < 2) {
	var xnew = zip_heap[++zip_heap_len] = (max_code < 2 ? ++max_code : 0);
	tree[xnew].fc = 1;
	zip_depth[xnew] = 0;
	zip_opt_len--;
	if(stree != null)
	    zip_static_len -= stree[xnew].dl;
	// new is 0 or 1 so it does not have extra bits
    }
    desc.max_code = max_code;

    /* The elements heap[heap_len/2+1 .. heap_len] are leaves of the tree,
     * establish sub-heaps of increasing lengths:
     */
    for(n = zip_heap_len >> 1; n >= 1; n--)
	zip_pqdownheap(tree, n);

    /* Construct the Huffman tree by repeatedly combining the least two
     * frequent nodes.
     */
    do {
	n = zip_heap[zip_SMALLEST];
	zip_heap[zip_SMALLEST] = zip_heap[zip_heap_len--];
	zip_pqdownheap(tree, zip_SMALLEST);

	m = zip_heap[zip_SMALLEST];  // m = node of next least frequency

	// keep the nodes sorted by frequency
	zip_heap[--zip_heap_max] = n;
	zip_heap[--zip_heap_max] = m;

	// Create a new node father of n and m
	tree[node].fc = tree[n].fc + tree[m].fc;
//	depth[node] = (char)(MAX(depth[n], depth[m]) + 1);
	if(zip_depth[n] > zip_depth[m] + 1)
	    zip_depth[node] = zip_depth[n];
	else
	    zip_depth[node] = zip_depth[m] + 1;
	tree[n].dl = tree[m].dl = node;

	// and insert the new node in the heap
	zip_heap[zip_SMALLEST] = node++;
	zip_pqdownheap(tree, zip_SMALLEST);

    } while(zip_heap_len >= 2);

    zip_heap[--zip_heap_max] = zip_heap[zip_SMALLEST];

    /* At this point, the fields freq and dad are set. We can now
     * generate the bit lengths.
     */
    zip_gen_bitlen(desc);

    // The field len is now set, we can generate the bit codes
    zip_gen_codes(tree, max_code);
}

/* ==========================================================================
 * Scan a literal or distance tree to determine the frequencies of the codes
 * in the bit length tree. Updates opt_len to take into account the repeat
 * counts. (The contribution of the bit length codes will be added later
 * during the construction of bl_tree.)
 */
var zip_scan_tree = function(tree,// the tree to be scanned
		       max_code) {  // and its largest code of non zero frequency
    var n;			// iterates over all tree elements
    var prevlen = -1;		// last emitted length
    var curlen;			// length of current code
    var nextlen = tree[0].dl;	// length of next code
    var count = 0;		// repeat count of the current code
    var max_count = 7;		// max repeat count
    var min_count = 4;		// min repeat count

    if(nextlen == 0) {
	max_count = 138;
	min_count = 3;
    }
    tree[max_code + 1].dl = 0xffff; // guard

    for(n = 0; n <= max_code; n++) {
	curlen = nextlen;
	nextlen = tree[n + 1].dl;
	if(++count < max_count && curlen == nextlen)
	    continue;
	else if(count < min_count)
	    zip_bl_tree[curlen].fc += count;
	else if(curlen != 0) {
	    if(curlen != prevlen)
		zip_bl_tree[curlen].fc++;
	    zip_bl_tree[zip_REP_3_6].fc++;
	} else if(count <= 10)
	    zip_bl_tree[zip_REPZ_3_10].fc++;
	else
	    zip_bl_tree[zip_REPZ_11_138].fc++;
	count = 0; prevlen = curlen;
	if(nextlen == 0) {
	    max_count = 138;
	    min_count = 3;
	} else if(curlen == nextlen) {
	    max_count = 6;
	    min_count = 3;
	} else {
	    max_count = 7;
	    min_count = 4;
	}
    }
}

  /* ==========================================================================
   * Send a literal or distance tree in compressed form, using the codes in
   * bl_tree.
   */
var zip_send_tree = function(tree, // the tree to be scanned
		   max_code) { // and its largest code of non zero frequency
    var n;			// iterates over all tree elements
    var prevlen = -1;		// last emitted length
    var curlen;			// length of current code
    var nextlen = tree[0].dl;	// length of next code
    var count = 0;		// repeat count of the current code
    var max_count = 7;		// max repeat count
    var min_count = 4;		// min repeat count

    /* tree[max_code+1].dl = -1; */  /* guard already set */
    if(nextlen == 0) {
      max_count = 138;
      min_count = 3;
    }

    for(n = 0; n <= max_code; n++) {
	curlen = nextlen;
	nextlen = tree[n+1].dl;
	if(++count < max_count && curlen == nextlen) {
	    continue;
	} else if(count < min_count) {
	    do { zip_SEND_CODE(curlen, zip_bl_tree); } while(--count != 0);
	} else if(curlen != 0) {
	    if(curlen != prevlen) {
		zip_SEND_CODE(curlen, zip_bl_tree);
		count--;
	    }
	    // Assert(count >= 3 && count <= 6, " 3_6?");
	    zip_SEND_CODE(zip_REP_3_6, zip_bl_tree);
	    zip_send_bits(count - 3, 2);
	} else if(count <= 10) {
	    zip_SEND_CODE(zip_REPZ_3_10, zip_bl_tree);
	    zip_send_bits(count-3, 3);
	} else {
	    zip_SEND_CODE(zip_REPZ_11_138, zip_bl_tree);
	    zip_send_bits(count-11, 7);
	}
	count = 0;
	prevlen = curlen;
	if(nextlen == 0) {
	    max_count = 138;
	    min_count = 3;
	} else if(curlen == nextlen) {
	    max_count = 6;
	    min_count = 3;
	} else {
	    max_count = 7;
	    min_count = 4;
	}
    }
}

/* ==========================================================================
 * Construct the Huffman tree for the bit lengths and return the index in
 * bl_order of the last bit length code to send.
 */
var zip_build_bl_tree = function() {
    var max_blindex;  // index of last bit length code of non zero freq

    // Determine the bit length frequencies for literal and distance trees
    zip_scan_tree(zip_dyn_ltree, zip_l_desc.max_code);
    zip_scan_tree(zip_dyn_dtree, zip_d_desc.max_code);

    // Build the bit length tree:
    zip_build_tree(zip_bl_desc);
    /* opt_len now includes the length of the tree representations, except
     * the lengths of the bit lengths codes and the 5+5+4 bits for the counts.
     */

    /* Determine the number of bit length codes to send. The pkzip format
     * requires that at least 4 bit length codes be sent. (appnote.txt says
     * 3 but the actual value used is 4.)
     */
    for(max_blindex = zip_BL_CODES-1; max_blindex >= 3; max_blindex--) {
	if(zip_bl_tree[zip_bl_order[max_blindex]].dl != 0) break;
    }
    /* Update opt_len to include the bit length tree and counts */
    zip_opt_len += 3*(max_blindex+1) + 5+5+4;
//    Tracev((stderr, "\ndyn trees: dyn %ld, stat %ld",
//	    encoder->opt_len, encoder->static_len));

    return max_blindex;
}

/* ==========================================================================
 * Send the header for a block using dynamic Huffman trees: the counts, the
 * lengths of the bit length codes, the literal tree and the distance tree.
 * IN assertion: lcodes >= 257, dcodes >= 1, blcodes >= 4.
 */
var zip_send_all_trees = function(lcodes, dcodes, blcodes) { // number of codes for each tree
    var rank; // index in bl_order

//    Assert (lcodes >= 257 && dcodes >= 1 && blcodes >= 4, "not enough codes");
//    Assert (lcodes <= L_CODES && dcodes <= D_CODES && blcodes <= BL_CODES,
//	    "too many codes");
//    Tracev((stderr, "\nbl counts: "));
    zip_send_bits(lcodes-257, 5); // not +255 as stated in appnote.txt
    zip_send_bits(dcodes-1,   5);
    zip_send_bits(blcodes-4,  4); // not -3 as stated in appnote.txt
    for(rank = 0; rank < blcodes; rank++) {
//      Tracev((stderr, "\nbl code %2d ", bl_order[rank]));
	zip_send_bits(zip_bl_tree[zip_bl_order[rank]].dl, 3);
    }

    // send the literal tree
    zip_send_tree(zip_dyn_ltree,lcodes-1);

    // send the distance tree
    zip_send_tree(zip_dyn_dtree,dcodes-1);
}

/* ==========================================================================
 * Determine the best encoding for the current block: dynamic trees, static
 * trees or store, and output the encoded block to the zip file.
 */
var zip_flush_block = function(eof) { // true if this is the last block for a file
    var opt_lenb, static_lenb; // opt_len and static_len in bytes
    var max_blindex;	// index of last bit length code of non zero freq
    var stored_len;	// length of input block

    stored_len = zip_strstart - zip_block_start;
    zip_flag_buf[zip_last_flags] = zip_flags; // Save the flags for the last 8 items

    // Construct the literal and distance trees
    zip_build_tree(zip_l_desc);
//    Tracev((stderr, "\nlit data: dyn %ld, stat %ld",
//	    encoder->opt_len, encoder->static_len));

    zip_build_tree(zip_d_desc);
//    Tracev((stderr, "\ndist data: dyn %ld, stat %ld",
//	    encoder->opt_len, encoder->static_len));
    /* At this point, opt_len and static_len are the total bit lengths of
     * the compressed block data, excluding the tree representations.
     */

    /* Build the bit length tree for the above two trees, and get the index
     * in bl_order of the last bit length code to send.
     */
    max_blindex = zip_build_bl_tree();

    // Determine the best encoding. Compute first the block length in bytes
    opt_lenb	= (zip_opt_len   +3+7)>>3;
    static_lenb = (zip_static_len+3+7)>>3;

//    Trace((stderr, "\nopt %lu(%lu) stat %lu(%lu) stored %lu lit %u dist %u ",
//	   opt_lenb, encoder->opt_len,
//	   static_lenb, encoder->static_len, stored_len,
//	   encoder->last_lit, encoder->last_dist));

    if(static_lenb <= opt_lenb)
	opt_lenb = static_lenb;
    if(stored_len + 4 <= opt_lenb // 4: two words for the lengths
       && zip_block_start >= 0) {
	var i;

	/* The test buf != NULL is only necessary if LIT_BUFSIZE > WSIZE.
	 * Otherwise we can't have processed more than WSIZE input bytes since
	 * the last block flush, because compression would have been
	 * successful. If LIT_BUFSIZE <= WSIZE, it is never too late to
	 * transform a block into a stored block.
	 */
	zip_send_bits((zip_STORED_BLOCK<<1)+eof, 3);  /* send block type */
	zip_bi_windup();		 /* align on byte boundary */
	zip_put_short(stored_len);
	zip_put_short(~stored_len);

      // copy block
/*
      p = &window[block_start];
      for(i = 0; i < stored_len; i++)
	put_byte(p[i]);
*/
	for(i = 0; i < stored_len; i++)
	    zip_put_byte(zip_window[zip_block_start + i]);

    } else if(static_lenb == opt_lenb) {
	zip_send_bits((zip_STATIC_TREES<<1)+eof, 3);
	zip_compress_block(zip_static_ltree, zip_static_dtree);
    } else {
	zip_send_bits((zip_DYN_TREES<<1)+eof, 3);
	zip_send_all_trees(zip_l_desc.max_code+1,
			   zip_d_desc.max_code+1,
			   max_blindex+1);
	zip_compress_block(zip_dyn_ltree, zip_dyn_dtree);
    }

    zip_init_block();

    if(eof != 0)
	zip_bi_windup();
}

/* ==========================================================================
 * Save the match info and tally the frequency counts. Return true if
 * the current block must be flushed.
 */
var zip_ct_tally = function(
	dist, // distance of matched string
	lc) { // match length-MIN_MATCH or unmatched char (if dist==0)
    zip_l_buf[zip_last_lit++] = lc;
    if(dist == 0) {
	// lc is the unmatched char
	zip_dyn_ltree[lc].fc++;
    } else {
	// Here, lc is the match length - MIN_MATCH
	dist--;		    // dist = match distance - 1
//      Assert((ush)dist < (ush)MAX_DIST &&
//	     (ush)lc <= (ush)(MAX_MATCH-MIN_MATCH) &&
//	     (ush)D_CODE(dist) < (ush)D_CODES,  "ct_tally: bad match");

	zip_dyn_ltree[zip_length_code[lc]+zip_LITERALS+1].fc++;
	zip_dyn_dtree[zip_D_CODE(dist)].fc++;

	zip_d_buf[zip_last_dist++] = dist;
	zip_flags |= zip_flag_bit;
    }
    zip_flag_bit <<= 1;

    // Output the flags if they fill a byte
    if((zip_last_lit & 7) == 0) {
	zip_flag_buf[zip_last_flags++] = zip_flags;
	zip_flags = 0;
	zip_flag_bit = 1;
    }
    // Try to guess if it is profitable to stop the current block here
    if(zip_compr_level > 2 && (zip_last_lit & 0xfff) == 0) {
	// Compute an upper bound for the compressed length
	var out_length = zip_last_lit * 8;
	var in_length = zip_strstart - zip_block_start;
	var dcode;

	for(dcode = 0; dcode < zip_D_CODES; dcode++) {
	    out_length += zip_dyn_dtree[dcode].fc * (5 + zip_extra_dbits[dcode]);
	}
	out_length >>= 3;
//      Trace((stderr,"\nlast_lit %u, last_dist %u, in %ld, out ~%ld(%ld%%) ",
//	     encoder->last_lit, encoder->last_dist, in_length, out_length,
//	     100L - out_length*100L/in_length));
	if(zip_last_dist < parseInt(zip_last_lit/2) &&
	   out_length < parseInt(in_length/2))
	    return true;
    }
    return (zip_last_lit == zip_LIT_BUFSIZE-1 ||
	    zip_last_dist == zip_DIST_BUFSIZE);
    /* We avoid equality with LIT_BUFSIZE because of wraparound at 64K
     * on 16 bit machines and because stored blocks are restricted to
     * 64K-1 bytes.
     */
}

  /* ==========================================================================
   * Send the block data compressed using the given Huffman trees
   */
var zip_compress_block = function(
	ltree,	// literal tree
	dtree) {	// distance tree
    var dist;		// distance of matched string
    var lc;		// match length or unmatched char (if dist == 0)
    var lx = 0;		// running index in l_buf
    var dx = 0;		// running index in d_buf
    var fx = 0;		// running index in flag_buf
    var flag = 0;	// current flags
    var code;		// the code to send
    var extra;		// number of extra bits to send

    if(zip_last_lit != 0) do {
	if((lx & 7) == 0)
	    flag = zip_flag_buf[fx++];
	lc = zip_l_buf[lx++] & 0xff;
	if((flag & 1) == 0) {
	    zip_SEND_CODE(lc, ltree); /* send a literal byte */
//	Tracecv(isgraph(lc), (stderr," '%c' ", lc));
	} else {
	    // Here, lc is the match length - MIN_MATCH
	    code = zip_length_code[lc];
	    zip_SEND_CODE(code+zip_LITERALS+1, ltree); // send the length code
	    extra = zip_extra_lbits[code];
	    if(extra != 0) {
		lc -= zip_base_length[code];
		zip_send_bits(lc, extra); // send the extra length bits
	    }
	    dist = zip_d_buf[dx++];
	    // Here, dist is the match distance - 1
	    code = zip_D_CODE(dist);
//	Assert (code < D_CODES, "bad d_code");

	    zip_SEND_CODE(code, dtree);	  // send the distance code
	    extra = zip_extra_dbits[code];
	    if(extra != 0) {
		dist -= zip_base_dist[code];
		zip_send_bits(dist, extra);   // send the extra distance bits
	    }
	} // literal or match pair ?
	flag >>= 1;
    } while(lx < zip_last_lit);

    zip_SEND_CODE(zip_END_BLOCK, ltree);
}

/* ==========================================================================
 * Send a value on a given number of bits.
 * IN assertion: length <= 16 and value fits in length bits.
 */
var zip_Buf_size = 16; // bit size of bi_buf
var zip_send_bits = function(
	value,	// value to send
	length) {	// number of bits
    /* If not enough room in bi_buf, use (valid) bits from bi_buf and
     * (16 - bi_valid) bits from value, leaving (width - (16-bi_valid))
     * unused bits in value.
     */
    if(zip_bi_valid > zip_Buf_size - length) {
	zip_bi_buf |= (value << zip_bi_valid);
	zip_put_short(zip_bi_buf);
	zip_bi_buf = (value >> (zip_Buf_size - zip_bi_valid));
	zip_bi_valid += length - zip_Buf_size;
    } else {
	zip_bi_buf |= value << zip_bi_valid;
	zip_bi_valid += length;
    }
}

/* ==========================================================================
 * Reverse the first len bits of a code, using straightforward code (a faster
 * method would use a table)
 * IN assertion: 1 <= len <= 15
 */
var zip_bi_reverse = function(
	code,	// the value to invert
	len) {	// its bit length
    var res = 0;
    do {
	res |= code & 1;
	code >>= 1;
	res <<= 1;
    } while(--len > 0);
    return res >> 1;
}

/* ==========================================================================
 * Write out any remaining bits in an incomplete byte.
 */
var zip_bi_windup = function() {
    if(zip_bi_valid > 8) {
	zip_put_short(zip_bi_buf);
    } else if(zip_bi_valid > 0) {
	zip_put_byte(zip_bi_buf);
    }
    zip_bi_buf = 0;
    zip_bi_valid = 0;
}

var zip_qoutbuf = function() {
    if(zip_outcnt != 0) {
	var q, i;
	q = zip_new_queue();
	if(zip_qhead == null)
	    zip_qhead = zip_qtail = q;
	else
	    zip_qtail = zip_qtail.next = q;
	q.len = zip_outcnt - zip_outoff;
//      System.arraycopy(zip_outbuf, zip_outoff, q.ptr, 0, q.len);
	for(i = 0; i < q.len; i++)
	    q.ptr[i] = zip_outbuf[zip_outoff + i];
	zip_outcnt = zip_outoff = 0;
    }
}

var zip_deflate = function(str, level) {
    var i, j;

    zip_deflate_data = str;
    zip_deflate_pos = 0;
    if(typeof level == "undefined")
	level = zip_DEFAULT_LEVEL;
    zip_deflate_start(level);

    var buff = new Array(1024);
    var aout = [];
    while((i = zip_deflate_internal(buff, 0, buff.length)) > 0) {
	var cbuf = new Array(i);
	for(j = 0; j < i; j++){
	    cbuf[j] = String.fromCharCode(buff[j]);
	}
	aout[aout.length] = cbuf.join("");
    }
    zip_deflate_data = null; // G.C.
    return aout.join("");
}

if (! ctx.RawDeflate) ctx.RawDeflate = {};
ctx.RawDeflate.deflate = zip_deflate;

})(this);
/*
 * Date Format 1.2.3
 * (c) 2007-2009 Steven Levithan <stevenlevithan.com>
 * MIT license
 *
 * Includes enhancements by Scott Trenda <scott.trenda.net>
 * and Kris Kowal <cixar.com/~kris.kowal/>
 *
 * Accepts a date, a mask, or a date and a mask.
 * Returns a formatted version of the given date.
 * The date defaults to the current date/time.
 * The mask defaults to dateFormat.masks.default.
 */

var dateFormat = function () {
	var	token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
		timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
		timezoneClip = /[^-+\dA-Z]/g,
		pad = function (val, len) {
			val = String(val);
			len = len || 2;
			while (val.length < len) val = "0" + val;
			return val;
		};

	// Regexes and supporting functions are cached through closure
	return function (date, mask, utc) {
		var dF = dateFormat;

		// You can't provide utc if you skip other args (use the "UTC:" mask prefix)
		if (arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)) {
			mask = date;
			date = undefined;
		}

		// Passing date through Date applies Date.parse, if necessary
		date = date ? new Date(date) : new Date;
		if (isNaN(date)) throw SyntaxError("invalid date");

		mask = String(dF.masks[mask] || mask || dF.masks["default"]);

		// Allow setting the utc argument via the mask
		if (mask.slice(0, 4) == "UTC:") {
			mask = mask.slice(4);
			utc = true;
		}

		var	_ = utc ? "getUTC" : "get",
			d = date[_ + "Date"](),
			D = date[_ + "Day"](),
			m = date[_ + "Month"](),
			y = date[_ + "FullYear"](),
			H = date[_ + "Hours"](),
			M = date[_ + "Minutes"](),
			s = date[_ + "Seconds"](),
			L = date[_ + "Milliseconds"](),
			o = utc ? 0 : date.getTimezoneOffset(),
			flags = {
				d:    d,
				dd:   pad(d),
				ddd:  dF.i18n.dayNames[D],
				dddd: dF.i18n.dayNames[D + 7],
				m:    m + 1,
				mm:   pad(m + 1),
				mmm:  dF.i18n.monthNames[m],
				mmmm: dF.i18n.monthNames[m + 12],
				yy:   String(y).slice(2),
				yyyy: y,
				h:    H % 12 || 12,
				hh:   pad(H % 12 || 12),
				H:    H,
				HH:   pad(H),
				M:    M,
				MM:   pad(M),
				s:    s,
				ss:   pad(s),
				l:    pad(L, 3),
				L:    pad(L > 99 ? Math.round(L / 10) : L),
				t:    H < 12 ? "a"  : "p",
				tt:   H < 12 ? "am" : "pm",
				T:    H < 12 ? "A"  : "P",
				TT:   H < 12 ? "AM" : "PM",
				Z:    utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
				o:    (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
				S:    ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 != 10) * d % 10]
			};

		return mask.replace(token, function ($0) {
			return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
		});
	};
}();

// Some common format strings
dateFormat.masks = {
	"default":      "ddd mmm dd yyyy HH:MM:ss",
	shortDate:      "m/d/yy",
	mediumDate:     "mmm d, yyyy",
	longDate:       "mmmm d, yyyy",
	fullDate:       "dddd, mmmm d, yyyy",
	shortTime:      "h:MM TT",
	mediumTime:     "h:MM:ss TT",
	longTime:       "h:MM:ss TT Z",
	isoDate:        "yyyy-mm-dd",
	isoTime:        "HH:MM:ss",
	isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss",
	isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
};

// Internationalization strings
dateFormat.i18n = {
	dayNames: [
		"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
		"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
	],
	monthNames: [
		"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
		"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
	]
};

// For convenience...
Date.prototype.format = function (mask, utc) {
	return dateFormat(this, mask, utc);
};

angular.module('ImageLib', []);

angular.module('ImageLib').factory('GenerateImageBmp', [
  function() {
    var Encoder;
    Encoder = (function() {
      function Encoder() {}

      Encoder.prototype._getLittleEndianHex = function(value) {
        var bytes, result, _i;
        result = [];
        for (bytes = _i = 4; _i >= 1; bytes = --_i) {
          result.push(String.fromCharCode(value & 255));
          value >>= 8;
        }
        return result.join('');
      };

      Encoder.prototype._header = function(width, height) {
        var h, header, numFileBytes, w;
        numFileBytes = this._getLittleEndianHex(width * height);
        w = this._getLittleEndianHex(width);
        h = this._getLittleEndianHex(height);
        header = '' + 'BM' + numFileBytes + '\x00\x00' + '\x00\x00' + '\x36\x00\x00\x00' + '\x28\x00\x00\x00' + w + h + '\x01\x00' + '\x20\x00' + '\x00\x00\x00\x00' + '\x00\x00\x00\x00' + '\x13\x0B\x00\x00' + '\x13\x0B\x00\x00' + '\x00\x00\x00\x00' + '\x00\x00\x00\x00';
        return header;
      };

      Encoder.prototype.encode = function(stringData, width, height) {
        var encodedData, header, outputData;
        header = this._header(width, height);
        outputData = header + stringData.join('');
        if (window.btoa) {
          encodedData = window.btoa(outputData);
        } else {
          encodedData = $.base64.encode(outputData);
        }
        return 'data:image/bmp;base64,' + encodedData;
      };

      return Encoder;

    })();
    return new Encoder();
  }
]);

angular.module('ImageLib').factory('GenerateImagePng', [
  function() {
    var Chunker, Data, Deflate, Encoder, Hex, Palette;
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
        } else if (this.size <= this.sizeMaxValue) {
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
      function Data(bitDepth, colorType, filterMethod, compressionLevel, inputData, width, height) {
        var COLORTYPE;
        this.bitDepth = bitDepth;
        this.colorType = colorType;
        this.filterMethod = filterMethod;
        this.compressionLevel = compressionLevel;
        this.inputData = inputData;
        this.width = width;
        this.height = height;
        this.h = new Hex();
        this.chunker = new Chunker();
        this.deflate = new Deflate();
        this.printData = false;
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
        sample = (pixel & f.mask) >>> f.shift;
        return sample;
      };

      Data.prototype._getPixelData = function(pixel) {
        var bits, converted, downSampleShift;
        converted = 0x00000000;
        bits = 0;
        downSampleShift = 8 - this.bitDepth;
        if (this.colorType === 2 || this.colorType === 6) {
          converted = (converted << this.bitDepth) | (this._getPixelChannel(pixel, 'RED') >>> downSampleShift);
          converted = (converted << this.bitDepth) | (this._getPixelChannel(pixel, 'GREEN') >>> downSampleShift);
          converted = (converted << this.bitDepth) | (this._getPixelChannel(pixel, 'BLUE') >>> downSampleShift);
          bits += 3 * this.bitDepth;
        } else if (this.colorType === 3) {
          converted = (converted << this.bitDepth) | this.palette.color(pixel);
          bits += this.bitDepth;
        } else {
          converted = (converted << this.bitDepth) | (this._getPixelChannel(pixel, 'GRAY') >>> downSampleShift);
          bits += this.bitDepth;
        }
        if (this.colorType === 4 || this.colorType === 6) {
          converted = (converted << this.bitDepth) | (this._getPixelChannel(pixel, 'ALPHA') >>> downSampleShift);
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

      Data.prototype._filter = function() {
        if (this.filterMethod > 0) {
          return this._filterSubAndUp();
        } else {
          return this._filterZero();
        }
      };

      Data.prototype._filterSubAndUp = function() {
        var LINE_FILTER_SUB, LINE_FILTER_UP, cur, filteredData, i, index, prev, step, x, y, _i, _j, _k, _l, _m, _ref, _ref1, _ref2;
        console.log('filter');
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
        if (this.compressionLevel > 0) {
          return this._deflateCompression(data, this.compressionLevel);
        } else {
          return this._deflateNoCompression(data);
        }
      };

      Data.prototype._deflateCompression = function(data, level) {
        var DATA_COMPRESSION_METHOD, storeBuffer;
        DATA_COMPRESSION_METHOD = String.fromCharCode(0x78, 0x9c);
        storeBuffer = this.deflate.encode(data, level);
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
          this.h.printHexOfListOfInts(this.inputData, 'inputData');
          this.h.printHex(this.data, 'byteData');
          this.h.printHex(filteredData, 'filteredData');
          if (this.colorType === 3) {
            this.h.printHex(this.palette.getData(), 'palette');
          }
          this.h.printHex(compressedData, 'compresedData', [2, 4]);
          this.h.printHex(IDAT, 'IDAT');
        }
        return SIGNATURE + IHDR + PLTE + IDAT + IEND;
      };

      return Data;

    })();
    Deflate = (function() {
      function Deflate() {}

      Deflate.prototype.encode = function(data, level) {
        return RawDeflate.deflate(data, level);
      };

      return Deflate;

    })();
    Hex = (function() {
      function Hex() {}

      Hex.prototype.hexStringOfByte = function(b) {
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

      Hex.prototype.hex = function(ins, maybeName, hf) {
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

      Hex.prototype.printHex = function(ins, maybeName, hf) {
        var s;
        s = this.hex(ins, maybeName, hf);
        s = '[' + maybeName + ', ' + ins.length + '] ' + s;
        return console.log(s);
      };

      Hex.prototype.printHexOfListOfStrings = function(list, label) {
        var s, w, _i, _len;
        s = '';
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          w = list[_i];
          s += this.hexOfString(w);
        }
        return console.log('[' + label + '] ' + s);
      };

      Hex.prototype.printHexOfListOfInts = function(list, label) {
        var s, w, _i, _len;
        s = '';
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          w = list[_i];
          s += this.hexOfInt(w);
        }
        return console.log('[' + label + '] ' + s);
      };

      Hex.prototype.hexOfInt = function(word) {
        return this.hexStringOfByte(word >>> 24) + ' ' + this.hexStringOfByte((word << 8) >>> 24) + ' ' + this.hexStringOfByte((word << 16) >>> 24) + ' ' + this.hexStringOfByte((word << 24) >>> 24) + ' ';
      };

      Hex.prototype.hexOfString = function(string, label) {
        var i, s, word, _i, _ref;
        s = '';
        for (i = _i = 0, _ref = string.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          word = string.charCodeAt(i);
          s += this.hexOfInt(word);
        }
        return s;
      };

      return Hex;

    })();
    Encoder = (function() {
      function Encoder() {
        this.Chunker = Chunker;
        this.Data = Data;
        this.hex = new Hex();
        this.COLOR_GRAYSCALE = 0;
        this.COLOR_INDEXED = 3;
        this.COLOR_RGB = 2;
        this.COLOR = this.COLOR_INDEXED;
        this.COMPRESSION_LEVEL = 6;
        this.FILTER_METHOD = 0;
        this.BIT_DEPTH = 2;
      }

      Encoder.prototype.encode = function(stringData, width, height, colorStyle, filterMethod, compressionLevel) {
        var a, b, g, image, intData, r, s, x, y, _i, _j;
        if (compressionLevel === void 0) {
          compressionLevel = this.COMPRESSION_LEVEL;
        }
        if (filterMethod === void 0) {
          filterMethod = this.FILTER_METHOD;
        }
        if (colorStyle === void 0) {
          colorStyle = this.COLOR_GRAYSCALE;
        }
        intData = [];
        for (y = _i = 0; 0 <= height ? _i < height : _i > height; y = 0 <= height ? ++_i : --_i) {
          for (x = _j = 0; 0 <= width ? _j < width : _j > width; x = 0 <= width ? ++_j : --_j) {
            s = stringData[(height - y - 1) * width + x];
            r = s.charCodeAt(0);
            g = s.charCodeAt(1);
            b = s.charCodeAt(2);
            a = s.charCodeAt(3);
            intData[width * y + x] = (r << 24) | (g << 16) | (b << 8) | a;
          }
        }
        image = new Data(this.BIT_DEPTH, this.COLOR_INDEXED, filterMethod, compressionLevel, intData, width, height);
        image.printData = false;
        return 'data:image/png;base64,' + btoa(image.imageData());
      };

      return Encoder;

    })();
    return new Encoder();
  }
]);

angular.module('ImageLib').factory('GenerateImageUsingCanvas', [
  function() {
    var CanvasWrapper;
    CanvasWrapper = (function() {
      function CanvasWrapper() {}

      CanvasWrapper.prototype.getCanvas = function() {
        if (this.canvas === void 0) {
          this.canvas = document.createElement('canvas');
        }
        return this.canvas;
      };

      CanvasWrapper.prototype.getContext = function() {
        if (this.context === void 0) {
          this.context = this.getCanvas().getContext('2d');
        }
        return this.context;
      };

      CanvasWrapper.prototype.encode = function(stringData, width, height) {
        var a, b, canvas, canvasData, context, g, index, r, s, x, y, _i, _j;
        canvas = this.getCanvas();
        canvas.setAttribute('width', width);
        canvas.setAttribute('height', height);
        context = this.getContext();
        canvasData = context.getImageData(0, 0, width, height);
        if (canvasData) {
          for (y = _i = 0; 0 <= height ? _i < height : _i > height; y = 0 <= height ? ++_i : --_i) {
            for (x = _j = 0; 0 <= width ? _j < width : _j > width; x = 0 <= width ? ++_j : --_j) {
              s = stringData[(height - y - 1) * width + x];
              r = s.charCodeAt(0);
              g = s.charCodeAt(1);
              b = s.charCodeAt(2);
              a = s.charCodeAt(3);
              index = (x + y * width) * 4;
              canvasData.data[index] = r;
              canvasData.data[index + 1] = g;
              canvasData.data[index + 2] = b;
              canvasData.data[index + 3] = 255 - a;
            }
          }
          context.putImageData(canvasData, 0, 0);
          return canvas.toDataURL("image/png");
        } else {
          return 'error';
        }
      };

      return CanvasWrapper;

    })();
    return new CanvasWrapper();
  }
]);

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('ImageLib').factory("GraphicsManager", [
  'ImageData', 'GenerateImagePng', 'GenerateImageUsingCanvas', function(ImageData, GenerateImagePng, GenerateImageUsingCanvas) {
    var GraphicsManager, Image, graphicsManager;
    Image = (function() {
      function Image(imageData, width, height, backgroundColor, offsetleft, offsetright, offsettop, offsetbottom) {
        var color, i, _i, _ref;
        this.imageData = imageData;
        this.width = width;
        this.height = height;
        this.flipImage = __bind(this.flipImage, this);
        this.width = Math.round(this.width);
        this.height = Math.round(this.height);
        this.colors = this.imageData.colors[0];
        this.chars = this.imageData.chars[0];
        this.data = [];
        if (offsetleft !== void 0 && offsetright !== void 0 && offsettop !== void 0 && offsetbottom !== void 0) {
          this.offsetleft = Math.round(offsetleft);
          this.offsetright = Math.round(offsetright);
          this.offsettop = Math.round(offsettop);
          this.offsetbottom = Math.round(offsetbottom);
        } else if (offsetleft !== void 0) {
          this.offsetleft = Math.round(offsetleft);
          this.offsetright = Math.round(offsetleft);
          this.offsettop = Math.round(offsetleft);
          this.offsetbottom = Math.round(offsetleft);
        } else {
          this.offsetleft = 0;
          this.offsetright = 0;
          this.offsettop = 0;
          this.offsetbottom = 0;
        }
        this.width = this.width + this.offsetleft + this.offsetright;
        this.height = this.height + this.offsettop + this.offsetbottom;
        if (backgroundColor !== void 0) {
          color = this.colors[backgroundColor];
          if (color === void 0) {
            color = this.colors['w'];
          }
          for (i = _i = 0, _ref = this.width * this.height - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            this.data[i] = color;
          }
        }
      }

      Image.prototype.colorOrBlack = function(colorLetter) {
        var color;
        if (colorLetter === void 0 || this.colors[colorLetter] === void 0) {
          return color = this.colors['B'];
        } else {
          return this.colors[colorLetter];
        }
      };

      Image.prototype.placeChar = function(x, y, c, colorLetter) {
        var char, color, i, xx, yy, _i, _ref, _results;
        x = Math.round(x);
        y = Math.round(y);
        color = this.colorOrBlack(colorLetter);
        char = this.chars[c];
        if (char === void 0) {
          char = this.chars['?'];
        }
        i = 0;
        _results = [];
        for (yy = _i = _ref = y + char[1] - 1; _ref <= y ? _i <= y : _i >= y; yy = _ref <= y ? ++_i : --_i) {
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (xx = _j = x, _ref1 = x + char[0] - 1; x <= _ref1 ? _j <= _ref1 : _j >= _ref1; xx = x <= _ref1 ? ++_j : --_j) {
              if (char[2][i] > 0) {
                this.setPoint(xx, yy, color);
              }
              _results1.push(i = i + 1);
            }
            return _results1;
          }).call(this));
        }
        return _results;
      };

      Image.prototype.placeCharSequence = function(x, y, cc, colorLetter) {
        var i, w, _i, _ref, _results;
        if (cc === void 0 || cc.length < 1) {
          return;
        }
        w = 6;
        _results = [];
        for (i = _i = 0, _ref = cc.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push(this.placeChar(x + i * w, y, cc[i], colorLetter));
        }
        return _results;
      };

      Image.prototype.placeCharSequenceCentered = function(x, y, cc, colorLetter) {
        if (cc === void 0 || cc.length < 1) {
          return;
        }
        return this.placeCharSequence(x - 3 * cc.length, y - 4, cc, colorLetter);
      };

      Image.prototype.setPoint = function(x, y, color) {
        x = Math.round(x + this.offsetleft);
        y = Math.round(y + this.offsetbottom);
        this.data[y * this.width + x] = color;
        return this;
      };

      Image.prototype.getPoint = function(x, y) {
        return this.data[y * this.width + x];
      };

      Image.prototype.drawLine = function(x1, y1, x2, y2, colorLetter) {
        var color, fx2y, fy2x, k, x, y, _i, _j;
        color = this.colorOrBlack(colorLetter);
        if (y2 === y1 && x2 === x1) {
          this.setPoint(x1, y1, color);
          return this;
        }
        if (Math.abs(y2 - y1) > Math.abs(x2 - x1)) {
          k = (x2 - x1) / (y2 - y1);
          fy2x = function(y) {
            return Math.round(k * (y - y1)) + x1;
          };
          for (y = _i = y1; y1 <= y2 ? _i <= y2 : _i >= y2; y = y1 <= y2 ? ++_i : --_i) {
            this.setPoint(fy2x(y), y, color);
          }
        } else {
          k = (y2 - y1) / (x2 - x1);
          fx2y = function(x) {
            return Math.round(k * (x - x1)) + y1;
          };
          for (x = _j = x1; x1 <= x2 ? _j <= x2 : _j >= x2; x = x1 <= x2 ? ++_j : --_j) {
            this.setPoint(x, fx2y(x), color);
          }
        }
        return this;
      };

      Image.prototype.drawRectangle = function(x, y, w, h, colorLetter) {
        this.drawLine(x, y, x + w, y, colorLetter);
        this.drawLine(x, y, x, y + h, colorLetter);
        this.drawLine(x, y + h, x + w, y + h, colorLetter);
        return this.drawLine(x + w, y, x + w, y + h, colorLetter);
      };

      Image.prototype.drawTriangle = function(x1, y1, x2, y2, x3, y3, colorLetter) {
        this.drawLine(x1, y1, x2, y2, colorLetter);
        this.drawLine(x1, y1, x3, y3, colorLetter);
        return this.drawLine(x2, y2, x3, y3, colorLetter);
      };

      Image.prototype.fillRectangle = function(x, y, w, h, colorLetter) {
        var color, nx, ny, _i, _j, _ref, _ref1;
        x = Math.round(x);
        y = Math.round(y);
        w = Math.round(w);
        h = Math.round(h);
        color = this.colorOrBlack(colorLetter);
        for (ny = _i = y, _ref = y + h - 1; y <= _ref ? _i <= _ref : _i >= _ref; ny = y <= _ref ? ++_i : --_i) {
          for (nx = _j = x, _ref1 = x + w - 1; x <= _ref1 ? _j <= _ref1 : _j >= _ref1; nx = x <= _ref1 ? ++_j : --_j) {
            this.setPoint(nx, ny, color);
          }
        }
        return this;
      };

      Image.prototype.fillRectangleCoords = function(x1, y1, x2, y2, colorLetter) {
        return this.fillRectangle(x1, y1, x2 - x1, y2 - y1, colorLetter);
      };

      Image.prototype.transform = function(fxy) {
        var nx, ny, x, y, _i, _j, _ref, _ref1, _ref2;
        this.buffer = [];
        for (x = _i = 0, _ref = this.width - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
          for (y = _j = 0, _ref1 = this.height - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
            _ref2 = fxy(x, y), nx = _ref2[0], ny = _ref2[1];
            this.buffer[ny * this.width + nx] = this.data[y * this.width + x];
          }
        }
        this.data = this.buffer;
        this.buffer = void 0;
        return this;
      };

      Image.prototype.flipImage = function() {
        return this.transform((function(_this) {
          return function(x, y) {
            return [x, _this.height - 1 - y];
          };
        })(this));
      };

      Image.prototype.getBase64 = function() {
        return this.getBase64Png();
      };

      Image.prototype.getBase64Png = function() {
        return GenerateImagePng.encode(this.data, this.width, this.height);
      };

      Image.prototype.getBase64Canvas = function() {
        return GenerateImageUsingCanvas.encode(this.data, this.width, this.height);
      };

      return Image;

    })();
    GraphicsManager = (function() {
      function GraphicsManager() {
        this.imageData = ImageData;
      }

      GraphicsManager.prototype.newImage = function(width, height, backgroundColor) {
        return new Image(this.imageData, width, height, backgroundColor);
      };

      GraphicsManager.prototype.newImageWhite = function(width, height) {
        return new Image(this.imageData, width, height, 'w');
      };

      GraphicsManager.prototype.newImageWhiteWithOffset = function(width, height, offsetleft, offsetright, offsettop, offsetbottom) {
        return new Image(this.imageData, width, height, 'w', offsetleft, offsetright, offsettop, offsetbottom);
      };

      GraphicsManager.prototype.getColor = function(r, g, b, a) {
        return String.fromCharCode(r, g, b, a);
      };

      GraphicsManager.prototype.test = function() {
        var img;
        img = this.newImage(210, 210);
        img.fillRectangle(0, 0, 210, 210, 'w');
        img.fillRectangle(10, 10, 90, 90, 'r');
        img.fillRectangle(110, 10, 90, 90, 'g');
        img.fillRectangle(10, 110, 90, 90, 'b');
        img.flipImage();
        return img.getBase64();
      };

      return GraphicsManager;

    })();
    graphicsManager = new GraphicsManager();
    document.numeric.modules.GraphicsManager = graphicsManager;
    return graphicsManager;
  }
]);

angular.module('ImageLib').factory('ImageData', [
  function() {
    var ImageData;
    ImageData = (function() {
      function ImageData() {
        this.colors = {
          0: {
            'B': String.fromCharCode(0, 0, 0, 0),
            'D': String.fromCharCode(50, 50, 50, 0),
            'G': String.fromCharCode(150, 150, 150, 0),
            'L': String.fromCharCode(210, 210, 210, 0),
            'w': String.fromCharCode(255, 255, 255, 0),
            'r': String.fromCharCode(255, 0, 0, 0),
            'g': String.fromCharCode(0, 255, 0, 0),
            'b': String.fromCharCode(0, 0, 255, 0)
          }
        };
        this.chars = {
          0: {
            '0': [5, 7, [0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0]],
            '1': [5, 7, [0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1]],
            '2': [5, 7, [0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1]],
            '3': [5, 7, [1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0]],
            '4': [5, 7, [0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0]],
            '5': [5, 7, [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0]],
            '6': [5, 7, [0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0]],
            '7': [5, 7, [1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0]],
            '8': [5, 7, [0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0]],
            '9': [5, 7, [0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0]],
            '?': [5, 7, [0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0]],
            '-': [5, 7, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]],
            '.': [5, 7, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0]],
            'A': [5, 7, [0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1]],
            'B': [5, 7, [1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0]],
            'C': [5, 7, [0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0]],
            'D': [5, 7, [1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0]],
            'E': [5, 7, [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1]],
            'F': [5, 7, [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0]],
            'G': [5, 7, [0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1]],
            'H': [5, 7, [1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1]],
            'I': [5, 7, [1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1]],
            'J': [5, 7, [0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0]],
            'K': [5, 7, [1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1]],
            'L': [5, 7, [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1]],
            'M': [5, 7, [1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1]],
            'N': [5, 7, [1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1]],
            'O': [5, 7, [0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0]],
            'P': [5, 7, [1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0]],
            'Q': [5, 7, [0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1]],
            'R': [5, 7, [1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1]],
            'S': [5, 7, [0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0]],
            'T': [5, 7, [1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0]],
            'U': [5, 7, [1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0]],
            'V': [5, 7, [1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0]],
            'W': [5, 7, [1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0]],
            'X': [5, 7, [1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1]],
            'Y': [5, 7, [1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0]],
            'Z': [5, 7, [1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1]],
            'a': [5, 7, []],
            'b': [5, 7, []],
            'c': [5, 7, []],
            'd': [5, 7, []],
            'e': [5, 7, []],
            'f': [5, 7, []],
            'g': [5, 7, []],
            'h': [5, 7, []],
            'i': [5, 7, []],
            'j': [5, 7, []],
            'k': [5, 7, []],
            'l': [5, 7, []],
            'm': [5, 7, []],
            'n': [5, 7, []],
            'o': [5, 7, []],
            'p': [5, 7, []],
            'q': [5, 7, []],
            'r': [5, 7, []],
            's': [5, 7, []],
            't': [5, 7, []],
            'u': [5, 7, []],
            'v': [5, 7, []],
            'w': [5, 7, []],
            'x': [5, 7, []],
            'y': [5, 7, []],
            'z': [5, 7, []]
          }
        };
      }

      return ImageData;

    })();
    return new ImageData();
  }
]);

angular.module('ModuleDataPack', []);

angular.module('ModuleDataPack').factory('DataPack', [
  function() {
    var DataPack, dataPack;
    DataPack = (function() {
      function DataPack() {}

      DataPack.prototype.data = {
        name: {
          male: ['Jackson', 'Aiden', 'Liam', 'Lucas', 'Noah', 'Jayden', 'Ethan', 'Jacob', 'Jack', 'Logan', 'Benjamin', 'Michael', 'Ryan', 'Alexander', 'Elijah', 'James', 'William', 'Oliver', 'Connor', 'Matthew', 'Daniel', 'Luke', 'Henry', 'Gabriel', 'Joshua', 'Nicholas', 'Isaac', 'Nathan', 'Andrew', 'Samuel', 'Christian', 'Evan', 'Charlie', 'David', 'Sebastian', 'Joseph', 'Anthony', 'John', 'Tyler', 'Zachary', 'Thomas', 'Julian', 'Adam', 'Isaiah', 'Alex', 'Aaron', 'Parker', 'Cooper', 'Miles', 'Chase', 'Christopher', 'Blake', 'Austin', 'Jordan', 'Leo', 'Jonathan', 'Adrian', 'Colin', 'Hudson', 'Ian', 'Xavier', 'Tristan', 'Jason', 'Brody', 'Nathaniel', 'Jake', 'Jeremiah', 'Elliot', 'Derek', 'Toby'],
          female: ['Sally', 'Lynn', 'Sophia', 'Emma', 'Olivia', 'Isabella', 'Mia', 'Ava', 'Lily', 'Zoe', 'Emily', 'Chloe', 'Layla', 'Madison', 'Madelyn', 'Abigail', 'Aubrey', 'Charlotte', 'Amelia', 'Ella', 'Kaylee', 'Avery', 'Aaliyah', 'Hailey', 'Hannah', 'Aria', 'Arianna', 'Lila', 'Evelyn', 'Grace', 'Ellie', 'Anna', 'Kaitlyn', 'Isabelle', 'Sophie', 'Scarlett', 'Natalie', 'Leah', 'Sarah', 'Nora', 'Mila', 'Elizabeth', 'Lillian', 'Kylie', 'Audrey', 'Lucy', 'Maya', 'Annabelle', 'Gabriella', 'Elena', 'Victoria', 'Claire', 'Savannah', 'Maria', 'Stella', 'Liliana', 'Allison', 'Samantha', 'Alyssa', 'Molly', 'Violet', 'Julia', 'Eva', 'Alice', 'Alexis', 'Kayla', 'Katherine', 'Lauren', 'Jasmine', 'Caroline', 'Vivian', 'Juliana']
        },
        buyable: ['a magazine', 'a new toy robot', 'a new diary', 'a book', 'a book about birds', 'a movie ticket'],
        itemsWithPrices: [[['types of pets', 'pet', 'prices', 'price', ['$', '']], [['Goldfish', 10], ['Kitten', 35], ['Puppy', 40], ['Ferret', 30], ['Iguana', 70], ['Parrot', 50], ['Parakeet', 20], ['Snake', 20], ['Turtle', 30], ['Frog', 10]]], [['types of fish', 'fish', 'prices', 'price', ['$', '']], [['Acei Cichlid', 10], ['African Cichlid', 10], ['African Featherfin Catfish', 20], ['African Knifefish', 10], ['Albino Cory Catfish', 5], ['Algae Eater', 5], ['Angelfish', 10], ['Angelicus Botia', 15], ['Auratus Cichlid', 10], ['Australian Rainbowfish', 5], ['Black Ghost Knifefish', 15], ['Black Moor Goldfish', 10], ['Boesemani Rainbowfish', 10], ['Peacock Eel', 15], ['Fancy Goldfish', 35], ['Pigeon Blood Discus', 400], ['Calico Ryukin Goldfish', 200], ['Elongated Mbuna', 80], ['Neon Tetra', 60], ['Serpae Tetra', 65], ['Snow White Socolofi', 75], ['Orange Sailfin Molly', 45], ['Red Sailfin Molly', 45], ['Red Swordtail', 40], ['Green Tiger Barb', 30], ['Plakat Betta', 40]]], [['cars', 'car', 'maximum speeds', 'maximum speed', ['', ' mph']], [['Nissan Centra', 120], ['Toyota Camry', 130], ['Honda Odyssey', 160], ['Dodge Caravan', 150], ['Dodge Caravan', 150], ['Mazda 626', 175], ['Mazda Protege', 165], ['Ford Mustang', 170], ['Cadillac', 160], ['Hummer H2', 120], ['Toyota Prius', 110], ['Tesla Model S', 145], ['Mercedes-Benz SLK', 140], ['BMW i3', 170], ['Subaru Outback', 135], ['Subaru Tribeca', 145], ['BMW x5', 150], ['Volkswagen Jetta', 160]]], [['types of boats', 'boat', 'lengths', 'length', ['', ' ft']], [['Class A small', 5], ['Class A medium', 10], ['Class A large', 15], ['Class 1 medium', 20], ['Class 1 large', 25], ['Class 2 medium', 30], ['Class 2 large', 35], ['Class 3 small', 40], ['Class 3 medium', 50], ['Class 3 large', 60]]]],
        item: {
          person: [[[['boy', 'boys'], ['girl', 'girls']], ['kid', 'children']], [[['boy', 'boys'], ['girl', 'girls']], ['kid', 'children']], [[['adult', 'adults'], ['kid', 'kids']], ['person', 'people']], [[['man', 'men'], ['woman', 'women']], ['person', 'people']]],
          bird: [[[['red bird', 'red birds'], ['blue bird', 'blue birds']], ['bird', 'birds']], [[['robin', 'robins'], ['sparrow', 'sparrows']]]],
          zoo: [[[['penguin', 'penguins'], ['meerkat', 'meerkats']]], [[['zebra', 'zebras'], ['deer', 'deers']]]],
          forest: [[[['wolf', 'wolves'], ['rabbit', 'rabbits']]], [[['pine tree', 'pine trees'], ['cedar tree', 'cedar trees']], ['cedar or pine tree', 'cedar and pine trees']], [[['bear', 'bears'], ['squirrel', 'squirrels']]]],
          animal: [[[['red bird', 'red birds'], ['blue bird', 'blue birds']], ['bird', 'birds']], [[['dog', 'dogs'], ['cat', 'cats']], ['animal', 'animals']], [[['mouse', 'mice'], ['cat', 'cats']]]],
          barn: [[[['dog', 'dogs'], ['cat', 'cats']], ['animal', 'animals']], [[['horse', 'horses'], ['cow', 'cows']]], [[['pig', 'pigs'], ['cow', 'cows']]], [[['duck', 'ducks'], ['chicken', 'chickens']]]],
          thing: [[[['orange candy', 'orange candies'], ['green candy', 'green candies']], ['candy', 'candies']], [[['red ball', 'red balls'], ['green ball', 'green balls']], ['ball', 'balls']], [[['red marble', 'red marbles'], ['blue marble', 'blue marbles']], ['marble', 'marbles']], [[['black pencil', 'black pencils'], ['red pencil', 'red pencils']], ['pencil', 'pencils']], [[['pencil', 'pencils'], ['pen', 'pens']]], [[['dime', 'dimes'], ['quarter', 'quarters']], ['coin', 'coins']], [[['apple', 'apples'], ['banana', 'bananas']]], [[['fruit', 'fruits'], ['vegetable', 'vegetables']]], [[['pea', 'peas'], ['carrot', 'carrots']]]]
        },
        location: {
          person: [[[''], ''], [[''], ''], [['room'], 'in the'], [['class', 'ballet class'], 'in the'], [['classroom'], 'in the'], [['building'], 'in the'], [['lobby'], 'in the'], [['hotel'], 'in the'], [['park'], 'in the'], [['museum'], 'in the'], [['train station'], 'at the'], [['playground'], 'on the'], [['school'], 'in the']],
          bird: [[[''], ''], [[''], ''], [['tree', 'tall'], 'on the', 'sitting'], [['park'], 'in the'], [['forest'], 'in the'], [['lake'], 'by the', 'sitting']],
          zoo: [[[''], ''], [[''], ''], [['zoo', 'local'], 'at the']],
          forest: [[[''], ''], [[''], ''], [['forest'], 'in the']],
          animal: [[[''], ''], [[''], ''], [[''], ''], [['city', 'small'], 'in the']],
          barn: [[[''], ''], [[''], ''], [['yard'], 'on the'], [['barn'], 'in the']],
          thing: [[[''], ''], [[''], ''], [['room'], 'in the'], [['box'], 'in the'], [['table'], 'on the'], [['room'], 'in the']]
        }
      };

      return DataPack;

    })();
    dataPack = new DataPack();
    document.numeric.modules.DataPack = dataPack;
    return dataPack;
  }
]);

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('ModuleDataUtilities', ['ModuleDataPack', 'BaseLib']);

angular.module('ModuleDataUtilities').factory('DataUtilities', [
  'DataPack', 'RandomFunctions', function(DataPack, RandomFunctions) {
    var DataUtilities, dataUtilities;
    DataUtilities = (function() {
      function DataUtilities() {
        this.randomName = __bind(this.randomName, this);
      }

      DataUtilities.prototype.d = DataPack;

      DataUtilities.prototype.r = RandomFunctions;

      DataUtilities.prototype.randomName = function() {
        var l1, l2, n1, name, names;
        names = this.d.data.name;
        l1 = names.male.length;
        l2 = names.female.length;
        n1 = this.r.random(0, l1 + l2);
        if (n1 >= l1) {
          name = [names.female[n1 - l1], 'she', 'her', 'her'];
        } else {
          name = [names.male[n1], 'he', 'him', 'his'];
        }
        return name;
      };

      DataUtilities.prototype.randomNames = function(n, filter) {
        var f, i, name, names, o, _i;
        o = [];
        names = [];
        f = function(n) {
          return (filter === void 0) || filter(n);
        };
        for (i = _i = 1; 1 <= n ? _i <= n : _i >= n; i = 1 <= n ? ++_i : --_i) {
          name = this.randomName();
          while ((o.indexOf(name[0]) > -1) || (!f(name[0]))) {
            name = this.randomName();
          }
          o.push(name[0]);
          names.push(name);
        }
        return names;
      };

      return DataUtilities;

    })();
    dataUtilities = new DataUtilities();
    document.numeric.modules.DataUtilities = dataUtilities;
    return dataUtilities;
  }
]);

angular.module('BaseLib', ['ImageLib']);

angular.module('BaseLib').filter('questionMark', function() {
  return function(input) {
    if (input === void 0) {
      return '?';
    } else {
      return input;
    }
  };
}).filter('epochToDate', function() {
  return function(input) {
    var e, r;
    if (input === void 0) {
      return '';
    } else {
      try {
        r = (new Date(input)).toUTCString().substr(5, 11);
      } catch (_error) {
        e = _error;
        r = '';
      }
      return r;
    }
  };
}).filter('underscore', function() {
  return function(input) {
    if (input === void 0 || input === '') {
      return '_';
    } else {
      return input;
    }
  };
}).filter('textOrLoading', function() {
  return function(input) {
    if (input === void 0) {
      return '';
    } else {
      return input;
    }
  };
}).filter('secsToMillis', function() {
  return function(input) {
    if (input === void 0 || isNaN(input)) {
      return input;
    } else {
      return Math.round(input / 1000);
    }
  };
}).filter('truncate', function() {
  return function(text, length, end) {
    if (isNaN(length)) {
      length = 27;
    }
    if (!end) {
      end = "...";
    }
    if (text.length <= length || (text.length - end.length) <= length) {
      return text;
    }
    return String(text).substring(0, length - end.length) + end;
  };
}).filter('firstCapital', function() {
  return function(input) {
    if (input === void 0) {
      return '';
    } else {
      return input.substring(0, 1).toUpperCase() + input.substring(1);
    }
  };
}).filter('orderObjectBy', function() {
  return function(items, field, reverse) {
    var filtered;
    filtered = [];
    angular.forEach(items, function(item) {
      return filtered.push(item);
    });
    filtered.sort(function(a, b) {
      if (a[field] > b[field]) {
        return 1;
      } else {
        return -1;
      }
    });
    if (reverse) {
      filtered.reverse();
    }
    return filtered;
  };
}).filter('secondsToHuman', function() {
  return function(allSeconds) {
    var allDays, allHours, allMinutes, days, hours, minutes, seconds;
    allDays = allSeconds / 86400;
    days = Math.floor(allDays);
    allSeconds = allSeconds - days * 86400;
    allHours = allSeconds / 3600;
    hours = Math.floor(allHours);
    allSeconds = allSeconds - hours * 3600;
    allMinutes = allSeconds / 60;
    minutes = Math.floor(allMinutes);
    allSeconds = allSeconds - minutes * 60;
    seconds = allSeconds;
    if (days > 1) {
      return "" + days + " days, " + hours + " hours, " + minutes + " minutes, " + seconds + " seconds";
    }
    if (days === 1) {
      return "1 day, " + hours + " hours, " + minutes + " minutes, " + seconds + " seconds";
    }
    if (hours > 1) {
      return "" + hours + " hours, " + minutes + " minutes, " + seconds + " seconds";
    }
    if (hours === 1) {
      return "1 hour, " + minutes + " minutes, " + seconds + " seconds";
    }
    if (minutes > 1) {
      return "" + minutes + " minutes, " + seconds + " seconds";
    }
    if (minutes === 1) {
      return "1 minute, " + seconds + " seconds";
    }
    if (seconds === 1) {
      return "1 second";
    }
    return "" + seconds + " seconds";
  };
}).filter('secondsToClock', function() {
  return function(allSeconds) {
    var allHours, allMinutes, hours, minutes, seconds;
    if (allSeconds === void 0 || isNaN(allSeconds)) {
      return "";
    }
    allHours = allSeconds / 3600;
    hours = Math.floor(allHours);
    allSeconds = allSeconds - hours * 3600;
    allMinutes = allSeconds / 60;
    minutes = Math.floor(allMinutes);
    if (minutes < 10) {
      minutes = "0" + minutes;
    }
    allSeconds = allSeconds - minutes * 60;
    seconds = allSeconds;
    if (seconds < 10) {
      seconds = "0" + seconds;
    }
    if (hours > 0) {
      return "" + hours + ":" + minutes + ":" + seconds + "";
    }
    return "" + minutes + ":" + seconds + "";
  };
});

angular.module('BaseLib').factory("MathFunctions", [
  function() {
    var MathFunctions, mathFunctions;
    MathFunctions = (function() {
      function MathFunctions() {}

      MathFunctions.prototype.gcd = function(a, b) {
        var c, _ref;
        if (a < 0) {
          a = -a;
        }
        if (b < 0) {
          b = -b;
        }
        if (a > b) {
          _ref = [b, a], a = _ref[0], b = _ref[1];
        }
        if (a === 0) {
          b;
        }
        if (b === 0) {
          a;
        }
        c = b - Math.floor(b / a) * a;
        if (c <= 0) {
          return a;
        } else {
          return this.gcd(c, a);
        }
      };

      MathFunctions.prototype.reduce = function(a, b) {
        var c;
        c = this.gcd(a, b);
        return [a / c, b / c];
      };

      return MathFunctions;

    })();
    mathFunctions = new MathFunctions();
    document.numeric.modules.MathFunctions = mathFunctions;
    return mathFunctions;
  }
]);

angular.module('BaseLib').factory("RandomFunctions", [
  function() {
    var RandomFunctions, randomFunctions;
    RandomFunctions = (function() {
      function RandomFunctions() {}

      RandomFunctions.prototype.random = function(a, b) {
        return a + ((Math.random() * (b - a)) | 0);
      };

      RandomFunctions.prototype.randomAB = function() {
        return this.random(0, 2) > 0;
      };

      RandomFunctions.prototype.randomFromList = function(list) {
        if (list === void 0 || list.length < 1) {
          return 0;
        }
        return list[this.random(0, list.length)];
      };

      RandomFunctions.prototype.randomPairFromList = function(list) {
        var n, n1, n2, pair;
        if (list === void 0 || list.length < 1) {
          return [];
        }
        n = list.length;
        if (n === 1) {
          return [list[0], list[0]];
        }
        pair = void 0;
        while (pair === void 0) {
          n1 = this.random(0, n);
          n2 = this.random(0, n);
          if (n1 !== n2) {
            pair = [list[n1], list[n2]];
          }
        }
        return pair;
      };

      RandomFunctions.prototype.randomNonRepeating = function(list, n) {
        var grow, remaining, remove, rn;
        if (!list || list.length < 1) {
          return [];
        }
        if (n > list.length) {
          n = list.length;
        } else if (n < 1) {
          n = 1;
        }
        remaining = list;
        rn = list.length;
        grow = [];
        while (n > 0) {
          remove = this.random(0, rn);
          grow = grow.concat(remaining.splice(remove, 1));
          n = n - 1;
          rn = rn - 1;
        }
        return grow;
      };

      RandomFunctions.prototype.randomDigits = function(n) {
        if (n > 10) {
          n = 10;
        }
        if (n < 1) {
          n = 1;
        }
        return this.randomNonRepeating([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], n);
      };

      RandomFunctions.prototype.randomVariableLetter = function() {
        return this.randomFromList('abcdefghkmnpqrstuvwyzABCDEFGHKLMNPQRSTUVWYZ');
      };

      RandomFunctions.prototype.shuffleListInPlace = function(a) {
        var i, j, _i, _ref, _ref1;
        if (a === void 0 || a.length < 2) {
          return;
        }
        for (i = _i = _ref = a.length - 1; _ref <= 1 ? _i <= 1 : _i >= 1; i = _ref <= 1 ? ++_i : --_i) {
          j = Math.floor(Math.random() * (i + 1));
          _ref1 = [a[j], a[i]], a[i] = _ref1[0], a[j] = _ref1[1];
        }
        return a;
      };

      RandomFunctions.prototype.shuffleAnswers4 = function(otherPossibleAnswers, correct) {
        var answers, index, tail;
        this.shuffleListInPlace(otherPossibleAnswers);
        index = this.random(0, 5);
        tail = otherPossibleAnswers.splice(index, 10);
        answers = otherPossibleAnswers.concat([correct]).concat(tail);
        return [answers, index];
      };

      RandomFunctions.prototype._someChars = 'z123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZAB';

      RandomFunctions.prototype._randomSomeChar = function() {
        return this._someChars[Math.random() * 64 | 0];
      };

      RandomFunctions.prototype.randomSomeString = function(n) {
        var i, s, _i;
        s = '';
        for (i = _i = 1; 1 <= n ? _i <= n : _i >= n; i = 1 <= n ? ++_i : --_i) {
          s = s + this._randomSomeChar();
        }
        return s;
      };

      return RandomFunctions;

    })();
    randomFunctions = new RandomFunctions();
    document.numeric.modules.RandomFunctions = randomFunctions;
    return randomFunctions;
  }
]);

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('BaseLib').factory("TextFunctions", [
  'RandomFunctions', function(RandomFunctions) {
    var TextFunctions, textFunctions;
    TextFunctions = (function() {
      function TextFunctions() {
        this.combine2 = __bind(this.combine2, this);
        this.combine3 = __bind(this.combine3, this);
        this.ifBthenwhatC = __bind(this.ifBthenwhatC, this);
        this.AwhatCifB = __bind(this.AwhatCifB, this);
        this.whatCifAandB = __bind(this.whatCifAandB, this);
        this.AandBwhatC = __bind(this.AandBwhatC, this);
        this.AifBthenwhatC = __bind(this.AifBthenwhatC, this);
      }

      TextFunctions.prototype.r = RandomFunctions;

      TextFunctions.prototype.capitalize = function(a) {
        if (a === void 0) {
          return '';
        }
        return a[0].toUpperCase() + a.slice(1, 10000);
      };

      TextFunctions.prototype.prettify = function(text) {
        var afterSpaced, append, az, letter, output, previousLetter, sentenceStop, skipBlack, skipBlank, upperCaseNext, _i, _len;
        if (text === void 0) {
          return '';
        }
        afterSpaced = '.,;-!?';
        sentenceStop = '.!?';
        az = 'abcdefghijklmnopqrstuvwxyz';
        output = '';
        previousLetter = void 0;
        upperCaseNext = true;
        skipBlack = true;
        for (_i = 0, _len = text.length; _i < _len; _i++) {
          letter = text[_i];
          append = letter.toLowerCase();
          if (az.indexOf(append) > -1 && upperCaseNext) {
            append = letter.toUpperCase();
            upperCaseNext = false;
          }
          if (sentenceStop.indexOf(letter) > -1) {
            upperCaseNext = true;
          }
          if (afterSpaced.indexOf(letter) > -1) {
            output += letter + ' ';
            append = '';
          }
          if (letter === ' ') {
            if (skipBlank) {
              append = '';
            }
            skipBlank = true;
          } else {
            skipBlank = false;
          }
          output += append;
        }
        output = output.trim().replace(' .', '.').replace(' ?', '?');
        return output;
      };

      TextFunctions.prototype.AifBthenwhatC = function(A, B, C, v) {
        var output;
        if (v !== void 0 && v !== '') {
          output = A + '. ' + v + ' ' + B + ', ' + C + '?';
        } else {
          output = A + '. ' + B + '. ' + C + '?';
        }
        return this.prettify(output);
      };

      TextFunctions.prototype.AandBwhatC = function(A, B, C, v) {
        var output;
        output = A + ', and ' + B + '. ' + C + '?';
        return this.prettify(output);
      };

      TextFunctions.prototype.whatCifAandB = function(A, B, C, v) {
        var output;
        output = C + ', if ' + A + ', and ' + B + '?';
        return this.prettify(output);
      };

      TextFunctions.prototype.AwhatCifB = function(A, B, C, v) {
        var output;
        if (v === void 0 || v === '') {
          v = 'if';
        }
        output = A + '. ' + C + ' ' + v + ' ' + B + '?';
        return this.prettify(output);
      };

      TextFunctions.prototype.ifBthenwhatC = function(B, C, v) {
        var output;
        if (v !== void 0 || v === '') {
          output = v + ' ' + B + ', ' + C + '?';
        } else {
          output = B + '. ' + C + '?';
        }
        return this.prettify(output);
      };

      TextFunctions.prototype.combine3 = function(A, B, C, v) {
        var s;
        s = this.r.randomFromList(['AifBthenwhatC', 'AandBwhatC', 'AwhatCifB']);
        v = this.r.randomFromList(['if', '']);
        return this[s](A, B, C, v);
      };

      TextFunctions.prototype.combine2 = function(B, C, v) {
        var s;
        s = this.r.randomFromList(['ifBthenwhatC']);
        v = this.r.randomFromList(['if', '']);
        return this[s](B, C, v);
      };

      TextFunctions.prototype.digitToWord = function(d) {
        var words;
        words = ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];
        return words[d];
      };

      TextFunctions.prototype.numberBelow20ToWord = function(num) {
        var below20;
        below20 = ['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen'];
        return below20[num];
      };

      TextFunctions.prototype.tensToWord = function(c) {
        var tens;
        tens = ['', 'ten', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];
        return tens[c];
      };

      TextFunctions.prototype.twoDigitToWords = function(c, d) {
        if (c < 2) {
          return '' + this.numberBelow20ToWord(c * 10 + d);
        } else {
          return '' + this.tensToWord(c) + ' ' + this.digitToWord(d);
        }
      };

      return TextFunctions;

    })();
    textFunctions = new TextFunctions();
    document.numeric.modules.TextFunctions = textFunctions;
    return textFunctions;
  }
]);

angular.module('BaseLib').factory("HyperTextManager", [
  function() {
    var HyperTextManager, hyperTextManager;
    HyperTextManager = (function() {
      function HyperTextManager() {}

      HyperTextManager.prototype.table = function(rows, headers) {
        var header, item, o, row, _i, _j, _k, _len, _len1, _len2;
        o = '<table class="problem-generated-table">';
        if (headers !== void 0) {
          o += '<tr>';
          for (_i = 0, _len = headers.length; _i < _len; _i++) {
            header = headers[_i];
            o += '<th>' + header + '</th>';
          }
          o += '</tr>';
        }
        for (_j = 0, _len1 = rows.length; _j < _len1; _j++) {
          row = rows[_j];
          o += '<tr>';
          for (_k = 0, _len2 = row.length; _k < _len2; _k++) {
            item = row[_k];
            o += '<td>' + item + '</td>';
          }
          o += '</tr>';
        }
        return o + '</table>';
      };

      HyperTextManager.prototype.tableWrapped = function(rows, headers) {
        var table;
        table = this.table(rows, headers);
        return "<span class='problem-generated-table-holder'>" + table + "</span>";
      };

      HyperTextManager.prototype.fraction = function(a, b) {
        var o;
        o = '<span class="fraction">';
        o += '<span class="fraction-top">' + a + '</span>';
        o += '<span class="fraction-bottom">' + b + '</span>';
        return o + '</span>';
      };

      HyperTextManager.prototype.graphic = function(imgdata, width, height) {
        var dim, o;
        if (width !== void 0 && height !== void 0) {
          dim = ' width="' + width + '" height="' + height + '" ';
        } else {
          dim = '';
        }
        o = '<span class="span-question-graphic">';
        o += '<img class="img-question-graphic" alt="img" src="' + imgdata + '"' + dim + '>';
        return o + '</span>';
      };

      return HyperTextManager;

    })();
    hyperTextManager = new HyperTextManager();
    document.numeric.modules.HyperTextManager = hyperTextManager;
    return hyperTextManager;
  }
]);

angular.module('ModuleSettings', ['ModulePersistence']);

angular.module('ModuleSettings').factory("Settings", [
  '$q', 'PersistenceManager', function($q, PersistenceManager) {
    var Settings;
    Settings = (function() {
      function Settings() {}

      Settings.prototype.init = function(key, defaults) {
        var deferred;
        this.key = key;
        this.defaults = defaults;
        deferred = $q.defer();
        this.writeThruCache = PersistenceManager.cacheWithwriteThruToLocalStorePersister(this.key);
        this.writeThruCache.init().then((function(_this) {
          return function(t) {
            _this.ready = true;
            return deferred.resolve(t);
          };
        })(this))["catch"]((function(_this) {
          return function(t) {
            if (t[0] === 0) {
              _this.ready = true;
              return deferred.resolve(0);
            } else {
              return deferred.reject(t);
            }
          };
        })(this));
        return deferred.promise;
      };

      Settings.prototype.getDefault = function(attr) {
        return this.defaults[attr];
      };

      Settings.prototype.get = function(attr) {
        var storedValue;
        storedValue = this.writeThruCache.get(attr);
        if (storedValue !== void 0) {
          return storedValue;
        } else {
          return this.defaults[attr];
        }
      };

      Settings.prototype.set = function(attr, newValue) {
        return this.writeThruCache.set(attr, newValue);
      };

      Settings.prototype.unset = function(attr) {
        return this.writeThruCache.remove(attr);
      };

      return Settings;

    })();
    return new Settings();
  }
]);

angular.module('ModulePersistence', []);

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('ModulePersistence').factory('PersistenceManager', [
  '$q', 'SerializationMethods', 'LocalStorageManager', 'FileStorageManager', 'ServerStorageManager', function($q, SerializationMethods, LocalStorageManager, FileStorageManager, ServerStorageManager) {
    var DictionaryCacheWriteThruStorePersister, DictionaryStoreBlockingPersister, DictionaryStorePersister, PersistenceManager, StoreBlockingPersister, StorePersister;
    PersistenceManager = (function() {
      function PersistenceManager() {
        this.localStore = LocalStorageManager;
        this.fileStore = FileStorageManager;
        this.serverStore = ServerStorageManager;
      }

      PersistenceManager.prototype.serialize = function(object) {
        return SerializationMethods.serialize(object);
      };

      PersistenceManager.prototype.deserialize = function(textData) {
        return SerializationMethods.deserialize(textData);
      };

      PersistenceManager.prototype.saveText = function(store, key, textData) {
        return store.saveText(key, textData);
      };

      PersistenceManager.prototype.readText = function(store, key) {
        return store.readText(key);
      };

      PersistenceManager.prototype.saveTextBlocking = function(store, key, textData) {
        return store.saveTextBlocking(key, textData);
      };

      PersistenceManager.prototype.readTextBlocking = function(store, key) {
        return store.readTextBlocking(key);
      };

      PersistenceManager.prototype.saveObject = function(store, key, object) {
        var deferred, t, textData;
        deferred = $q.defer();
        try {
          textData = this.serialize(object);
        } catch (_error) {
          t = _error;
          deferred.reject([1, t]);
          return deferred.promise;
        }
        this.saveText(store, key, textData).then(function(result) {
          return deferred.resolve(result);
        })["catch"](function(t) {
          return deferred.reject(t);
        });
        return deferred.promise;
      };

      PersistenceManager.prototype.readObject = function(store, key) {
        var deferred;
        deferred = $q.defer();
        this.readText(store, key).then((function(_this) {
          return function(textData) {
            var obj, t;
            try {
              obj = _this.deserialize(textData);
              deferred.resolve(obj);
            } catch (_error) {
              t = _error;
              deferred.reject([1, t]);
              return deferred.promise;
            }
            return deferred.resolve(obj);
          };
        })(this))["catch"](function(t) {
          return deferred.reject(t);
        });
        return deferred.promise;
      };

      PersistenceManager.prototype.saveObjectBlocking = function(store, key, object) {
        var t, textData;
        try {
          textData = this.serialize(object);
        } catch (_error) {
          t = _error;
          return null;
        }
        return this.saveTextBlocking(store, key, textData);
      };

      PersistenceManager.prototype.readObjectBlocking = function(store, key) {
        var obj, t, textData;
        try {
          textData = this.readTextBlocking(store, key);
          obj = this.deserialize(textData);
          return obj;
        } catch (_error) {
          t = _error;
          return null;
        }
      };

      PersistenceManager.prototype.save = function(key, object) {
        return this.saveObject(this.localStore, key, object);
      };

      PersistenceManager.prototype.read = function(key) {
        return this.readObject(this.localStore, key);
      };

      PersistenceManager.prototype.localStorePersister = function(key) {
        return new StorePersister(this, this.localStore, key);
      };

      PersistenceManager.prototype.localStoreBlockingPersister = function(key) {
        return new StoreBlockingPersister(this, this.localStore, key);
      };

      PersistenceManager.prototype.localStoreDictionaryPersister = function(key) {
        return new DictionaryStorePersister(this, this.localStore, key);
      };

      PersistenceManager.prototype.localStoreBlockingDictionaryPersister = function(key) {
        return new DictionaryStoreBlockingPersister(this, this.localStore, key);
      };

      PersistenceManager.prototype.cacheWithwriteThruToLocalStorePersister = function(key) {
        return new DictionaryCacheWriteThruStorePersister(this, this.localStore, key);
      };

      return PersistenceManager;

    })();
    StorePersister = (function() {
      function StorePersister(persistenceManager, store, key) {
        this.persistenceManager = persistenceManager;
        this.store = store;
        this.key = key;
      }

      StorePersister.prototype.read = function() {
        return this.persistenceManager.readObject(this.store, this.key);
      };

      StorePersister.prototype.save = function(table) {
        return this.persistenceManager.saveObject(this.store, this.key, table);
      };

      StorePersister.prototype.clear = function() {
        return this.persistenceManager.saveObject(this.store, this.key, {});
      };

      return StorePersister;

    })();
    StoreBlockingPersister = (function() {
      function StoreBlockingPersister(persistenceManager, store, key) {
        this.persistenceManager = persistenceManager;
        this.store = store;
        this.key = key;
      }

      StoreBlockingPersister.prototype.read = function() {
        return this.persistenceManager.readObjectBlocking(this.store, this.key);
      };

      StoreBlockingPersister.prototype.save = function(table) {
        return this.persistenceManager.saveObjectBlocking(this.store, this.key, table);
      };

      StoreBlockingPersister.prototype.clear = function() {
        return this.persistenceManager.saveObjectBlocking(this.store, this.key, {});
      };

      return StoreBlockingPersister;

    })();
    DictionaryStorePersister = (function() {
      function DictionaryStorePersister(persistenceManager, store, objkey) {
        this.persistenceManager = persistenceManager;
        this.store = store;
        this.objkey = objkey;
        this.remove = __bind(this.remove, this);
        this.set = __bind(this.set, this);
        this.get = __bind(this.get, this);
        this.persister = new StorePersister(this.persistenceManager, this.store, this.objkey);
      }

      DictionaryStorePersister.prototype.init = function() {
        var deferred;
        deferred = $q.defer();
        this.persister.read().then(function(val) {
          return deferred.resolve(val);
        })["catch"]((function(_this) {
          return function(t) {
            return _this.persister.clear().then(function() {
              return deferred.reject(t);
            });
          };
        })(this));
        return deferred.promise;
      };

      DictionaryStorePersister.prototype.get = function(key) {
        var deferred;
        deferred = $q.defer();
        this.persister.read().then((function(_this) {
          return function(table) {
            return deferred.resolve(table[key]);
          };
        })(this))["catch"]((function(_this) {
          return function(t) {
            return deferred.reject(t);
          };
        })(this));
        return deferred.promise;
      };

      DictionaryStorePersister.prototype.set = function(key, val) {
        var deferred;
        deferred = $q.defer();
        this.persister.read().then((function(_this) {
          return function(table) {
            table[key] = val;
            return _this.persister.save(table).then(function(result) {
              return deferred.resolve(result);
            })["catch"](function(result) {
              return deferred.reject(result);
            });
          };
        })(this))["catch"](function(result) {
          return deferred.reject(result);
        });
        return deferred.promise;
      };

      DictionaryStorePersister.prototype.remove = function(key) {
        return this.persister.read().then((function(_this) {
          return function(table) {
            if (table[key]) {
              delete table[key];
              return _this.persister.save(table);
            }
          };
        })(this));
      };

      DictionaryStorePersister.prototype.clear = function() {
        return this.persister.clear();
      };

      return DictionaryStorePersister;

    })();
    DictionaryStoreBlockingPersister = (function() {
      function DictionaryStoreBlockingPersister(persistenceManager, store, objkey) {
        this.persistenceManager = persistenceManager;
        this.store = store;
        this.objkey = objkey;
        this.remove = __bind(this.remove, this);
        this.set = __bind(this.set, this);
        this.get = __bind(this.get, this);
        this.getAll = __bind(this.getAll, this);
        this.persister = new StoreBlockingPersister(this.persistenceManager, this.store, this.objkey);
      }

      DictionaryStoreBlockingPersister.prototype.init = function() {
        var val;
        val = this.persister.read();
        if (val !== void 0 && val !== null) {
          return val;
        } else {
          this.persister.clear();
          return null;
        }
      };

      DictionaryStoreBlockingPersister.prototype.getAll = function(key) {
        return this.persister.read();
      };

      DictionaryStoreBlockingPersister.prototype.get = function(key) {
        var table;
        table = this.persister.read();
        return table[key];
      };

      DictionaryStoreBlockingPersister.prototype.set = function(key, val) {
        var table;
        table = this.persister.read();
        table[key] = val;
        return this.persister.save(table);
      };

      DictionaryStoreBlockingPersister.prototype.remove = function(key) {
        var table;
        table = this.persister.read();
        if (table[key]) {
          delete table[key];
          return this.persister.save(table);
        }
      };

      DictionaryStoreBlockingPersister.prototype.clear = function() {
        return this.persister.clear();
      };

      return DictionaryStoreBlockingPersister;

    })();
    DictionaryCacheWriteThruStorePersister = (function() {
      function DictionaryCacheWriteThruStorePersister(persistenceManager, store, objkey) {
        this.persistenceManager = persistenceManager;
        this.store = store;
        this.objkey = objkey;
        this.cache = {};
        this.persister = new DictionaryStorePersister(this.persistenceManager, this.store, this.objkey);
      }

      DictionaryCacheWriteThruStorePersister.prototype.init = function() {
        var deferred;
        deferred = $q.defer();
        this.persister.init().then((function(_this) {
          return function(saved) {
            var key, val;
            for (key in saved) {
              val = saved[key];
              _this.cache[key] = val;
            }
            return deferred.resolve(saved);
          };
        })(this))["catch"](function(t) {
          return deferred.reject(t);
        });
        return deferred.promise;
      };

      DictionaryCacheWriteThruStorePersister.prototype.get = function(key) {
        return this.cache[key];
      };

      DictionaryCacheWriteThruStorePersister.prototype.set = function(key, val) {
        this.cache[key] = val;
        return this.persister.set(key, val);
      };

      DictionaryCacheWriteThruStorePersister.prototype.remove = function(key) {
        if (this.cache[key]) {
          delete this.cache[key];
        }
        return this.persister.remove(key);
      };

      DictionaryCacheWriteThruStorePersister.prototype.clear = function() {
        var key, val, _ref;
        _ref = this.cache;
        for (key in _ref) {
          val = _ref[key];
          delete this.cache[key];
        }
        return this.persister.clear();
      };

      return DictionaryCacheWriteThruStorePersister;

    })();
    return new PersistenceManager();
  }
]);


var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('ModulePersistence').factory("FS", [
  '$q', 'md5', function($q, md5) {
    var FS;
    FS = (function() {
      function FS() {
        this.tryDeleteFile = __bind(this.tryDeleteFile, this);
        this.readDataFromFile = __bind(this.readDataFromFile, this);
        this.writeDataToFile = __bind(this.writeDataToFile, this);
        this.getContents = __bind(this.getContents, this);
        this.getFileSystem = __bind(this.getFileSystem, this);
        this.quota = 10;
        this.salt = 'only the first line of defence';
        window.requestFileSystem = window.requestFileSystem || window.webkitRequestFileSystem;
        this._getDirEntryRawName(document.numeric.url.base.numeric, {
          create: true
        }).then((function(_this) {
          return function() {
            return _this._getDirEntryRawName(document.numeric.url.base.fs, {
              create: true
            });
          };
        })(this)).then((function(_this) {
          return function() {
            return _this.getDirEntry(document.numeric.path.result, {
              create: true
            });
          };
        })(this)).then((function(_this) {
          return function() {
            return _this.getDirEntry(document.numeric.path.activity, {
              create: true
            });
          };
        })(this)).then((function(_this) {
          return function() {
            return _this.getDirEntry(document.numeric.path.body, {
              create: true
            });
          };
        })(this));
      }

      FS.prototype._errorHandler = function(dfd) {
        return function(e) {
          var msg;
          msg = (function() {
            switch (e.code) {
              case FileError.QUOTA_EXCEEDED_ERR:
                return 'QUOTA_EXCEEDED_ERR';
              case FileError.NOT_FOUND_ERR:
                return 'NOT_FOUND_ERR';
              case FileError.SECURITY_ERR:
                return 'SECURITY_ERR';
              case FileError.INVALID_MODIFICATION_ERR:
                return 'INVALID_MODIFICATION_ERR';
              case FileError.INVALID_STATE_ERR:
                return 'INVALID_STATE_ERR';
              default:
                return 'Unknown Error: ' + e.code;
            }
          })();
          console.log('ERROR: ' + msg);
          return dfd.reject(msg);
        };
      };

      FS.prototype._inCordova = function() {
        return typeof LocalFileSystem !== 'undefined';
      };

      FS.prototype._printEntries = function(entries) {
        var entry, _i, _len, _results;
        console.log('entries:');
        _results = [];
        for (_i = 0, _len = entries.length; _i < _len; _i++) {
          entry = entries[_i];
          _results.push(console.log(entry.name));
        }
        return _results;
      };

      FS.prototype._requestQuota = function() {
        var deferred;
        deferred = $q.defer();
        deferred.resolve(1);
        return deferred.promise;
      };

      FS.prototype.getFileSystem = function() {
        var deferred;
        deferred = $q.defer();
        if (this.fileSystem !== void 0) {
          deferred.resolve(this.fileSystem);
        } else if (this._inCordova()) {
          window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, (function(_this) {
            return function(fs) {
              _this.fileSystem = fs;
              return deferred.resolve(fs);
            };
          })(this), this._errorHandler(deferred));
        } else {
          console.log('running in a browser');
          this._requestQuota().then((function(_this) {
            return function(bytes) {
              return window.requestFileSystem(window.TEMPORARY, bytes, function(fs) {
                _this.fileSystem = fs;
                return deferred.resolve(fs);
              }, _this._errorHandler(deferred));
            };
          })(this))["catch"]((function(_this) {
            return function(status) {
              return deferred.reject(status);
            };
          })(this));
        }
        return deferred.promise;
      };

      FS.prototype._getDirEntryRawName = function(dirName, options) {
        var deferred;
        console.log('getting dirEntry: ' + dirName);
        deferred = $q.defer();
        this.getFileSystem().then((function(_this) {
          return function(fs) {
            if (dirName === '/') {
              return deferred.resolve(fs.root);
            } else {
              return fs.root.getDirectory(dirName, options, function(dirEntry) {
                return deferred.resolve(dirEntry);
              }, _this._errorHandler(deferred));
            }
          };
        })(this))["catch"](function(status) {
          return deferred.reject(status);
        });
        return deferred.promise;
      };

      FS.prototype.__getFileEntryRawName = function(fileName, options) {
        var deferred;
        console.log('getting fileEntry: ' + fileName);
        deferred = $q.defer();
        this.getFileSystem().then((function(_this) {
          return function(fs) {
            return fs.root.getFile(fileName, options, function(fileEntry) {
              return deferred.resolve(fileEntry);
            }, _this._errorHandler(deferred));
          };
        })(this))["catch"](function(status) {
          return deferred.reject(status);
        });
        return deferred.promise;
      };

      FS.prototype.getDirEntry = function(dirName, options) {
        return this._getDirEntryRawName(document.numeric.url.base.fs + dirName, options);
      };

      FS.prototype.getFileEntry = function(fileName, options) {
        return this.__getFileEntryRawName(document.numeric.url.base.fs + fileName, options);
      };

      FS.prototype.getContents = function(dirName) {
        var deferred;
        deferred = $q.defer();
        return this.getDirEntry(dirName, {
          create: false
        }).then((function(_this) {
          return function(dirEntry) {
            var directoryReader;
            console.log(dirEntry);
            console.log('fullPath:' + dirEntry.fullPath);
            console.log('toURL:' + dirEntry.toURL());
            directoryReader = dirEntry.createReader();
            return directoryReader.readEntries(_this._printEntries, _this._errorHandler);
          };
        })(this));
      };

      FS.prototype.getFileWriter = function(fileName) {
        var deferred;
        deferred = $q.defer();
        this.getFileEntry(fileName, {
          create: true,
          exclusive: false
        }).then((function(_this) {
          return function(fileEntry) {
            return fileEntry.createWriter(function(fileWriter) {
              return deferred.resolve(fileWriter);
            }, _this._errorHandler(deferred));
          };
        })(this))["catch"]((function(_this) {
          return function(status) {
            return deferred.reject(status);
          };
        })(this));
        return deferred.promise;
      };

      FS.prototype.getFileReader = function(fileName) {
        var deferred;
        deferred = $q.defer();
        this.getFileEntry(fileName, {
          create: false
        }).then(function(fileEntry) {
          return fileEntry.file(function(file) {
            var reader;
            reader = new FileReader();
            reader.onloadend = function(evt) {
              return deferred.resolve(evt.target.result);
            };
            return reader.readAsText(file);
          }, function(fail) {
            return deferred.reject(fail);
          });
        })["catch"](function(status) {
          return deferred.reject(status);
        });
        return deferred.promise;
      };

      FS.prototype.prepareText = function(textData) {
        if (textData === void 0) {
          textData = '';
        }
        if (this._inCordova()) {
          return textData;
        } else {
          return new Blob([textData], {
            type: 'text/plain'
          });
        }
      };

      FS.prototype.writeToFile = function(fileName, textData) {
        var deferred;
        deferred = $q.defer();
        this.getFileWriter(fileName).then((function(_this) {
          return function(fileWriter) {
            var preparedText;
            console.log('obtained filewriter for: ' + fileName);
            preparedText = _this.prepareText(textData);
            fileWriter.seek(0);
            window.fwfw = fileWriter;
            fileWriter.onwriteend = function() {
              console.log('finished writing');
              return deferred.resolve();
            };
            fileWriter.onerror = function(e) {
              return deferred.reject([1, e]);
            };
            return fileWriter.write(preparedText);
          };
        })(this))["catch"]((function(_this) {
          return function(status) {
            return deferred.reject(status);
          };
        })(this));
        return deferred.promise;
      };

      FS.prototype.readFromFile = function(fileName) {
        var deferred;
        deferred = $q.defer();
        this.getFileReader(fileName).then((function(_this) {
          return function(data) {
            return deferred.resolve(data);
          };
        })(this))["catch"]((function(_this) {
          return function(status) {
            return deferred.reject(status);
          };
        })(this));
        return deferred.promise;
      };

      FS.prototype.writeDataToFile = function(fileName, buffer, getHash) {
        var dataAsString, deferred;
        deferred = $q.defer();
        dataAsString = JSON.stringify(buffer);
        this.writeToFile(fileName, dataAsString).then((function(_this) {
          return function(data) {
            if (getHash) {
              return deferred.resolve(md5.createHash(dataAsString + _this.salt));
            } else {
              return deferred.resolve('ok');
            }
          };
        })(this))["catch"]((function(_this) {
          return function(status) {
            return deferred.reject(status);
          };
        })(this));
        return deferred.promise;
      };

      FS.prototype.readDataFromFile = function(fileName, checkHash) {
        var deferred;
        deferred = $q.defer();
        this.readFromFile(fileName).then((function(_this) {
          return function(data) {
            if (checkHash && checkHash !== md5.createHash(data + _this.salt)) {
              _this.tryDeleteFile(fileName);
              return deferred.resolve('mismatch');
            } else {
              return deferred.resolve(JSON.parse(data));
            }
          };
        })(this))["catch"]((function(_this) {
          return function(status) {
            return deferred.reject(status);
          };
        })(this));
        return deferred.promise;
      };

      FS.prototype.tryDeleteFile = function(fileName) {
        var deferred;
        deferred = $q.defer();
        this.getFileEntry(fileName, {
          create: false
        }).then((function(_this) {
          return function(fileEntry) {
            return fileEntry.remove(function(success) {
              return deferred.resolve('removed');
            }, function(status) {
              return deferred.resolve('could not remove, but it is alright');
            });
          };
        })(this), function(status) {
          return deferred.resolve('could not remove, but it is alright');
        });
        return deferred.promise;
      };

      return FS;

    })();
    return new FS();
  }
]);


angular.module('ModulePersistence').factory('SerializationMethods', [
  function() {
    var SerializationMethods;
    SerializationMethods = (function() {
      function SerializationMethods() {}

      SerializationMethods.prototype.serialize = function(object) {
        return JSON.stringify(object);
      };

      SerializationMethods.prototype.deserialize = function(textData) {
        return JSON.parse(textData);
      };

      return SerializationMethods;

    })();
    return new SerializationMethods();
  }
]);


angular.module('ModulePersistence').factory('FileStorageManager', [
  '$q', 'FS', function($q, FS) {
    var ModulePersistenceFileStorage;
    ModulePersistenceFileStorage = (function() {
      function ModulePersistenceFileStorage() {
        this.filesystem = FS;
      }

      ModulePersistenceFileStorage.prototype.readText = function(key) {
        var deferred;
        deferred = $q.defer();
        this.filesystem.readFromFile(key).then(function(textData) {
          return deferred.resolve(textData);
        })["catch"](function(t) {
          return deferred.reject(t);
        });
        return deferred.promise;
      };

      ModulePersistenceFileStorage.prototype.saveText = function(key, textData) {
        var deferred;
        deferred = $q.defer();
        this.filesystem.writeToFile(key, textData).then(function() {
          return deferred.resolve(0);
        })["catch"](function(t) {
          return deferred.reject(t);
        });
        return deferred.promise;
      };

      return ModulePersistenceFileStorage;

    })();
    return new ModulePersistenceFileStorage();
  }
]);

angular.module('ModulePersistence').factory('LocalStorageManager', [
  '$q', function($q) {
    var DefaultRawLocalStorage, ModuleLocalStorage;
    DefaultRawLocalStorage = (function() {
      function DefaultRawLocalStorage() {}

      DefaultRawLocalStorage.prototype.isAvailable = function() {
        return window.localStorage !== void 0;
      };

      DefaultRawLocalStorage.prototype.getItem = function(key) {
        return window.localStorage.getItem(key);
      };

      DefaultRawLocalStorage.prototype.setItem = function(key, val) {
        return window.localStorage.setItem(key, val);
      };

      DefaultRawLocalStorage.prototype.clear = function() {
        return window.localStorage.clear();
      };

      return DefaultRawLocalStorage;

    })();
    ModuleLocalStorage = (function() {
      function ModuleLocalStorage(rawStore) {
        this.rawStore = rawStore;
      }

      ModuleLocalStorage.prototype.clear = function() {
        return this.rawStore.clear();
      };

      ModuleLocalStorage.prototype.readText = function(key) {
        var deferred, t, textData;
        deferred = $q.defer();
        if (this.rawStore.isAvailable()) {
          try {
            textData = this.rawStore.getItem(key);
            if (textData === null || textData === void 0) {
              deferred.reject([0]);
            } else {
              deferred.resolve(textData);
            }
          } catch (_error) {
            t = _error;
            deferred.reject([1, t]);
          }
        } else {
          deferred.reject([-1]);
        }
        return deferred.promise;
      };

      ModuleLocalStorage.prototype.saveText = function(key, textData) {
        var deferred, t;
        deferred = $q.defer();
        if (this.rawStore.isAvailable()) {
          try {
            this.rawStore.setItem(key, textData);
            deferred.resolve(textData);
          } catch (_error) {
            t = _error;
            deferred.reject([1, t]);
          }
        } else {
          deferred.reject([-1]);
        }
        return deferred.promise;
      };

      ModuleLocalStorage.prototype.readTextBlocking = function(key) {
        var t, textData;
        if (this.rawStore.isAvailable()) {
          try {
            textData = this.rawStore.getItem(key);
            if (textData === null || textData === void 0) {
              return void 0;
            } else {
              return textData;
            }
          } catch (_error) {
            t = _error;
            return null;
          }
        } else {
          return null;
        }
      };

      ModuleLocalStorage.prototype.saveTextBlocking = function(key, textData) {
        var t;
        if (this.rawStore.isAvailable()) {
          try {
            this.rawStore.setItem(key, textData);
            return textData;
          } catch (_error) {
            t = _error;
            return null;
          }
        } else {
          return null;
        }
      };

      return ModuleLocalStorage;

    })();
    return new ModuleLocalStorage(new DefaultRawLocalStorage());
  }
]);

angular.module('ModulePersistence').factory('ServerStorageManager', ['$q', function($q) {}]);

angular.module('ModuleIdentity', ['ngMd5', 'ModulePersistence', 'BaseLib']);

angular.module('ModuleIdentity').factory('DeviceId', [
  'md5', 'PersistenceManager', 'RandomFunctions', function(md5, PersistenceManager, RandomFunctions) {
    var DeviceId;
    DeviceId = (function() {
      function DeviceId() {
        var ids;
        this.persister = PersistenceManager.localStoreBlockingPersister(document.numeric.key.deviceId);
        ids = this.persister.read();
        if (ids) {
          this.deviceSecretId = ids["private"];
          this.devicePublicId = ids["public"];
        } else {
          this.deviceSecretId = RandomFunctions.randomSomeString(50);
          this.devicePublicId = md5.createHash(this.deviceSecretId);
          this.persister.save({
            "private": this.deviceSecretId,
            "public": this.devicePublicId
          });
        }
      }

      return DeviceId;

    })();
    return new DeviceId();
  }
]);

angular.module('ModuleIdentity').factory('QRSignature', [
  function() {
    var QRSignature;
    QRSignature = (function() {
      function QRSignature() {}

      QRSignature.prototype.encode = function(input, dotsize) {
        var QRCodeVersion, black, c, canvas, err, errorChild, errorMSG, imgElement, padding, qr, qrCanvasContext, qrsize, r, shiftForPadding, white, _i, _j, _ref, _ref1;
        padding = 10;
        black = "rgb(0,0,0)";
        white = "rgb(255,255,255)";
        QRCodeVersion = 4;
        canvas = document.createElement('canvas');
        qrCanvasContext = canvas.getContext('2d');
        try {
          qr = new QRCode(QRCodeVersion, QRErrorCorrectLevel.L);
          qr.addData(input);
          qr.make();
        } catch (_error) {
          err = _error;
          errorChild = document.createElement("p");
          errorMSG = document.createTextNode("QR Code generation failed: " + err);
          errorChild.appendChild(errorMSG);
          return errorChild;
        }
        qrsize = qr.getModuleCount();
        canvas.setAttribute('height', (qrsize * dotsize) + padding);
        canvas.setAttribute('width', (qrsize * dotsize) + padding);
        shiftForPadding = padding / 2;
        if (canvas.getContext) {
          for (r = _i = 0, _ref = qrsize - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; r = 0 <= _ref ? ++_i : --_i) {
            for (c = _j = 0, _ref1 = qrsize - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; c = 0 <= _ref1 ? ++_j : --_j) {
              if (qr.isDark(r, c)) {
                qrCanvasContext.fillStyle = black;
              } else {
                qrCanvasContext.fillStyle = white;
              }
              qrCanvasContext.fillRect(c * dotsize + shiftForPadding, r * dotsize + shiftForPadding, dotsize, dotsize);
            }
          }
        }
        imgElement = document.createElement("img");
        imgElement.src = canvas.toDataURL("image/png");
        return imgElement;
      };

      return QRSignature;

    })();
    return new QRSignature();
  }
]);

angular.module('ModuleCommunication', ['ModuleSettings', 'ModuleIdentity', 'ModuleMessage', 'ModulePersistence']);

angular.module('ModuleCommunication').factory('ServerHttp', [
  '$q', '$http', 'Settings', 'DeviceId', 'MessageDispatcher', 'FS', function($q, $http, Settings, DeviceId, MessageDispatcher, FS) {
    var ServerHttp;
    ServerHttp = (function() {
      function ServerHttp() {}

      ServerHttp.prototype._inCordova = function() {
        return typeof LocalFileSystem !== 'undefined';
      };

      ServerHttp.prototype._baseCdv = function() {
        return document.numeric.url.base.cdv;
      };

      ServerHttp.prototype._baseChrome = function() {
        return document.numeric.url.base.chrome;
      };

      ServerHttp.prototype._baseCdvFs = function(path) {
        return this._baseCdv() + document.numeric.url.base.fs + path;
      };

      ServerHttp.prototype._base = function() {
        if (this._inCordova()) {
          return this._baseCdv();
        } else {
          return this._baseChrome();
        }
      };

      ServerHttp.prototype.appGroup = function() {
        return document.numeric.appGroup;
      };

      ServerHttp.prototype.appName = function() {
        return document.numeric.appName;
      };

      ServerHttp.prototype.version = function() {
        return document.numeric.appVersion;
      };

      ServerHttp.prototype.auth = function() {
        return '' + DeviceId.deviceSecretId + ':' + DeviceId.devicePublicId + ':' + this.appGroup() + ':' + this.appName() + ':' + this.version();
      };

      ServerHttp.prototype.get = function(url, options, cbtime) {
        var cb, deferred;
        deferred = $q.defer();
        if (cbtime === void 0) {
          cbtime = 1000;
        }
        cb = "cb=" + Math.round((new Date()) / cbtime);
        if (url.indexOf('?') > -1) {
          url = url + '&' + cb;
        } else {
          url = url + '?' + cb;
        }
        if (options !== void 0) {
          if (options.cache === void 0) {
            options.cache = false;
          }
          if (options.timeout === void 0) {
            options.timeout = 7000;
          }
          if (options.headers === void 0) {
            options.headers = {
              "Authorization": this.auth()
            };
          } else if (options.headers.Authorization === void 0) {
            options.headers.Authorization = '' + DeviceId.deviceSecretId;
          }
        } else {
          options = {
            cache: false,
            timeout: 7000,
            headers: {
              "Authorization": this.auth()
            }
          };
        }
        $http.get(url, options).then((function(_this) {
          return function(response) {
            var data;
            data = response.data;
            if (data !== void 0 && data.messages !== void 0 && data.content !== void 0) {
              MessageDispatcher.addNewMessages(data.messages);
              response.data = data.content;
            }
            return deferred.resolve(response);
          };
        })(this))["catch"]((function(_this) {
          return function(e) {
            return deferred.reject(e);
          };
        })(this));
        return deferred.promise;
      };

      ServerHttp.prototype.download = function(url, filePath) {
        var deferred;
        deferred = $q.defer();
        FS.tryDeleteFile(filePath).then(function(result) {
          return console.log('deleted previous version');
        })["catch"](function(status) {
          return console.log('could not delete previous version');
        }).then((function(_this) {
          return function(result) {
            return _this.get(url).then(function(response) {
              var data, t;
              try {
                data = response.data;
                return FS.writeToFile(filePath, data).then(function(response) {
                  return deferred.resolve('ok');
                })["catch"](function(e) {
                  return deferred.reject(e);
                });
              } catch (_error) {
                t = _error;
                return deferred.reject(t);
              }
            })["catch"](function(e) {
              return deferred.reject(e);
            });
          };
        })(this));
        return deferred.promise;
      };

      ServerHttp.prototype.post = function(url, data) {
        var deferred;
        console.log("post url: " + url);
        deferred = $q.defer();
        $http.defaults.headers.common.Authorization = this.auth();
        $http.post(url, data).then((function(_this) {
          return function(response) {
            data = response.data;
            if (data !== void 0 && data.messages !== void 0 && data.content !== void 0) {
              MessageDispatcher.addNewMessages(data.messages);
              response.data = data.content;
            }
            return deferred.resolve(response);
          };
        })(this))["catch"]((function(_this) {
          return function(e) {
            return deferred.reject(e);
          };
        })(this));
        return deferred.promise;
      };

      ServerHttp.prototype["delete"] = function(url) {
        var deferred;
        console.log("delete url: " + url);
        deferred = $q.defer();
        $http.defaults.headers.common.Authorization = this.auth();
        $http["delete"](url).then((function(_this) {
          return function(response) {
            var data;
            data = response.data;
            if (data !== void 0 && data.messages !== void 0 && data.content !== void 0) {
              MessageDispatcher.addNewMessages(data.messages);
              response.data = data.content;
            }
            return deferred.resolve(response);
          };
        })(this))["catch"]((function(_this) {
          return function(e) {
            return deferred.reject(e);
          };
        })(this));
        return deferred.promise;
      };

      return ServerHttp;

    })();
    return new ServerHttp();
  }
]);

angular.module('ModuleCommunication').factory('Tracker', [
  'Settings', 'ServerHttp', function(Settings, ServerHttp) {
    var Tracker;
    Tracker = (function() {
      function Tracker() {}

      Tracker.prototype.touch = function(page, id) {
        if (!Settings.ready) {
          return 0;
        }
        if (id === void 0) {
          id = "default";
        } else {

        }
        return ServerHttp.get(Settings.get('mainServerAddress') + document.numeric.path.touch + "/" + page + "/" + id, {
          timeout: 2000
        }, 10);
      };

      return Tracker;

    })();
    return new Tracker();
  }
]);

angular.module('ModuleMessage', ['ModulePersistence']);

angular.module('ModuleMessage').factory("MessageDispatcher", [
  'PersistenceManager', function(PersistenceManager) {
    var MessageDispatcher;
    MessageDispatcher = (function() {
      function MessageDispatcher() {
        var init;
        this.MAXSEENMSG = 20;
        this.persister = PersistenceManager.localStoreBlockingDictionaryPersister(document.numeric.key.messages);
        init = this.persister.init();
      }

      MessageDispatcher.prototype.cmp = function(s) {
        return function(a, b) {
          if (a[0] > b[0]) {
            return 1 * s;
          } else {
            return -1 * s;
          }
        };
      };

      MessageDispatcher.prototype.addNewMessages = function(msgs) {
        var msg, t, _i, _len, _results;
        try {
          _results = [];
          for (_i = 0, _len = msgs.length; _i < _len; _i++) {
            msg = msgs[_i];
            _results.push(this.addNewMessage(msg));
          }
          return _results;
        } catch (_error) {
          t = _error;
          return console.log('could not add messages from server');
        }
      };

      MessageDispatcher.prototype.addNewMessage = function(msg) {
        var id, prev, priority, t;
        try {
          if (msg === void 0 || msg.content === void 0 || msg.id === void 0 || msg.priority === void 0) {
            return void 0;
          }
          id = Number(msg.id);
          priority = Number(msg.priority);
          if (isNaN(id) || isNaN(priority)) {
            return void 0;
          }
          prev = this.persister.get(msg.id);
          if (prev === void 0) {
            msg.seen = false;
            msg.id = id;
            msg.priority = priority;
            msg.rcvdTime = (new Date()).getTime();
            return this.persister.set(msg.id, msg);
          }
        } catch (_error) {
          t = _error;
          return console.log('could not add new message');
        }
      };

      MessageDispatcher.prototype.markAsSeen = function(msg) {
        msg = this.persister.get(msg.id);
        msg.seen = true;
        return this.persister.set(msg.id, msg);
      };

      MessageDispatcher.prototype.removeMessage = function(msg) {
        return this.persister.remove(msg.id);
      };

      MessageDispatcher.prototype.removeOneSeenMessageIfCloseToMax = function(all) {
        var id, msg, seen, t;
        try {
          if (all.length > this.MAXSEENMSG) {
            seen = (function() {
              var _results;
              _results = [];
              for (id in all) {
                msg = all[id];
                if (msg.seen) {
                  _results.push([msg.rcvdTime, msg]);
                }
              }
              return _results;
            })();
            if (seen.length < 1) {
              return void 0;
            }
            seen.sort(this.cmp(1));
            msg = seen[0][1];
            return this.removeMessage(msg);
          }
        } catch (_error) {
          t = _error;
          return void 0;
        }
      };

      MessageDispatcher.prototype.getMessageToShow = function() {
        var all, id, msg, t, unseen;
        try {
          all = this.persister.getAll();
          if (all === void 0 || all.length < 1) {
            return void 0;
          }
          this.removeOneSeenMessageIfCloseToMax(all);
          unseen = (function() {
            var _results;
            _results = [];
            for (id in all) {
              msg = all[id];
              if (!msg.seen) {
                _results.push([msg.priority, msg]);
              }
            }
            return _results;
          })();
          if (unseen.length < 1) {
            return void 0;
          }
          unseen.sort(this.cmp(-1));
          msg = unseen[0][1];
          this.markAsSeen(msg);
          return msg;
        } catch (_error) {
          t = _error;
          return void 0;
        }
      };

      return MessageDispatcher;

    })();
    return new MessageDispatcher();
  }
]);

angular.module('ActivityLib', ['ngRoute', 'ModuleSettings', 'ModuleCommunication', 'ModulePersistence', 'ModuleDataPack', 'ModuleDataUtilities', 'BaseLib']);


angular.module('ActivityLib').controller('ChannelCtrl', [
  '$scope', '$routeParams', '$location', '$sce', 'Settings', 'Tracker', 'Channels', 'ActivityDriver', 'StarPracticeApi', function($scope, $routeParams, $location, $sce, Settings, Tracker, Channels, ActivityDriver, StarPracticeApi) {
    var getActivities;
    if (!Settings.ready) {
      return $location.path('/');
    } else {
      Tracker.touch('channel', Channels.current.id);
    }
    $scope.toggleDetailsId = function(activityId) {
      if ($scope.detailsId === activityId) {
        $scope.detailsId = void 0;
        return;
      }
      return $scope.detailsId = activityId;
    };
    $scope.stringActivities = Settings.get('stringActivities');
    $scope.channelName = Channels.current.name;
    $scope.Channels = Channels;
    getActivities = function(searchTerm) {
      $scope.errorStatus = false;
      $scope.availableActivities = Channels.getChannelActivitiesFromCache($scope.startIndex, $scope.pageSize, searchTerm);
      if ($scope.availableActivities.activities !== void 0) {
        $scope.endIndex = $scope.startIndex + $scope.availableActivities.activities.length;
        $scope.littleHistory = $scope.availableActivities.activities.length < Settings.get('pageSize') && $scope.startIndex === 0;
        $scope.loadingList = false;
      } else {
        $scope.endIndex = 0;
        $scope.littleHistory = true;
        $scope.loadingList = true;
      }
      return Channels.getChannelActivities($scope.startIndex, $scope.pageSize, searchTerm).then((function(_this) {
        return function(response) {
          $scope.errorStatus = void 0;
          $scope.availableActivities.activities = response.data.activities;
          if ($scope.availableActivities.activities !== void 0) {
            $scope.endIndex = $scope.startIndex + $scope.availableActivities.activities.length;
            return $scope.littleHistory = $scope.availableActivities.activities.length < Settings.get('pageSize') && $scope.startIndex === 0;
          } else {
            $scope.endIndex = 0;
            return $scope.littleHistory = true;
          }
        };
      })(this))["catch"](function(status) {
        console.log('Could not get list of activity metas from server, status: ' + status);
        if ($scope.availableActivities.activities === void 0 || $scope.availableActivities.activities.length < 1) {
          return $scope.errorStatus = status;
        }
      }).then(function() {
        return $scope.loadingList = false;
      });
    };
    $scope.tryGettingAgain = function() {
      return getActivities($scope.searchTerm);
    };
    $scope.searchPublic = function() {
      var term;
      term = $scope.searchTerm;
      if (term === void 0) {
        return;
      }
      term = term.trim();
      if (term.length < 3) {
        return;
      }
      return getActivities(term);
    };
    $scope.littleHistory = true;
    $scope.startIndex = Channels.newFirst;
    $scope.pageSize = Settings.get('pageSize');
    $scope.endIndex = $scope.startIndex + $scope.pageSize;
    $scope.turnPage = function(distance) {
      if ($scope.startIndex + distance <= 0) {
        if ($scope.startIndex === 0) {
          return 1;
        } else {
          $scope.startIndex = 0;
        }
      } else if (distance < 0) {
        $scope.startIndex = $scope.startIndex - $scope.pageSize;
      } else if ($scope.endIndex < $scope.startIndex + $scope.pageSize) {
        return 1;
      } else {
        $scope.startIndex = $scope.startIndex + $scope.pageSize;
      }
      $scope.endIndex = $scope.startIndex + $scope.pageSize;
      return $scope.tryGettingAgain();
    };
    $scope.tryGettingAgain();
    return $scope.tryStartActivity = function(activityId, version) {
      $scope.startingActivityId = activityId;
      return ActivityDriver.trySetActivity(activityId, version).then(function(activity) {
        return $location.path('/task');
      })["catch"](function(status) {
        console.log(status);
        $scope.startingActivityId = void 0;
        return alert('could not start activity');
      });
    };
  }
]);

angular.module('ActivityLib').controller('ChannelListCtrl', [
  '$scope', '$location', '$sce', 'Settings', 'Tracker', 'Channels', function($scope, $location, $sce, Settings, Tracker, Channels) {
    var getChannels;
    if (!Settings.ready) {
      return $location.path('/');
    } else {
      Tracker.touch('channelList');
    }
    $scope.start = 0;
    $scope.size = 10;
    getChannels = function(searchTerm) {
      $scope.loadingList = true;
      return Channels.getChannels($scope.start, $scope.size, searchTerm).then(function(response) {
        $scope.errorStatus = void 0;
        return $scope.channels = response.data.channels;
      })["catch"](function(status) {
        console.log('Could not get list of channels from server, status: ' + status);
        return $scope.errorStatus = status;
      }).then(function() {
        return $scope.loadingList = false;
      });
    };
    getChannels($scope.searchTerm);
    $scope.tryGettingAgain = function() {
      return getChannels($scope.searchTerm);
    };
    $scope.searchPublic = function() {
      var term;
      term = $scope.searchTerm;
      if (term === void 0) {
        return;
      }
      term = term.trim();
      if (term.length < 3) {
        return;
      }
      return getChannels(term);
    };
    return $scope.navigateToChannel = function(id, name) {
      return Channels.navigateToChannel(id, name, '#/channelList');
    };
  }
]);

angular.module('ActivityLib').controller('HistoryCtrl', [
  '$scope', '$location', 'Settings', 'ActivitySummary', 'Tracker', function($scope, $location, Settings, ActivitySummary, Tracker) {
    if (!Settings.ready) {
      return $location.path('/');
    } else {
      Tracker.touch('history');
    }
    $scope.stringHistory = Settings.get('stringHistory');
    $scope.activitySummariesInfoAll = ActivitySummary.getAllSummaries();
    $scope.totalItems = $scope.activitySummariesInfoAll.length;
    $scope.noHistory = $scope.activitySummariesInfoAll.length < 1;
    $scope.littleHistory = $scope.activitySummariesInfoAll.length < Settings.get('pageSize');
    $scope.$watch('activitySummariesInfoAll', function(newValue, oldValue) {
      $scope.noHistory = newValue.length < 1;
      return $scope.totalItems = newValue.length;
    }, true);
    $scope.getPage = (function(_this) {
      return function(start, end) {
        return $scope.activitySummariesInfo = ActivitySummary.getAllSummariesPage(start, end);
      };
    })(this);
    $scope.refreshList = function() {
      ActivitySummary.newFirst = $scope.startIndex;
      return $scope.getPage($scope.startIndex, $scope.endIndex);
    };
    $scope.pageSize = Settings.get('pageSize');
    $scope.turnPage = function(distance) {
      if ($scope.startIndex + distance < 0 || $scope.totalItems < 1) {
        $scope.startIndex = 0;
      } else if ($scope.startIndex + distance >= $scope.totalItems) {
        $scope.startIndex = Math.floor(($scope.totalItems - 1) / $scope.pageSize) * $scope.pageSize;
      } else {
        $scope.startIndex = $scope.startIndex + distance;
      }
      $scope.endIndex = Math.min($scope.startIndex + $scope.pageSize, $scope.totalItems);
      return $scope.refreshList();
    };
    $scope.startIndex = ActivitySummary.newFirst;
    $scope.turnPage(0);
    return $scope.navigateToItem = function(timestamp) {
      ActivitySummary.setCurrentItem(timestamp, '#/history');
      return $location.path('/historyItem');
    };
  }
]).controller('HistoryItemCtrl', [
  '$scope', '$location', '$sce', 'Settings', 'Tracker', 'ActivitySummary', function($scope, $location, $sce, Settings, Tracker, ActivitySummary) {
    if (!Settings.ready) {
      return $location.path('/');
    } else {
      Tracker.touch('historyitem', ActivitySummary.current.id);
    }
    $scope.stringHistoryItem = Settings.get('stringHistoryItem');
    $scope.showSubmitLink = Settings.get('showSubmitLink');
    $scope.backButton = ActivitySummary.current.back;
    $scope.searchAll = function(value, index) {
      return true;
    };
    $scope.searchStarred = function(value, index) {
      return value[5] !== void 0 && value[5][0];
    };
    $scope.searchNoted = function(value, index) {
      return value[5] !== void 0 && value[5][1] !== false;
    };
    $scope.searchCorrect = function(value, index) {
      return value[3];
    };
    $scope.searchWrong = function(value, index) {
      return !value[3];
    };
    $scope.searchModel = $scope.searchAll;
    return ActivitySummary.getSummaryById(ActivitySummary.current.id).then(function(data) {
      var response;
      if (data === 'mismatch') {
        $scope.mismatch = true;
      } else {
        $scope.mismatch = false;
        $scope.activityName = data.activityName;
        $scope.timestamp = data.endTime;
        $scope.responses = (function() {
          var _i, _len, _ref, _results;
          _ref = data.responses;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            response = _ref[_i];
            _results.push([$sce.trustAsHtml('' + response[0]), $sce.trustAsHtml('' + response[1]), $sce.trustAsHtml('' + response[2]), response[3], response[4], response[5]]);
          }
          return _results;
        })();
        $scope.correct = data.runningTotals.correct;
        $scope.wrong = data.runningTotals.wrong;
        $scope.total = data.runningTotals.correct + data.runningTotals.wrong;
        $scope.totalSeconds = Math.round((data.endTime - data.startTime) / 1000);
        $scope.avgSeconds = Math.round(((data.endTime - data.startTime) / $scope.total) / 1000);
      }
      return $scope.ready = true;
    })["catch"](function(status) {
      console.log(status);
      $scope.mismatch = true;
      return $scope.ready = true;
    });
  }
]);

angular.module('ActivityLib').controller('HomeCtrl', [
  '$scope', '$location', '$sce', 'Settings', 'Tracker', 'StarPracticeApi', 'MessageDispatcher', 'Channels', 'ActivitySummary', 'Tags', function($scope, $location, $sce, Settings, Tracker, StarPracticeApi, MessageDispatcher, Channels, ActivitySummary, Tags) {
    var setScopeVars;
    setScopeVars = function() {
      var application, msg;
      Tracker.touch('home');
      $scope.settingsLoaded = true;
      msg = MessageDispatcher.getMessageToShow();
      if (msg !== void 0) {
        $scope.showMessage = true;
        $scope.message = $sce.trustAsHtml(msg.content);
      } else {
        $scope.showMessage = false;
        $scope.message = '';
      }
      $scope.navigateToTagsOrChannel = function(id, name) {
        if (Tags.hasTags()) {
          return Tags.navigateToTags();
        } else {
          if (id === void 0 || name === void 0) {
            id = Settings.get('defaultChannel');
            name = 'Public';
          }
          return Channels.navigateToChannel(id, name, '#/');
        }
      };
      $scope.hasHistory = ActivitySummary.hasHistory();
      $scope.stringTitle = Settings.get('stringTitle');
      $scope.showSettings = Settings.get('showSettings');
      $scope.showTabPractice = Settings.get('showTabPractice');
      $scope.stringPractice = Settings.get('stringPractice');
      $scope.showTabHistory = Settings.get('showTabHistory');
      $scope.stringHistory = Settings.get('stringHistory');
      application = document.numeric.application;
      if (application === void 0) {
        return $location.path('/');
      }
      $scope.customDisplay = application.customDisplay;
      return $scope.customTabs = document.numeric.customTabs;
    };
    if (Settings.ready) {
      return setScopeVars();
    } else {
      $scope.settingsLoaded = false;
      return Settings.init(document.numeric.key.settings, document.numeric.defaultSettings).then((function(_this) {
        return function() {
          return setScopeVars();
        };
      })(this))["catch"]((function(_this) {
        return function(t) {
          return $scope.errorMessage = 'Application needs some local storage enabled to work.';
        };
      })(this));
    }
  }
]);

angular.module('ActivityLib').controller('InfoCtrl', [
  '$scope', '$location', 'Settings', 'Application', 'Tracker', function($scope, $location, Settings, Application, Tracker) {
    var infoTitle;
    if (!Settings.ready) {
      return $location.path('/');
    } else {
      Tracker.touch('info');
    }
    $scope.infoTitle = Application.stringInfoTitle;
    if (infoTitle === void 0) {
      infoTitle = 'Info';
    }
    return $scope.infoHtml = Application.stringInfoHtml;
  }
]);

angular.module('ActivityLib').controller('SettingsCtrl', [
  '$scope', '$location', 'Settings', 'Tracker', function($scope, $location, Settings, Tracker) {
    if (!Settings.ready) {
      return $location.path('/');
    } else {
      Tracker.touch('settings');
    }
    $scope.getAttr = function(attr) {
      return Settings.get(attr);
    };
    $scope.setAttr = function(attr, newVal) {
      return Settings.set(attr, newVal);
    };
    $scope.defaultMainServerAddress = Settings.getDefault('mainServerAddress');
    $scope.mainServerAddress = Settings.get('mainServerAddress');
    $scope.newMainServerAddress = Settings.get('mainServerAddress');
    $scope.mainServerAddress_set = function() {
      var newVal;
      newVal = $scope.newMainServerAddress.trim().replace('http://', 'https://');
      if (newVal.length === 0) {
        return;
      }
      if (newVal[newVal.length - 1] !== '/') {
        newVal = newVal + '/';
      }
      Settings.set('mainServerAddress', newVal);
      $scope.mainServerAddress = Settings.get('mainServerAddress');
      return $scope.newMainServerAddress = $scope.mainServerAddress;
    };
    $scope.mainServerAddress_reset = function() {
      Settings.unset('mainServerAddress');
      $scope.mainServerAddress = Settings.get('mainServerAddress');
      return $scope.newMainServerAddress = Settings.get('mainServerAddress');
    };
    return $scope.clearLocalStorage = function() {
      return window.localStorage.clear();
    };
  }
]);

angular.module('ActivityLib').controller('TagsCtrl', [
  '$scope', '$routeParams', '$location', '$sce', 'Settings', 'Tracker', 'Channels', 'ActivityDriver', 'StarPracticeApi', function($scope, $routeParams, $location, $sce, Settings, Tracker, Channels, ActivityDriver, StarPracticeApi) {
    if (!Settings.ready) {
      return $location.path('/');
    } else {
      return Tracker.touch('tags');
    }
  }
]);

angular.module('ActivityLib').controller('TaskCtrl', [
  '$scope', '$rootScope', '$location', 'Settings', 'Tracker', 'TaskCtrlState', 'ActivityDriver', 'ActivitySummary', 'StarPracticeApi', function($scope, $rootScope, $location, Settings, Tracker, TaskCtrlState, ActivityDriver, ActivitySummary, StarPracticeApi) {
    if (!Settings.ready) {
      return $location.path('/');
    } else {
      Tracker.touch('task', ActivityDriver.currentActivity.id);
    }
    $scope.title = Settings.get('title');
    $scope.activityDriver = ActivityDriver;
    $scope.currentActivity = ActivityDriver.currentActivity;
    $scope.state = TaskCtrlState.setScope($scope);
    $scope.hasAnswers = function() {
      return ActivityDriver.statsCorrect > 0 || ActivityDriver.statsWrong > 0;
    };
    $scope.finishActivity = function() {
      if ($scope.hasAnswers()) {
        return ActivityDriver.tryFinishActivity().then(function(timestamp) {
          ActivitySummary.setCurrentItem(timestamp, '#/channel');
          return $location.path('/historyItem');
        })["catch"](function(status) {
          console.log('could not save activity: ' + status);
          return $location.path('/channel');
        });
      } else {
        return $location.path('/channel');
      }
    };
    $rootScope.$on('end-of-test', $scope.finishActivity);
    $scope.toPrevQuestion = (function(_this) {
      return function(toSave) {
        var val;
        document.getElementById('problemContainer').scrollTop = 0;
        document.getElementById('optionsContainer').scrollTop = 0;
        document.getElementById('prevQuestionContainer').scrollTop = 0;
        $scope.isOnReviewLast = true;
        $scope.isOnOptions = false;
        $scope.isOnNote = false;
        if (toSave !== void 0 && toSave.note && $scope.noteToAdd !== void 0) {
          val = $scope.noteToAdd.trim();
          if (val.length > 0) {
            ActivityDriver.addNotePrev(val);
          } else {
            ActivityDriver.addNotePrev(false);
          }
        }
        return true;
      };
    })(this);
    $scope.toOptions = (function(_this) {
      return function() {
        document.getElementById('problemContainer').scrollTop = 0;
        document.getElementById('optionsContainer').scrollTop = 0;
        document.getElementById('prevQuestionContainer').scrollTop = 0;
        $scope.optionsChanged = false;
        $scope.isOnReviewLast = false;
        $scope.isOnOptions = true;
        return $scope.isOnNote = false;
      };
    })(this);
    $scope.toExitWindow = (function(_this) {
      return function() {
        $scope.optionsChanged = false;
        $scope.isOnReviewLast = false;
        $scope.isOnOptions = false;
        $scope.isOnNote = false;
        return $scope.isOnExit = true;
      };
    })(this);
    $scope.toAddNote = (function(_this) {
      return function(options) {
        var prevNote;
        document.getElementById('problemContainer').scrollTop = 0;
        document.getElementById('optionsContainer').scrollTop = 0;
        document.getElementById('prevQuestionContainer').scrollTop = 0;
        $scope.optionsChanged = false;
        $scope.isOnReviewLast = false;
        $scope.isOnOptions = false;
        $scope.isOnNote = true;
        if (options !== void 0 && options.prev) {
          prevNote = ActivityDriver.addedNotePrev();
          if (prevNote !== false) {
            $scope.noteToAdd = prevNote;
          } else {
            $scope.noteToAdd = '';
          }
          $scope.noteToAddDestinationCurrent = false;
        } else {
          if (ActivityDriver.addedNote !== false) {
            $scope.noteToAdd = ActivityDriver.addedNote;
          } else {
            $scope.noteToAdd = '';
          }
          $scope.noteToAddDestinationCurrent = true;
        }
        return $scope.noteToAddOrig = $scope.noteToAdd;
      };
    })(this);
    $scope.noteHasChanged = function() {
      return $scope.noteToAdd !== $scope.noteToAddOrig;
    };
    $scope.backToActivity = (function(_this) {
      return function(toSave) {
        var val;
        document.getElementById('problemContainer').scrollTop = 0;
        document.getElementById('optionsContainer').scrollTop = 0;
        document.getElementById('prevQuestionContainer').scrollTop = 0;
        if ($scope.optionsChanged && $scope.isOnOptions) {
          $scope.optionsChanged = false;
          ActivityDriver.newQuestion(true);
        }
        $scope.isOnOptions = false;
        $scope.isOnReviewLast = false;
        $scope.isOnNote = false;
        $scope.isOnExit = false;
        if (toSave !== void 0 && toSave.note) {
          if ($scope.noteToAdd !== void 0 && (val = $scope.noteToAdd.trim()).length > 0) {
            ActivityDriver.addNote(val);
          } else {
            ActivityDriver.addNote(false);
          }
        }
        return true;
      };
    })(this);
    $scope.selectParamValue = (function(_this) {
      return function(paramKey, level) {
        var jump;
        $scope.optionsChanged = true;
        jump = ActivityDriver.selectParamValue(paramKey, level);
        if (jump) {
          return $scope.backToActivity();
        }
      };
    })(this);
    $scope.testStar = false;
    $scope.menuShowOptions = function() {
      return $scope.toOptions();
    };
    $scope.menuShowOptions_has = function() {
      return ActivityDriver.currentActivity.parameters !== void 0;
    };
    $scope.menuToggleStar = function() {
      return ActivityDriver.toggleStar();
    };
    $scope.menuToggleStar_has = function() {
      return ActivityDriver.toggledStar;
    };
    $scope.menuToggleStarPrev = function() {
      if ($scope.hasAnswers() && !ActivityDriver.finishing) {
        return ActivityDriver.toggleStarPrev();
      } else {
        return false;
      }
    };
    $scope.menuToggleStarPrev_has = function() {
      if ($scope.hasAnswers() && !ActivityDriver.finishing) {
        return ActivityDriver.toggledStarPrev();
      } else {
        return false;
      }
    };
    return ActivityDriver.start($scope);
  }
]);

angular.module('ActivityLib').factory("TaskCtrlState", [
  '$location', function($location) {
    var TaskCtrlState;
    TaskCtrlState = (function() {
      function TaskCtrlState() {}

      TaskCtrlState.prototype.setScope = function(scope) {
        this.scope = scope;
        return this;
      };

      TaskCtrlState.prototype.backButton = function() {
        console.log((new Date()) - this.lastTime);
        if (this.lastTime !== void 0 && (new Date()) - this.lastTime < 500) {
          return 1;
        }
        this.lastTime = new Date();
        console.log(this.scope.isOnNote);
        console.log(this.scope.isOnOptions);
        if (this.scope.isOnNote && this.scope.noteToAddDestinationCurrent) {
          this.scope.backToActivity({
            note: true
          });
        } else if (this.scope.isOnNote && !this.scope.noteToAddDestinationCurrent) {
          this.scope.toPrevQuestion({
            note: true
          });
        } else if (this.scope.isOnOptions || this.scope.isOnReviewLast || this.scope.isOnExit) {
          this.scope.backToActivity();
        } else {
          this.scope.toExitWindow();
        }
        return this.scope.$digest();
      };

      return TaskCtrlState;

    })();
    return new TaskCtrlState();
  }
]);

angular.module('ActivityLib').config([
  '$routeProvider', function($routeProvider) {
    var appName, customTabs, firstCapital, tab, _i, _len, _results;
    appName = document.numeric.appName;
    $routeProvider.when('/', {
      templateUrl: '/assets/apps/' + appName + '/templates/home.html',
      controller: 'ApplicationCtrl'
    }).when('/home', {
      templateUrl: '/assets/apps/' + appName + '/templates/home.html',
      controller: 'HomeCtrl'
    }).when('/info', {
      templateUrl: '/assets/apps/' + appName + '/templates/info.html',
      controller: 'InfoCtrl'
    }).when('/channelList', {
      templateUrl: '/assets/apps/' + appName + '/templates/channelList.html',
      controller: 'ChannelListCtrl'
    }).when('/channel', {
      templateUrl: '/assets/apps/' + appName + '/templates/channel.html',
      controller: 'ChannelCtrl'
    }).when('/tags', {
      templateUrl: '/assets/apps/' + appName + '/templates/tags.html',
      controller: 'TagsCtrl'
    }).when('/task', {
      templateUrl: '/assets/apps/' + appName + '/templates/task.html',
      controller: 'TaskCtrl'
    }).when('/history', {
      templateUrl: '/assets/apps/' + appName + '/templates/history.html',
      controller: 'HistoryCtrl'
    }).when('/historyItem', {
      templateUrl: '/assets/apps/' + appName + '/templates/historyItem.html',
      controller: 'HistoryItemCtrl'
    }).when('/settings', {
      templateUrl: '/assets/apps/' + appName + '/templates/settings.html',
      controller: 'SettingsCtrl'
    }).when('/connect', {
      templateUrl: '/assets/apps/' + appName + '/templates/connect.html',
      controller: 'ConnectCtrl'
    }).when('/myIdentity', {
      templateUrl: '/assets/apps/' + appName + '/templates/myIdentity.html',
      controller: 'MyIdentityCtrl'
    }).when('/teachers', {
      templateUrl: '/assets/apps/' + appName + '/templates/teachers.html',
      controller: 'TeachersCtrl'
    }).when('/addTeacher', {
      templateUrl: '/assets/apps/' + appName + '/templates/addTeacher.html',
      controller: 'AddTeacherCtrl'
    }).when('/test', {
      templateUrl: '/assets/apps/' + appName + '/templates/test.html',
      controller: 'TestCtrl'
    }).when('/sampleQuestion', {
      templateUrl: '/assets/apps/' + appName + '/templates/sampleQuestion.html',
      controller: 'SampleQuestionCtrl'
    }).otherwise({
      redirectTo: '/'
    });
    firstCapital = function(input) {
      if (input === void 0) {
        return '';
      } else {
        return input.substring(0, 1).toUpperCase() + input.substring(1);
      }
    };
    customTabs = document.numeric.customTabs;
    if (customTabs !== void 0) {
      _results = [];
      for (_i = 0, _len = customTabs.length; _i < _len; _i++) {
        tab = customTabs[_i];
        $routeProvider.when('/' + tab.page, {
          templateUrl: '/assets/apps/' + appName + '/templates/' + tab.page + '.html',
          controller: firstCapital(tab.page) + 'Ctrl'
        });
        _results.push(console.log('adding: ' + tab.page));
      }
      return _results;
    }
  }
]).run([
  '$route', '$location', 'TaskCtrlState', function($route, $location, TaskCtrlState) {
    $route.reload();
    document.addEventListener("backbutton", (function(_this) {
      return function() {
        var currentPath;
        currentPath = $location.path();
        if (typeof currentPath !== 'undefined' && currentPath.substr(0, 5) === "/task") {
          return TaskCtrlState.backButton();
        }
        if (typeof currentPath !== 'undefined' && currentPath.substr(0, 12) === "/historyItem") {
          $location.path('/history');
        } else {
          $location.path('/');
        }
        return $route.reload();
      };
    })(this), false);
    return document.addEventListener("menubutton", (function(_this) {
      return function() {
        var currentPath;
        currentPath = $location.path();
        console.log('menu button, current: ' + currentPath);
        if (typeof currentPath !== 'undefined' && currentPath.substr(0, 5) === "/task") {
          return;
        }
        if (typeof currentPath !== 'undefined' && currentPath.substr(0, 9) === "/settings") {
          return;
        }
        $location.path('/settings');
        return $route.reload();
      };
    })(this), false);
  }
]).config([
  '$compileProvider', '$httpProvider', function($compileProvider, $httpProvider) {
    $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|cdvfile|ftp|mailto|file|tel):/);
    return $httpProvider.defaults.useXDomain = true;
  }
]);


var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('ActivityLib').factory("ActivityDriver", [
  '$timeout', '$sce', '$q', 'ActivityLoader', 'ActivitySummary', function($timeout, $sce, $q, ActivityLoader, ActivitySummary) {
    var Activity, ActivityDriver;
    Activity = (function() {
      function Activity(currentTask) {
        this.currentTask = currentTask;
        this.id = this.currentTask.id;
        this.name = this.currentTask.meta.name;
        this.parameters = this.currentTask.parameters;
      }

      Activity.prototype.lettered = function(n) {
        return ' ' + "ABCDEFGH"[n] + ') ';
      };

      Activity.prototype.newQuestion = function() {
        var choice, i, questionStatement, _ref;
        this.question = this.currentTask.createNextQuestion();
        if (this.question === void 0) {
          return void 0;
        }
        if (this.question.answerType === 'numeric') {
          this.inputTypeNumeric = true;
          this.inputTypeMultipleChoice = false;
          this.questionStatementChoices = void 0;
          this.questionStatementAsHTML_ = this.question.statement;
          this.questionStatementAsHTML = $sce.trustAsHtml(this.question.statement);
        } else if (this.question.answerType === 'multiple') {
          this.inputTypeNumeric = false;
          this.inputTypeMultipleChoice = true;
          this.questionStatementChoices_ = this.question.choices;
          questionStatement = this.question.statement + '<div class="problem-ol-mult-choice-holder"><ol type="A" class="problem-ol-mult-choice">';
          _ref = this.question.choices;
          for (i in _ref) {
            choice = _ref[i];
            questionStatement += '<li>' + choice + '</li>';
          }
          questionStatement += '</ol></div>';
          this.questionStatementAsHTML_ = questionStatement;
          this.questionStatementAsHTML = $sce.trustAsHtml(questionStatement);
        } else {
          return void 0;
        }
        if (this.question.sizingClassCode) {
          if (this.question.sizingClassCode = 5) {
            this.sizingClass = 'sizeMakeSmaller';
          } else {
            this.sizingClass = 'sizeKeepSame';
          }
        } else {
          this.sizingClass = 'sizeKeepSame';
        }
        return this;
      };

      Activity.prototype.answerString = function(answer) {
        var answerString;
        answerString = answer;
        if (this.inputTypeMultipleChoice) {
          answerString = this.lettered(answerString) + this.questionStatementChoices_[answerString];
        }
        return answerString;
      };

      Activity.prototype.answerStringActual = function() {
        var answerString;
        answerString = this.question.getAnswer();
        if (this.inputTypeMultipleChoice) {
          answerString = this.lettered(answerString) + this.questionStatementChoices_[answerString];
        }
        return answerString;
      };

      Activity.prototype.checkAnswer = function(answer) {
        return this.question.checkAnswer(answer);
      };

      return Activity;

    })();
    ActivityDriver = (function() {
      ActivityDriver.prototype._markCorrectResult = function() {
        this.statsCorrect = this.statsCorrect + 1;
        return this.result = {
          "class": 'correct',
          verbal: 'Excellent!'
        };
      };

      ActivityDriver.prototype._markWrongResult = function() {
        this.statsWrong = this.statsWrong + 1;
        return this.result = {
          "class": 'incorrect',
          verbal: 'Wrong...'
        };
      };

      ActivityDriver.prototype.clearResult = function() {
        return this.result = {
          "class": 'none',
          verbal: ''
        };
      };

      ActivityDriver.prototype.resetStats = function() {
        this.statsCorrect = 0;
        this.statsWrong = 0;
        this.totalTime = NaN;
        return this.startTime = new Date();
      };

      ActivityDriver.prototype._clearLastQuestion = function() {
        return this.answeredQuestion = {
          statement: '',
          "class": 'correct',
          time: ''
        };
      };

      ActivityDriver.prototype.trySetActivity = function(activityId, version) {
        var deferred;
        deferred = $q.defer();
        ActivityLoader.loadActivity(activityId, version).then((function(_this) {
          return function(activity) {
            _this.setActivity(activity);
            return deferred.resolve(0);
          };
        })(this))["catch"](function(status) {
          console.log(status);
          return deferred.reject(status);
        });
        return deferred.promise;
      };

      ActivityDriver.prototype.setActivity = function(currentTask) {
        this.currentTask = currentTask;
        this.currentActivity = new Activity(this.currentTask);
        this.taskName = this.currentTask.meta.name;
        return this.currentActivity;
      };

      ActivityDriver.prototype.start = function(scope) {
        this.scope = scope;
        this.finishing = false;
        this.clearResult();
        this.resetStats();
        this._clearLastQuestion();
        this.newQuestion();
        this.startTime = new Date();
        return ActivitySummary.init(this.currentTask.id, this.currentTask.meta.name);
      };

      ActivityDriver.prototype.tryFinishActivity = function() {
        var deferred;
        this.finishing = true;
        deferred = $q.defer();
        ActivitySummary.finish().then(function(timestamp) {
          return deferred.resolve(timestamp);
        })["catch"](function(status) {
          console.log('error finishing task:' + status);
          return deferred.reject(status);
        });
        return deferred.promise;
      };

      ActivityDriver.prototype.selectParamValue = function(key, value) {
        this.currentActivity.parameters[key].selectedValue = value;
        if (this.currentActivity.parameters[key].jump) {
          return true;
        } else {
          return false;
        }
      };

      ActivityDriver.prototype.clearNotesBuffer = function() {
        this.toggledStar = false;
        return this.addedNote = false;
      };

      ActivityDriver.prototype.toggleStar = function() {
        return this.toggledStar = !this.toggledStar;
      };

      ActivityDriver.prototype.addNote = function(note) {
        if (note === false) {
          return this.addedNote = false;
        }
        if (note === void 0 || note.length < 1) {
          return 1;
        }
        return this.addedNote = note.substr(0, 300);
      };

      ActivityDriver.prototype.toggleStarPrev = function() {
        return ActivitySummary.togglePrevStar();
      };

      ActivityDriver.prototype.toggledStarPrev = function() {
        return ActivitySummary.getPrevStar();
      };

      ActivityDriver.prototype.addedNotePrev = function() {
        return ActivitySummary.getPrevNote();
      };

      ActivityDriver.prototype.addNotePrev = function(note) {
        if (note === false) {
          return ActivitySummary.setPrevNote(false);
        }
        if (note === void 0 || note.length < 1) {
          return 1;
        }
        return ActivitySummary.setPrevNote(note.substr(0, 300));
      };

      ActivityDriver.prototype.newQuestion = function(keepClock) {
        var e;
        this.totalTime = Math.round((new Date() - this.startTime) / 1000);
        this.answer = void 0;
        try {
          this.question = this.currentActivity.newQuestion();
        } catch (_error) {
          e = _error;
          console.log(e);
          try {
            this.question = this.currentActivity.newQuestion();
          } catch (_error) {
            e = _error;
            console.log(e);
            try {
              this.question = this.currentActivity.newQuestion();
            } catch (_error) {
              e = _error;
              console.log(e);
              alert('activity exited');
              this.question = void 0;
            }
          }
        }
        if (this.question === void 0) {
          this.scope.$broadcast('end-of-test');
          this.scope.$broadcast('timer-stop');
          return;
        }
        this.questionStatementAsHTML = this.question.questionStatementAsHTML;
        document.getElementById('problemContainer').scrollTop = 0;
        this.clearNotesBuffer();
        if (!keepClock) {
          return this.scope.$broadcast('timer-start');
        }
      };

      ActivityDriver.prototype._checkAnswer = function(answer) {
        this.scope.$broadcast('timer-stop');
        this.answeredQuestion = {
          statement: this.question.questionStatementAsHTML_,
          statementAsHTML: this.question.questionStatementAsHTML,
          answer: this.currentActivity.answerString(answer),
          answerAsHTML: $sce.trustAsHtml('' + this.currentActivity.answerString(answer)),
          actualAnswer: this.currentActivity.answerStringActual(),
          actualAnswerAsHTML: $sce.trustAsHtml('' + this.currentActivity.answerStringActual())
        };
        if (this.currentActivity.checkAnswer(answer)) {
          this._markCorrectResult();
          this.answeredQuestion.result = true;
        } else {
          this._markWrongResult();
          this.answeredQuestion.result = false;
        }
        this.answeredQuestion.addedNote = this.addedNote;
        this.answeredQuestion.toggledStar = this.toggledStar;
        return ActivitySummary.add(this.answeredQuestion);
      };

      ActivityDriver.prototype.pressed = function(digit) {
        if (this.answer === void 0) {
          this.answer = 0;
        }
        return this.answer = this.answer * 10 + digit;
      };

      ActivityDriver.prototype.clear = function() {
        return this.answer = void 0;
      };

      ActivityDriver.prototype.enter = function() {
        if (this.answer !== void 0) {
          this._checkAnswer(this.answer);
          return this.newQuestion();
        }
      };

      ActivityDriver.prototype.pressedChoice = function(choice) {
        this._checkAnswer(choice);
        return this.newQuestion();
      };

      function ActivityDriver() {
        this._checkAnswer = __bind(this._checkAnswer, this);
        this.clearResult();
        this.resetStats();
        this._clearLastQuestion();
      }

      return ActivityDriver;

    })();
    return new ActivityDriver();
  }
]);

var ActivityLoader,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

ActivityLoader = (function() {
  function ActivityLoader($q, Settings, ServerHttp, FS) {
    this.$q = $q;
    this.Settings = Settings;
    this.ServerHttp = ServerHttp;
    this.FS = FS;
    this.removeCachedActivity = __bind(this.removeCachedActivity, this);
    this.loadActivity = __bind(this.loadActivity, this);
    this._tryCachedActivity = __bind(this._tryCachedActivity, this);
    this._loadScriptFromCache = __bind(this._loadScriptFromCache, this);
    this._createScriptTagAndLoad = __bind(this._createScriptTagAndLoad, this);
  }

  ActivityLoader.prototype._pathToBody = function(activityId) {
    return document.numeric.path.body + activityId;
  };

  ActivityLoader.prototype._uriCache = function(activityId) {
    var cb, uri;
    uri = this._inCordova() ? document.numeric.url.base.cdv : document.numeric.url.base.chrome;
    cb = "?cb=" + Math.round((new Date()) / 1);
    return uri + document.numeric.url.base.fs + this._pathToBody(activityId) + cb;
  };

  ActivityLoader.prototype._uriRemote = function(activityId) {
    return this.Settings.get('mainServerAddress') + this._pathToBody(activityId);
  };

  ActivityLoader.prototype._scriptId = 'script_currentlyLoaded';

  ActivityLoader.prototype._inCordova = function() {
    return typeof LocalFileSystem !== 'undefined';
  };

  ActivityLoader.prototype._createScriptTagAndLoad = function(uri, activityId) {
    var deferred, e, newScript;
    console.log('__ attempt to load script with activityId: ' + activityId + ' and uri: ' + uri);
    deferred = this.$q.defer();
    try {
      newScript = document.createElement('script');
      newScript.type = 'text/javascript';
      newScript.id = this._scriptId;
      newScript.onload = (function(_this) {
        return function() {
          var activity;
          if (document.numeric.numericTasks[activityId]) {
            activity = document.numeric.numericTasks[activityId];
            delete document.numeric.numericTasks[activityId];
            return deferred.resolve(activity);
          } else {
            return deferred.reject('could not load script with tag due to some error');
          }
        };
      })(this);
      newScript.onerror = (function(_this) {
        return function(status) {
          return deferred.reject(status);
        };
      })(this);
      newScript.src = uri;
      try {
        document.getElementsByTagName('head')[0].removeChild(document.getElementById(this._scriptId));
      } catch (_error) {
        e = _error;
      }
      document.getElementsByTagName('head')[0].appendChild(newScript);
    } catch (_error) {
      e = _error;
      deferred.reject(e);
    }
    return deferred.promise;
  };

  ActivityLoader.prototype._loadScriptFromCache = function(activityId) {
    var deferred;
    deferred = this.$q.defer();
    this._createScriptTagAndLoad(this._uriCache(activityId), activityId).then((function(_this) {
      return function(activity) {
        var e;
        try {
          document.getElementsByTagName('head')[0].removeChild(document.getElementById(_this._scriptId));
        } catch (_error) {
          e = _error;
        }
        return deferred.resolve(activity);
      };
    })(this))["catch"]((function(_this) {
      return function(status) {
        var e;
        try {
          document.getElementsByTagName('head')[0].removeChild(document.getElementById(_this._scriptId));
        } catch (_error) {
          e = _error;
        }
        return deferred.reject(status);
      };
    })(this));
    return deferred.promise;
  };

  ActivityLoader.prototype._tryCachedActivity = function(activityId, version) {
    var deferred;
    deferred = this.$q.defer();
    this._loadScriptFromCache(activityId).then((function(_this) {
      return function(activity) {
        if (activity !== void 0 && activity.id === activityId && (version === void 0 || (activity.meta !== void 0 && version === activity.meta.version))) {
          return deferred.resolve(activity);
        } else {
          return deferred.reject('cached activity is older');
        }
      };
    })(this))["catch"]((function(_this) {
      return function(status) {
        return deferred.reject(status);
      };
    })(this));
    return deferred.promise;
  };

  ActivityLoader.prototype.loadActivity = function(activityId, version) {
    var deferred;
    if (version !== void 0) {
      version = Number(version);
    }
    deferred = this.$q.defer();
    if (this._loadedActivity !== void 0 && this._loadedActivity.id === activityId && (version === void 0 || (this._loadedActivity.meta !== void 0 && version === this._loadedActivity.meta.version))) {
      deferred.resolve(this._loadedActivity);
    } else {
      this._tryCachedActivity(activityId, version)["catch"]((function(_this) {
        return function(status) {
          return _this.ServerHttp.download(_this._uriRemote(activityId), _this._pathToBody(activityId)).then(function() {
            return _this._tryCachedActivity(activityId, version);
          });
        };
      })(this)).then((function(_this) {
        return function(activity) {
          _this._loadedActivity = activity;
          return deferred.resolve(_this._loadedActivity);
        };
      })(this))["catch"]((function(_this) {
        return function(status) {
          return deferred.reject(status);
        };
      })(this));
    }
    return deferred.promise;
  };

  ActivityLoader.prototype.removeCachedActivity = function(activityId) {
    var deferred;
    deferred = this.$q.defer();
    this.FS.tryDeleteFile(this._pathToBody(activityId)).then((function(_this) {
      return function(result) {
        return deferred.resolve(result);
      };
    })(this))["catch"]((function(_this) {
      return function(status) {
        return deferred.reject(status);
      };
    })(this));
    return deferred.promise;
  };

  return ActivityLoader;

})();

angular.module('ActivityLib').factory("ActivityLoader", [
  '$q', 'Settings', 'ServerHttp', 'FS', function($q, Settings, ServerHttp, FS) {
    return new ActivityLoader($q, Settings, ServerHttp, FS);
  }
]);

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('ActivityLib').factory("ActivitySummary", [
  '$q', 'FS', 'PersistenceManager', function($q, FS, PersistenceManager) {
    var ActivitySummary;
    ActivitySummary = (function() {
      ActivitySummary.prototype.current = {};

      ActivitySummary.prototype.newFirst = 0;

      function ActivitySummary() {
        this.finish = __bind(this.finish, this);
        this.removeSummaryById = __bind(this.removeSummaryById, this);
        this.currentActivityPersister = PersistenceManager.localStoreBlockingPersister(document.numeric.key.currentActivitySummary);
        this.activitySummariesPersister = PersistenceManager.localStoreBlockingPersister(document.numeric.key.storedActivitySummaries);
        if (!this.activitySummariesPersister.read()) {
          this.activitySummariesPersister.save({
            items: []
          });
        }
        this._extra = "Just the first line of defense.";
      }

      ActivitySummary.prototype.setCurrentItem = function(id, back) {
        this.current.id = id;
        return this.current.back = back;
      };

      ActivitySummary.prototype.__baseFormat = function() {
        return {
          activityId: '',
          activityName: '',
          runningTotals: {
            correct: 0,
            wrong: 0
          },
          responses: []
        };
      };

      ActivitySummary.prototype._addToAllSummaries = function(summaryInfo) {
        var table;
        table = this.activitySummariesPersister.read();
        table.items.unshift(summaryInfo);
        return this.activitySummariesPersister.save(table);
      };

      ActivitySummary.prototype._removeFromAllSummaries = function(timestamp) {
        var itemToDelete, key, table, val, _ref;
        table = this.activitySummariesPersister.read();
        itemToDelete = void 0;
        _ref = table.items;
        for (key in _ref) {
          val = _ref[key];
          if (Number(val.timestamp) === Number(timestamp)) {
            itemToDelete = key;
          }
        }
        if (itemToDelete !== void 0) {
          table.items.splice(itemToDelete, 1);
        }
        return this.activitySummariesPersister.save(table);
      };

      ActivitySummary.prototype.hasHistory = function() {
        return this.getAllSummaries().length > 0;
      };

      ActivitySummary.prototype.getAllSummaries = function() {
        return this.activitySummariesPersister.read().items;
      };

      ActivitySummary.prototype.getAllSummariesPage = function(start, end) {
        return this.getAllSummaries().slice(start, end);
      };

      ActivitySummary.prototype.getFromAllSummaries = function(timestamp) {
        var item, items, _i, _len;
        items = this.getAllSummaries();
        for (_i = 0, _len = items.length; _i < _len; _i++) {
          item = items[_i];
          if (parseInt(item.timestamp) === parseInt(timestamp)) {
            return item;
          }
        }
        return void 0;
      };

      ActivitySummary.prototype.removeSummaryById = function(timestamp) {
        var deferred, filename;
        deferred = $q.defer();
        filename = document.numeric.path.result + timestamp;
        FS.tryDeleteFile(filename).then((function(_this) {
          return function(data) {
            _this._removeFromAllSummaries();
            return _this.deferred.resolve(data);
          };
        })(this))["catch"]((function(_this) {
          return function(status) {
            return deferred.reject(status);
          };
        })(this));
        return deferred.promise;
      };

      ActivitySummary.prototype.getSummaryById = function(timestamp) {
        var deferred, filename, summary;
        deferred = $q.defer();
        summary = this.getFromAllSummaries(timestamp);
        filename = document.numeric.path.result + timestamp;
        FS.readDataFromFile(filename, summary.hash).then((function(_this) {
          return function(buffer) {
            if (buffer === 'mismatch') {
              _this._removeFromAllSummaries(timestamp);
            }
            return deferred.resolve(buffer);
          };
        })(this))["catch"]((function(_this) {
          return function(status) {
            _this._removeFromAllSummaries(timestamp);
            return deferred.reject(status);
          };
        })(this));
        return deferred.promise;
      };

      ActivitySummary.prototype.init = function(activityId, activityName) {
        var buffer;
        buffer = this.__baseFormat();
        buffer.activityId = activityId;
        buffer.activityName = activityName;
        buffer.startTime = (new Date()).getTime();
        this.currentActivityPersister.save(buffer);
        return this.lastTimePoint = (new Date()).getTime();
      };

      ActivitySummary.prototype.add = function(answeredQuestion) {
        var buffer;
        buffer = this.currentActivityPersister.read();
        if (answeredQuestion.result) {
          buffer.runningTotals.correct = buffer.runningTotals.correct + 1;
        } else {
          buffer.runningTotals.wrong = buffer.runningTotals.wrong + 1;
        }
        buffer.responses.push([answeredQuestion.statement, answeredQuestion.answer, answeredQuestion.actualAnswer, answeredQuestion.result, (new Date()) - this.lastTimePoint, [answeredQuestion.toggledStar, answeredQuestion.addedNote]]);
        this.currentActivityPersister.save(buffer);
        return this.lastTimePoint = (new Date()).getTime();
      };

      ActivitySummary.prototype.finish = function() {
        var buffer, deferred, filename;
        deferred = $q.defer();
        buffer = this.currentActivityPersister.read();
        buffer.endTime = this.lastTimePoint;
        filename = document.numeric.path.result + buffer.endTime;
        console.log('trying to write to filename: ' + filename);
        FS.writeDataToFile(filename, buffer, true).then((function(_this) {
          return function(hash) {
            var activitySummaryInfo;
            activitySummaryInfo = {
              activityName: buffer.activityName,
              timestamp: buffer.endTime,
              totalTime: buffer.endTime - buffer.startTime,
              numberCorrect: buffer.runningTotals.correct,
              numberWrong: buffer.runningTotals.wrong,
              hash: hash
            };
            _this._addToAllSummaries(activitySummaryInfo);
            _this.currentActivityPersister.save({});
            _this.newFirst = 0;
            return deferred.resolve(buffer.endTime);
          };
        })(this))["catch"](function(status) {
          return deferred.reject(status);
        });
        return deferred.promise;
      };

      ActivitySummary.prototype.getPrevStar = function() {
        var buffer;
        return buffer = this.currentActivityPersister.read().responses.slice(-1)[0][5][0];
      };

      ActivitySummary.prototype.togglePrevStar = function() {
        var buffer, last;
        buffer = this.currentActivityPersister.read();
        last = buffer.responses.pop();
        last[5][0] = !last[5][0];
        buffer.responses.push(last);
        return this.currentActivityPersister.save(buffer);
      };

      ActivitySummary.prototype.getPrevNote = function() {
        return this.currentActivityPersister.read().responses.slice(-1)[0][5][1];
      };

      ActivitySummary.prototype.setPrevNote = function(note) {
        var buffer, last;
        buffer = this.currentActivityPersister.read();
        last = buffer.responses.pop();
        last[5][1] = note;
        buffer.responses.push(last);
        return this.currentActivityPersister.save(buffer);
      };

      return ActivitySummary;

    })();
    return new ActivitySummary();
  }
]);

angular.module('ActivityLib').factory("Channels", [
  '$q', '$location', 'Settings', 'ServerHttp', 'PersistenceManager', function($q, $location, Settings, ServerHttp, PersistenceManager) {
    var Channels;
    Channels = (function() {
      Channels.prototype.current = {};

      Channels.prototype.newFirst = 0;

      function Channels() {
        var init;
        this.persister = PersistenceManager.localStoreBlockingDictionaryPersister(document.numeric.key.channelActivities);
        init = this.persister.init();
      }

      Channels.prototype._uriActivities = function() {
        return Settings.get('mainServerAddress') + document.numeric.path.list;
      };

      Channels.prototype._uriChannels = function() {
        return Settings.get('mainServerAddress') + document.numeric.path.channels;
      };

      Channels.prototype.getChannelActivities = function(start, size, searchTerm) {
        var deferred, st;
        deferred = $q.defer();
        st = "";
        if (searchTerm !== void 0) {
          st = "&q=" + searchTerm.trim();
        }
        ServerHttp.get(this._uriActivities() + "?channelId=" + this.current.id + "&st=" + start + "&si=" + size + st).then((function(_this) {
          return function(response) {
            _this.persister.set(_this.makeKey(_this.current.id, start, size, searchTerm), response.data.activities);
            return deferred.resolve(response);
          };
        })(this))["catch"]((function(_this) {
          return function(status) {
            return deferred.reject(status);
          };
        })(this));
        return deferred.promise;
      };

      Channels.prototype.getChannels = function(start, size, searchTerm) {
        var st;
        st = "";
        if (searchTerm !== void 0) {
          st = "&q=" + searchTerm.trim();
        }
        return ServerHttp.get(this._uriChannels() + "?st=" + start + "&si=" + size + st);
      };

      Channels.prototype.makeKey = function(channelId, start, size, searchTerm) {
        if (searchTerm !== void 0) {
          searchTerm = searchTerm.trim();
        } else {
          searchTerm = '';
        }
        return '' + channelId + ':' + start + ':' + size + ':' + searchTerm;
      };

      Channels.prototype.getChannelActivitiesFromCache = function(start, size, searchTerm) {
        var activities, cachedVersion;
        cachedVersion = {};
        activities = this.persister.get(this.makeKey(this.current.id, start, size, searchTerm));
        if (activities !== void 0 || activities !== null) {
          cachedVersion.activities = activities;
        }
        return cachedVersion;
      };

      Channels.prototype.setCurrentChannel = function(id, name, back) {
        this.current.id = id;
        this.current.name = name;
        if (back === void 0) {
          back = '#/';
        }
        this.current.back = back;
        return this.newFirst = 0;
      };

      Channels.prototype.navigateToChannel = function(id, name, back) {
        this.setCurrentChannel(id, name, back);
        return $location.path('/channel');
      };

      return Channels;

    })();
    return new Channels();
  }
]);

angular.module('ActivityLib').factory("Pagination", [
  '$location', 'Settings', 'ServerHttp', function($location, Settings, ServerHttp) {
    var Pagination;
    Pagination = (function() {
      function Pagination() {}

      Pagination.prototype.init = function(scope, tryAgain, startIndex, varLittleHistory, varStartIndex, varEndIndex, varTurnPage) {
        return scope[varLittleHistory] = true;
      };

      return Pagination;

    })();
    return new Pagination();
  }
]);

angular.module('ActivityLib').factory("StarPracticeApi", [
  'DataPack', 'DataUtilities', 'RandomFunctions', 'TextFunctions', 'MathFunctions', 'HyperTextManager', 'GraphicsManager', function(DataPack, DataUtilities, RandomFunctions, TextFunctions, MathFunctions, HyperTextManager, GraphicsManager) {
    var StarPracticeApi, starPracticeApi;
    StarPracticeApi = (function() {
      function StarPracticeApi() {
        this.DataPack = DataPack;
        this.DataUtilities = DataUtilities;
        this.RandomFunctions = RandomFunctions;
        this.TextFunctions = TextFunctions;
        this.MathFunctions = MathFunctions;
        this.HyperTextManager = HyperTextManager;
        this.GraphicsManager = GraphicsManager;
      }

      return StarPracticeApi;

    })();
    starPracticeApi = new StarPracticeApi();
    document.numeric.modules.StarPracticeApi = starPracticeApi;
    return starPracticeApi;
  }
]);

angular.module('ActivityLib').factory("Tags", [
  '$location', 'Settings', 'ServerHttp', function($location, Settings, ServerHttp) {
    var Tags;
    Tags = (function() {
      function Tags() {}

      Tags.prototype.hasTags = function() {
        return false;
      };

      Tags.prototype.navigateToTags = function() {
        return $location.path('/tags');
      };

      return Tags;

    })();
    return new Tags();
  }
]);


var e, _initGlobal;

_initGlobal = function(d) {
  var n;
  if (d.numeric === void 0) {
    d.numeric = {};
  }
  n = d.numeric;
  n.appGroup = 'com.sparkydots.apps';
  n.appName = 'AppOne';
  n.appVersion = 1;
  n.modules = {};
  n.numericTasks = {};
  if (n.key === void 0) {
    n.key = {};
  }
  n.key.settings = 'numericAppOneSettings';
  n.key.deviceId = 'numericAppOneDeviceId';
  n.key.currentActivitySummary = 'numericAppOneCurrentActivitySummary';
  n.key.storedActivitySummaries = 'numericAppOneStoredActivitySummaries';
  n.key.messages = 'numericAppOneMessages';
  n.key.channelActivities = 'numericAppOneChannelActivitiesCache';
  if (n.url === void 0) {
    n.url = {};
  }
  if (n.url.base === void 0) {
    n.url.base = {};
  }
  n.url.base.numeric = 'numericdata/';
  n.url.base.fs = 'numericdata/AppOne/';
  n.url.base.cdv = 'cdvfile://localhost/persistent/';
  n.url.base.chrome = 'filesystem:SERVERNAME/temporary/';
  n.url.base.server = 'https://www.sparkydots.com/activityServer/data/';
  if (n.path === void 0) {
    n.path = {};
  }
  n.path.touch = 'touch';
  n.path.channels = 'channels';
  n.path.list = 'activity/list';
  n.path.activity = 'activity/';
  n.path.body = 'activity/body/';
  n.path.result = 'result/';
  if (n.defaultSettings === void 0) {
    n.defaultSettings = {};
  }
  n.defaultSettings.defaultChannel = 'public.1000';
  n.defaultSettings.stringTitle = 'AppOne';
  n.defaultSettings.showTabPractice = true;
  n.defaultSettings.stringPractice = 'Practice';
  n.defaultSettings.showTabHistory = true;
  n.defaultSettings.stringHistory = 'History';
  n.defaultSettings.stringActivities = 'Activities';
  n.defaultSettings.stringHistoryItem = 'Task Summary';
  n.defaultSettings.showSettings = false;
  n.defaultSettings.showSubmitLink = false;
  n.defaultSettings.pageSize = 10;
  n.defaultSettings.historyServerSync = false;
  return n.defaultSettings.mainServerAddress = 'https://www.sparkydots.com/activityServer/data/';
};

_initGlobal(document);

try {
  (function(w) {
    var port, protocol, server, servername;
    protocol = location.protocol;
    server = location.hostname;
    port = location.port;
    if (port.length > 0) {
      port = ":" + port;
    }
    servername = protocol + "//" + server + port;
    w.document.numeric.url.base.chrome = w.document.numeric.url.base.chrome.replace("SERVERNAME", servername);
    if (server === 'localhost' && port === ':9000') {
      w.document.numeric.url.base.chrome = "filesystem:http://localhost:9000/temporary/";
      w.document.numeric.defaultSettings.mainServerAddress = "http://localhost:9000/activityServer/data/";
      return w.document.numeric.defaultSettings.showSettings = true;
    }
  })(this);
} catch (_error) {
  e = _error;
  console.log(e);
}
