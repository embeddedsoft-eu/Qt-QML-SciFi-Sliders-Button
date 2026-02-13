import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3

Window {
    width: 400
    height: 550
    visible: true
    title: qsTr("Hello SciFi")

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#3A5A66" }
            GradientStop { position: 1.1; color: "#0A1C22" }
        }
    }

    Rectangle {
        color: "transparent"
        border.color: "#0A1C22"
        border.width: 5
        width: parent.width
        height: width
        radius: width/2

        // Top sliders (direction: "top")
        Rectangle {
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            height: parent.height/2
            width: parent.width
            z: 1  // Lower z-order

            ArcSoundSliderSciFi {
                id: topSliderOuter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                radius: parent.width * 0.9/2
                direction: "top"
                z: 1  // Lower z-order
            }

            ArcSoundSliderSciFi {
                id: topSliderInner
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                radius: parent.width * 0.7/2
                direction: "top"
                z: 2  // Higher z-order, will be in the middle
            }

            ArcSoundSliderSciFi {
                id: topSliderInner2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                radius: parent.width * 0.5/2
                direction: "top"
                z: 2  // Higher z-order, will be on top
            }
        }

        // Bottom sliders (direction: "bottom")
        Rectangle {
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            height: parent.height/2
            width: parent.width
            z: 1  // Lower z-order

            ArcSoundSliderSciFi {
                id: bottomSliderOuter
                radius: parent.width * 0.9/2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                direction: "bottom"
                z: 1
            }

            ArcSoundSliderSciFi {
                id: bottomSliderInner
                radius: parent.width * 0.7/2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                direction: "bottom"
                z: 2  // Higher z-order, will be in the middle
            }

            ArcSoundSliderSciFi {
                id: bottomSliderInner2
                radius: parent.width * 0.5/2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                direction: "bottom"
                z: 3  // Higher z-order, will be on top
            }
        }

        SciFiToggleButton {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width*0.98
            z: 10  // Highest z-order
        }
    }

    // Add handler to prevent event propagation
    Item {
        anchors.fill: parent
        z: 100  // Very high z-order, but doesn't intercept events
        enabled: false  // Don't intercept events
    }
}
