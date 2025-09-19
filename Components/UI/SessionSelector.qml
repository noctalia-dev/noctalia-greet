import QtQuick
import qs.Commons

Rectangle {
  id: root

  // Properties to be set by parent
  property string currentSessionName: ""

  signal sessionClicked

  height: 40
  radius: 20
  color: "transparent"
  border.color: Colors.mPrimary
  border.width: 1

  // Make width depend on text length
  width: Math.max(180, sessionNameText.paintedWidth + 40)

  Text {
    id: sessionNameText
    anchors.centerIn: parent
    text: root.currentSessionName.replace(/\(|\)/g, "")
    color: Colors.mOnSurface
    font.pointSize: 16
    font.bold: true
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.sessionClicked()
  }
}
