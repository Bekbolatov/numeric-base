angular.module('ModulePersistence')

.factory("QRSignature", [ () ->
    class QRSignature
        encode: (input, dotsize) ->

            padding = 10
            black = "rgb(0,0,0)"
            white = "rgb(255,255,255)"
            QRCodeVersion = 4; # 1-40 4-> 288 bit (36 bytes/chars) - we are using MD5 as public, which is 32 chars /http://www.denso-wave.com/qrcode/qrgene2-e.html

            canvas = document.createElement('canvas')
            qrCanvasContext = canvas.getContext('2d')

            try
                qr = new QRCode(QRCodeVersion, QRErrorCorrectLevel.L)
                qr.addData(input)
                qr.make()
            catch err
                errorChild = document.createElement("p")
                errorMSG = document.createTextNode("QR Code generation failed: " + err)
                errorChild.appendChild(errorMSG)
                return errorChild


            qrsize = qr.getModuleCount()
            canvas.setAttribute('height', (qrsize * dotsize) + padding)
            canvas.setAttribute('width', (qrsize * dotsize) + padding)
            shiftForPadding = padding / 2
            if canvas.getContext
                for r in [0..(qrsize - 1)]
                    for c in [0..(qrsize - 1)]
                        if qr.isDark(r, c)
                            qrCanvasContext.fillStyle = black
                        else
                            qrCanvasContext.fillStyle = white
                        qrCanvasContext.fillRect(
                            c * dotsize + shiftForPadding
                            r * dotsize + shiftForPadding
                            dotsize
                            dotsize)

            imgElement = document.createElement("img")
            imgElement.src = canvas.toDataURL("image/png")
            imgElement

    new QRSignature()
])