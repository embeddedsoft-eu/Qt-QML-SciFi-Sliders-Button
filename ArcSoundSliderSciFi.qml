import QtQuick 2.12

Item {
    id: root

    // ===== API =====
    property real value: 0.5          // 0..1
    property real radius: 120
    property int ticks: 5

    // orientation: "top" or "bottom"
    property string direction: "top"

    property color trackColor: "#1C2A35"
    property color activeColor: "#00E5FF"
    property color tickColor: "#355463"
    property color activeTickColor: "#FFFFFF"
    property color textColor: "#7FBFD0"
    property bool hovered: false

    property string name: "default"
    property bool active: false

    signal valueChangedByUser(int v)
    property bool _userChanging: false

    width: radius * 2.2
    height: radius + 20

    // ===== Angles =====
    readonly property real startAngle:
        direction === "top" ? Math.PI*1.05 : Math.PI*0.05
    readonly property real endAngle:
        direction === "top" ? Math.PI*1.95 : Math.PI*0.95

    readonly property real currentAngle:
        startAngle + (endAngle - startAngle) * value

    // center of Curve
    readonly property real centerX: width / 2
    readonly property real centerY: direction === "top" ? height : 0

    // ===== Canvas =====
    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var cx = centerX
            var cy = centerY
            var r = root.radius

            var coef = 2;

            // base arc
            ctx.lineWidth = hovered ? 8*3*coef : 6*3*coef
            ctx.strokeStyle = root.trackColor
            ctx.beginPath()
            ctx.arc(cx, cy, r, startAngle, endAngle)
            ctx.stroke()

            // active arc
            ctx.lineWidth = hovered ? 10*1.1*coef : 8*1.1*coef
            ctx.strokeStyle = hovered
                ? Qt.lighter(root.activeColor, 1.4)
                : root.activeColor

            ctx.beginPath()
            ctx.arc(cx, cy, r, startAngle, currentAngle)
            ctx.stroke()

            // ticks
            var ticks = 20
            ctx.strokeStyle = "#FFFFFF"
            for (var i = 0; i < ticks; i++) {
                var t = i / (ticks - 1)
                var a = startAngle + (endAngle - startAngle) * t

                var inner = r - 10
                var outer = r + (i % 5 === 0 ? 8 : 4)

                ctx.strokeStyle = t <= value
                                  ? root.activeTickColor
                                  : root.tickColor
                ctx.lineWidth = 2

                ctx.beginPath()
                ctx.moveTo(cx + inner * Math.cos(a),
                           cy + inner * Math.sin(a))
                ctx.lineTo(cx + outer * Math.cos(a),
                           cy + outer * Math.sin(a))
                ctx.stroke()
            }

            // handle
            var hx = cx + r * Math.cos(currentAngle)
            var hy = cy + r * Math.sin(currentAngle)

            var inner2 = r - 12
            var outer2 = r + 12
            var a2 = currentAngle

            ctx.strokeStyle = root.activeTickColor
            ctx.lineWidth = 10

            ctx.beginPath()
            ctx.moveTo(cx + inner2 * Math.cos(a2),
                       cy + inner2 * Math.sin(a2))
            ctx.lineTo(cx + outer2 * Math.cos(a2),
                       cy + outer2 * Math.sin(a2))

            ctx.stroke()

            // inside rect
            var inner3 = r - 9
            var outer3 = r + 9

            ctx.strokeStyle = "#000000"
            ctx.lineWidth = 5

            ctx.beginPath()
            ctx.moveTo(cx + inner3 * Math.cos(a2),
                       cy + inner3 * Math.sin(a2))
            ctx.lineTo(cx + outer3 * Math.cos(a2),
                       cy + outer3 * Math.sin(a2))

            ctx.stroke()
        }
    }

    // MouseArea only on curve
    MouseArea {
        id: sliderArea

        // Catch only on curve region
        x: centerX - radius - 20
        y: direction === "top" ? centerY - radius - 20 : centerY - 20
        width: (radius + 40) * 2
        height: radius + 40

        hoverEnabled: true

        // prevent stealing events from underlying items
        preventStealing: true

        // Check if cursor on curve
        function isPointOnArc(x, y) {
            var dx = x - (centerX - sliderArea.x)
            var dy = y - (centerY - sliderArea.y)
            var distance = Math.sqrt(dx*dx + dy*dy)

            // Check if point is on curve ± tolerance
            var tolerance = 30
            return Math.abs(distance - radius) <= tolerance
        }

        //  mouse position changed (hover and drag)
        onPositionChanged: {
            // cursor update
            if (isPointOnArc(mouse.x, mouse.y)) {
                cursorShape = Qt.PointingHandCursor
            } else {
                cursorShape = Qt.ArrowCursor
            }

            // handle if pressed
            if (pressed && isPointOnArc(mouse.x, mouse.y)) {
                handleMouse(mouse.x + sliderArea.x, mouse.y + sliderArea.y)
            }
        }

        onExited: {
            cursorShape = Qt.ArrowCursor
        }

        // Catch mouse only if pressed
        onPressed: {
            if (isPointOnArc(mouse.x, mouse.y)) {
                mouse.accepted = true
                forceActiveFocus()
                handleMouse(mouse.x + sliderArea.x, mouse.y + sliderArea.y)
            } else {
                mouse.accepted = false
            }
        }

        onReleased: {
            // release focus
        }

        // Skip events if mouse click is not in region
        propagateComposedEvents: true
    }


    function handleMouse(mx, my) {
        var cx = centerX
        var cy = centerY

        var dx = mx - cx
        var dy = my - cy

        // Ignore if out of range
        var distance = Math.sqrt(dx*dx + dy*dy)
        if (Math.abs(distance - radius) > 25) {
            return
        }

        var angle = Math.atan2(dy, dx)

        // check direction
        if (direction === "top") {
            if (angle < 0)
                angle += 2 * Math.PI
        }

        var newValue


        if (direction === "top") {
            // check if value valid
            if (angle >= startAngle && angle <= endAngle) {
                newValue = (angle - startAngle) / (endAngle - startAngle)
            } else {
                // check for nearest point
                var distToStart = Math.abs(angle - startAngle)
                var distToEnd = Math.abs(angle - endAngle)
                var distToStartWrap = Math.abs((angle - 2*Math.PI) - startAngle)
                var distToEndWrap = Math.abs((angle + 2*Math.PI) - endAngle)

                var minDist = Math.min(distToStart, distToEnd, distToStartWrap, distToEndWrap)

                if (minDist === distToStart || minDist === distToStartWrap) {
                    newValue = 0
                } else {
                    newValue = 1
                }
            }
        } else {
            // for bottom
            if (angle >= startAngle && angle <= endAngle) {
                newValue = (angle - startAngle) / (endAngle - startAngle)
            } else {
                var distToStartBottom = Math.abs(angle - startAngle)
                var distToEndBottom = Math.abs(angle - endAngle)

                if (distToStartBottom < distToEndBottom) {
                    newValue = 0
                } else {
                    newValue = 1
                }
            }
        }

        // value limits
        newValue = Math.max(0, Math.min(1, newValue))

        // Update value is changed
        if (Math.abs(newValue - value) > 0.001) {
            _userChanging = true
            value = newValue
            valueChangedByUser(Math.round(value * 100))
            _userChanging = false
        }

        canvas.requestPaint()
    }

    onValueChanged: {
        if (!_userChanging) {
            canvas.requestPaint()
        }
    }
}
