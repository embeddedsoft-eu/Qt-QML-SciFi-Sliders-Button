import QtQuick 2.12

Item {
    id: root
    height: width/4.5

    property bool checked: false
    property string textOn: "SYSTEM ON"
    property string textOff: "SYSTEM OFF"

    property color onColor: "#00F6FF"
    property color offColor: "#1C2A35"
    property color textColor: "#7FFBFF"
    property color ringOuterColor: "#6FB3C4"

    signal toggled(bool value)

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)

            circleCanvas.requestPaint()
        }
    }


    // ===== CIRCLE =====
    Item {
        id: circleWrap
        width: height
        height: parent.height
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter


        Canvas {
            id: circleCanvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var cx = width / 2 + 5
                var cy = height / 2
                var r = width * 0.30

                // outer ring (внешнее кольцо) - теперь используем отдельный цвет
                ctx.lineWidth = 3
                ctx.strokeStyle = root.ringOuterColor
                ctx.beginPath()
                ctx.arc(cx, cy, r*1.2, 0, Math.PI * 2)
                ctx.stroke()

                // inner ring (внутреннее кольцо) - основной цвет
                ctx.lineWidth = 4
                ctx.fillStyle = "#0B3C44"
                ctx.strokeStyle = root.onColor
                ctx.beginPath()
                ctx.arc(cx, cy, r, 0, Math.PI * 2)
                ctx.stroke()

                // inner glow
                ctx.fillStyle = !root.checked ? "#0B3C44" : "#0A1C22"
                ctx.beginPath()
                ctx.arc(cx, cy, r * 0.8, 0, Math.PI * 2)
                ctx.fill()
            }
        }
    }

    // ===== RIGHT PANEL =====
    Rectangle {
        id: panel
        anchors.left: circleWrap.left
        anchors.leftMargin: +4
        z:-1
        width: parent.width
        height: parent.height*0.6
        anchors.verticalCenter: parent.verticalCenter

        color: root.checked ? "#0B3C44" : "#0A1C22"
        border.color: root.checked ? root.onColor : "#355463"
        border.width: 1
        radius: parent.width/30

        Rectangle {
            // glow line
            height: 2
            width: parent.width * 0.9
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.checked ? root.onColor : "#355463"
            opacity: root.checked ? 1.0 : 0.3
        }

        Text {
            anchors.centerIn: parent
            text: root.checked ? root.textOn : root.textOff
            color: root.textColor
            font.pixelSize: 18
            font.family: "Arial"
        }
    }

    Behavior on checked {
        NumberAnimation { duration: 180 }
    }
}
