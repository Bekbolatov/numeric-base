// Class containing image data
function image(w, h) {
  this.header = '';
  this.data = Array();
  this.width = w;
  this.height = h;
}

// Convert a value to a little endian hexadecimal value
function getLittleEndianHex(value) {
  var result = [];

  for (var bytes = 4; bytes > 0; bytes--) {
    result.push(String.fromCharCode(value & 255));
    value >>= 8;
  }

  return result.join('');
}

// Set the required bitmap header
// Set the required bitmap header
function setImageHeader(img)
{
  var numFileBytes = getLittleEndianHex(img.width * img.height);
  var w = getLittleEndianHex(img.width);
  var h = getLittleEndianHex(img.height);

  img.header =
    'BM' +                    // Signature
    numFileBytes +            // size of the file (bytes)*
    '\x00\x00' +              // reserved
    '\x00\x00' +              // reserved
    '\x36\x00\x00\x00' +      // offset of where BMP data lives (54 bytes)
    '\x28\x00\x00\x00' +      // number of remaining bytes in header from here (40 bytes)
    w +                       // the width of the bitmap in pixels*
    h +                       // the height of the bitmap in pixels*
    '\x01\x00' +              // the number of color planes (1)
    '\x20\x00' +              // 32 bits / pixel
    '\x00\x00\x00\x00' +      // No compression (0)
    '\x00\x00\x00\x00' +      // size of the BMP data (bytes)*
    '\x13\x0B\x00\x00' +      // 2835 pixels/meter - horizontal resolution
    '\x13\x0B\x00\x00' +      // 2835 pixels/meter - the vertical resolution
    '\x00\x00\x00\x00' +      // Number of colors in the palette (keep 0 for 32-bit)
    '\x00\x00\x00\x00';       // 0 important colors (means all colors are important)
}

// Fill a rectangle
function fillRectangle(img, x, y, w, h, color) {
  for (var ny = y; ny < y + h; ny++) {
    for (var nx = x; nx < x + w; nx++) {
      img.data[ny * img.width + nx] = color;
    }
  }
}


// Flip image vertically
function flipImage(img) {
  var newImgData = new Array();

  for(var x = 0; x < img.width; x++) {
    for(var y = 0; y < img.height; y ++) {
      var ny = img.height - 1 - y;
      newImgData[(ny * img.width) + x] = img.data[(y * img.width) + x];
    }
  }

  img.data = newImgData;
}


// Main draw function
function drawImage() {
  var img = new image(210, 210);

  setImageHeader(img);

  fillRectangle(img, 0, 0, img.width, img.height, String.fromCharCode(255, 255, 255, 0));

  fillRectangle(img, 10, 10, 90, 90, String.fromCharCode(255, 0, 0, 0)); // Blue
  fillRectangle(img, 110, 10, 90, 90, String.fromCharCode(0, 255, 0, 0)); // Green
  fillRectangle(img, 10, 110, 90, 90, String.fromCharCode(0, 0, 255, 0)); // Red

  // Flip image vertically
  flipImage(img);

  // If window.btoa is supported, use it since it's often faster
  if(window.btoa != undefined) {
    return 'data:image/bmp;base64,' + btoa(img.header + img.data.join(""));
  }
  // If not, use our base64 library
  else {
    return 'data:image/bmp;base64,' + $.base64.encode(img.header + img.data.join(""));
  }
}

console.log('asd')
