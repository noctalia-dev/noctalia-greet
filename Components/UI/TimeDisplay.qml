import QtQuick
import qs.Commons

Column {
  id: root

  spacing: 10

  Text {
    id: timeText
    text: Qt.formatDateTime(new Date(), "HH:mm")
    font.family: "DejaVu Sans"
    font.pointSize: 72
    font.weight: Font.Bold
    color: Colors.mOnSurface
    horizontalAlignment: Text.AlignHCenter

    SequentialAnimation on scale {
      loops: Animation.Infinite
      NumberAnimation {
        to: 1.02
        duration: 2000
        easing.type: Easing.InOutQuad
      }
      NumberAnimation {
        to: 1.0
        duration: 2000
        easing.type: Easing.InOutQuad
      }
    }
  }

  Text {
    id: dateText
    text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
    font.family: "DejaVu Sans"
    font.pointSize: 24
    font.weight: Font.Light
    color: Colors.mOnSurface
    horizontalAlignment: Text.AlignHCenter
    width: timeText.width
  }

  // Timer to update time
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      if (typeof timeText !== 'undefined' && timeText) {
        timeText.text = Qt.formatDateTime(new Date(), "HH:mm")
      }
      if (typeof dateText !== 'undefined' && dateText) {
        dateText.text = Qt.formatDateTime(new Date(), "dddd, MMMM d")
      }
    }
  }
}
