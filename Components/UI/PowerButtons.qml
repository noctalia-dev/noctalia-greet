import QtQuick
import qs.Commons

Row {
  id: root

  spacing: 20

  Rectangle {
    width: 60
    height: 60
    radius: width * 0.5
    color: powerButtonArea.containsMouse ? Colors.mError : Colors.applyOpacity(Colors.mError, "33")
    border.color: Colors.mError
    border.width: 2

    Text {
      anchors.centerIn: parent
      text: "⏻"
      font.pointSize: 24
      color: powerButtonArea.containsMouse ? Colors.mOnSurface : Colors.mError
    }

    MouseArea {
      id: powerButtonArea
      anchors.fill: parent
      hoverEnabled: true
      onClicked: {
        console.log("Power off clicked")
      }
    }
  }

  Rectangle {
    width: 60
    height: 60
    radius: width * 0.5
    color: restartButtonArea.containsMouse ? Colors.mPrimary : Colors.applyOpacity(Colors.mPrimary, "33")
    border.color: Colors.mPrimary
    border.width: 2

    Text {
      anchors.centerIn: parent
      text: "↻"
      font.pointSize: 24
      color: restartButtonArea.containsMouse ? Colors.mOnSurface : Colors.mPrimary
    }

    MouseArea {
      id: restartButtonArea
      anchors.fill: parent
      hoverEnabled: true
      onClicked: {
        console.log("Reboot clicked")
      }
    }
  }

  Rectangle {
    width: 60
    height: 60
    radius: width * 0.5
    color: suspendButtonArea.containsMouse ? Colors.mSecondary : Colors.applyOpacity(Colors.mSecondary, "33")
    border.color: Colors.mSecondary
    border.width: 2

    Text {
      anchors.centerIn: parent
      text: "💤"
      font.pointSize: 20
      color: suspendButtonArea.containsMouse ? Colors.mOnSurface : Colors.mSecondary
    }

    MouseArea {
      id: suspendButtonArea
      anchors.fill: parent
      hoverEnabled: true
      onClicked: {
        console.log("Suspend clicked")
      }
    }
  }
}
