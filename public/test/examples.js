// emit a target for a later example image
function embedimage(name, vspace) {
  if (typeof document.all != 'undefined') {		// IE 4+ version
	document.write('<div id="'+name+'" align="left">',
                   '<img width="32" height="32" alt="'+name+'" src="../images/pixel.gif">',
                   '</div>');
  } else {			// NN version
	document.write('<img align="left" width="32" height="32" vspace="', vspace,
                   '" alt="', name, '" name="', name, '" src="../images/pixel.gif">');
  }
}

// the target names and the functions which compute them
var imgdata = new Array(
                        'pnglet', '',
                        'point1', 'p.point(p.color(255,0,0), 16, 16)',
                        'point2', 'p.point(red,16,16,8,16,16,8)',
                        'line1', 'p.line(green, 2,2, 32,16)',
                        'line2', 'p.line(green, 2,2, 32,16, 16,32, 4,7)',
                        'poly1', 'p.polygon(blue, null, 16,8, 8,16, 24,16)',
                        'poly2', 'p.polygon(null, red, 16,8, 8,16, 24,16)',
                        'poly3', 'p.polygon(blue, red, 16,8, 8,16, 24,16)',
                        'rect1', 'p.rectangle(white, null, 2,2, 30,30)',
                        'rect2', 'p.rectangle(null, red, 2,2, 30,30)',
                        'rect3', 'p.rectangle(white, red, 2,2, 30,30)',
                        'arc1', 'p.arc(green, 16,16, 20,20, 0,270)',
                        'oval1', 'p.oval(green, null, 16,16, 20,20)',
                        'oval2', 'p.oval(null, blue, 16,16, 20,20)',
                        'oval3', 'p.oval(green, blue, 16,16, 20,20)',
                        'chord1', 'p.chord(green, null, 16,16, 20,20, 0,270)',
                        'chord2', 'p.chord(null, blue, 16,16, 20,20, 0,270)',
                        'chord3', 'p.chord(green, blue, 16,16, 20,20, 0,270)',
                        'pieslice1', 'p.pieslice(green, null, 16,16, 20,20, 0,270)',
                        'pieslice2', 'p.pieslice(null, blue, 16,16, 20,20, 0,270)',
                        'pieslice3', 'p.pieslice(green, blue, 16,16, 20,20, 0,270)',
                        'outlfill', 'p.oval(blue, null, 11,11, 10,10);'+
                        'p.oval(green, null, 16,16, 15,15);'+
			            'p.fill(green, blue, 16,16)',
                        'fillfill', 'p.oval(blue, null, 11,11, 10,10);'+
                        'p.oval(green, null, 16,16, 15,15);'+
			            'p.fill(null, blue, 16,16)',
                        'point3', 'p.smoothPoint(5, red,16,16,8,16,16,8)',
                        'line3', 'p.smoothLine(5, green, 2,2, 32,16, 16,32, 4,7)',
                        'poly4', 'p.smoothPolygon(5, blue, null, 16,8, 8,16, 24,16)',
                        'poly5', 'p.smoothPolygon(5, null, red, 16,8, 8,16, 24,16)',
                        'poly6', 'p.smoothPolygon(5, blue, red, 16,8, 8,16, 24,16)'
                        );

var pnglets = new Object();

//
// these could be respecified in the web page
// after examples.js is loaded.
// 'dataUrl' - writes a data:image/png;base64 into innerHTML
//	nn4.5 - illegal URL method "data:"
//	ie4 - broken image, no error
// 'javascriptUrl' - writes a javascript:pnglets[name] into innerHTML
//	nn4.5 - displays image
//	ie4 - broken image, no error
// 'showDataUrl' - inserts the dataUrl text into innerHTML
//	ie4 - base64 text with appropriate patterns
// 'document.write' - writes image/png into the <DIV> document
//	ie4 - invalid argument on open, or document disappears
// 'document.write.base64 - writes image/png;base64 into the <DIV> document
//
var nnMethod = 'javascriptUrl';
var ieMethod = 'javascriptUrl';

function loadimages(i) {
  function install(name, value) {
	var p = new Pnglet(32, 32, 8);
	var black = p.color(0,0,0,0),
      red = p.color(255,0,0),
      green = p.color(0,255,0),
      blue = p.color(0,0,255),
      white = p.color(255,255,255);
	eval(value);
	pnglets[name] = p.output();
	if (document.images[name]) {
      if (nnMethod == 'javascriptUrl')
		document.images[name].src = "javascript:pnglets."+name;
      if (nnMethod == 'dataUrl')
		document.images[name].src = dataUrl('image/png', pnglets[name]);
	} else if (ieMethod == 'dataUrl') {
      document.all[name].innerHTML = '<img'+
		' height="32"'+
		' width="32"'+
		' alt="'+name+'"'+
		' src="'+dataUrl('image/png', pnglets[name])+'"'+
		'>';
	} else if (ieMethod == 'javascriptUrl') {
      document.all[name].innerHTML = '<img'+
		' height="32"'+
		' width="32"'+
		' alt="'+name+'"'+
		' src="javascript:pnglets.'+name+'"'+
		'>';
	} else if (ieMethod == 'showDataUrl') {
      document.all[name].innerHTML = '<pre>'+dataUrl('image/png', pnglets[name])+'</pre>';
	} else if (ieMethod == 'document.write') {
      document.all[name].document.open('text/html');
      document.all[name].document.write(pnglets[name]);
      document.all[name].document.close();
	} else if (ieMethod == 'document.write.base64') {
      document.all[name].document.open('image/png;base64');
      document.all[name].document.write(base64(pnglets[name]));
      document.all[name].document.close();
	}
  }
    if (i+1 < imgdata.length) {
      install(imgdata[i], imgdata[i+1]);
      setTimeout("window.loadimages("+(i+2)+")", 10);
    }
}
