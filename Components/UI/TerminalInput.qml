import QtQuick
import QtQuick.Layouts
import qs.Commons

Rectangle {
  id: root

  // Properties to be set by parent
  property string currentUser: ""
  property string passwordBuffer: ""
  property bool unlocking: false

  signal passwordChanged(string password)
  signal authenticateRequested

  onCurrentUserChanged: {
    console.log("[TerminalInput] Current user changed to:", currentUser)
  }

  width: 720
  height: 280
  radius: 20
  color: Colors.applyOpacity(Colors.mSurface, "E6")
  border.color: Colors.mPrimary
  border.width: 2

  // Terminal scanlines effect
  Repeater {
    model: 20
    Rectangle {
      width: parent.width
      height: 1
      color: Colors.applyOpacity(Colors.mPrimary, "1A")
      y: index * 10
      opacity: 0.3
      SequentialAnimation on opacity {
        loops: Animation.Infinite
        NumberAnimation {
          to: 0.6
          duration: 2000 + Math.random() * 1000
        }
        NumberAnimation {
          to: 0.1
          duration: 2000 + Math.random() * 1000
        }
      }
    }
  }

  // Terminal header
  Rectangle {
    width: parent.width
    height: 40
    color: Colors.applyOpacity(Colors.mPrimary, "33")
    topLeftRadius: 18
    topRightRadius: 18

    RowLayout {
      anchors.fill: parent
      anchors.margins: 10
      spacing: 10

      Text {
        text: "SECURE TERMINAL"
        color: Colors.mOnSurface
        font.family: "DejaVu Sans Mono"
        font.pointSize: 14
        font.weight: Font.Bold
        Layout.fillWidth: true
      }

      Text {
        text: "USER: " + root.currentUser
        color: Colors.mOnSurface
        font.family: "DejaVu Sans Mono"
        font.pointSize: 12
      }
    }
  }

  // Terminal content
  ColumnLayout {
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 20
    anchors.topMargin: 55
    spacing: 15

    RowLayout {
      Layout.fillWidth: true
      spacing: 10

      Text {
        text: root.currentUser + "@noctalia:~$"
        color: Colors.mPrimary
        font.family: "DejaVu Sans Mono"
        font.pointSize: 16
        font.weight: Font.Bold
      }

      Text {
        text: "sudo start-session"
        color: Colors.mOnSurface
        font.family: "DejaVu Sans Mono"
        font.pointSize: 16
      }

      // Visible password input (terminal style)
      TextInput {
        id: terminalPassword
        color: Colors.mOnSurface
        font.family: "DejaVu Sans Mono"
        font.pointSize: 16
        echoMode: TextInput.Password
        passwordCharacter: "*"
        passwordMaskDelay: 0
        focus: true
        text: root.passwordBuffer
        // Size to content for terminal look
        width: Math.max(1, contentWidth)
        selectByMouse: false

        Component.onCompleted: terminalPassword.forceActiveFocus()

        onTextChanged: {
          root.passwordBuffer = text
          root.passwordChanged(text)
        }

        Keys.onPressed: kevent => {
                          if (kevent.key === Qt.Key_Enter || kevent.key === Qt.Key_Return) {
                            root.authenticateRequested()
                            kevent.accepted = true
                          } else if (kevent.key === Qt.Key_Escape) {
                            root.passwordBuffer = ""
                            terminalPassword.text = ""
                            root.passwordChanged("")
                            kevent.accepted = true
                          }
                        }
      }
    }

    Text {
      text: root.unlocking ? "Authenticating..." : ""
      color: root.unlocking ? Colors.mPrimary : "transparent"
      font.family: "DejaVu Sans Mono"
      font.pointSize: 16
      Layout.fillWidth: true

      SequentialAnimation on opacity {
        running: root.unlocking
        loops: Animation.Infinite
        NumberAnimation {
          to: 1.0
          duration: 800
        }
        NumberAnimation {
          to: 0.5
          duration: 800
        }
      }
    }

    // Execute button
    Rectangle {
      width: 120
      height: 40
      radius: 10
      color: executeButtonArea.containsMouse ? Colors.mPrimary : Colors.applyOpacity(Colors.mPrimary, "33")
      border.color: Colors.mPrimary
      border.width: 1
      enabled: !root.unlocking
      Layout.alignment: Qt.AlignRight
      Layout.bottomMargin: -10

      Text {
        anchors.centerIn: parent
        text: root.unlocking ? "EXECUTING" : "EXECUTE"
        color: executeButtonArea.containsMouse ? Colors.mOnSurface : Colors.mPrimary
        font.family: "DejaVu Sans Mono"
        font.pointSize: 14
        font.weight: Font.Bold
      }

      MouseArea {
        id: executeButtonArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.authenticateRequested()

        SequentialAnimation on scale {
          running: executeButtonArea.containsMouse
          NumberAnimation {
            to: 1.05
            duration: 200
            easing.type: Easing.OutCubic
          }
        }

        SequentialAnimation on scale {
          running: !executeButtonArea.containsMouse
          NumberAnimation {
            to: 1.0
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
      }

      SequentialAnimation on scale {
        loops: Animation.Infinite
        running: root.unlocking
        NumberAnimation {
          to: 1.02
          duration: 600
          easing.type: Easing.InOutQuad
        }
        NumberAnimation {
          to: 1.0
          duration: 600
          easing.type: Easing.InOutQuad
        }
      }
    }
  }

  // Terminal border glow
  Rectangle {
    anchors.fill: parent
    radius: parent.radius
    color: "transparent"
    border.color: Colors.applyOpacity(Colors.mPrimary, "4D")
    border.width: 1
    z: -1

    SequentialAnimation on opacity {
      loops: Animation.Infinite
      NumberAnimation {
        to: 0.6
        duration: 2000
        easing.type: Easing.InOutQuad
      }
      NumberAnimation {
        to: 0.2
        duration: 2000
        easing.type: Easing.InOutQuad
      }
    }
  }
}
