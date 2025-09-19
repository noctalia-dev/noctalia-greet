import QtQuick
import qs.Commons

Rectangle {
  id: root

  // Properties to be set by parent
  property string currentUser: ""
  property bool unlocking: false

  signal userClicked

  onCurrentUserChanged: {
    console.log("[UserAvatar] Current user changed to:", currentUser)
  }

  width: 108
  height: 108
  radius: width * 0.5
  color: "transparent"
  border.color: Colors.mPrimary
  border.width: 2
  z: 10

  Rectangle {
    anchors.centerIn: parent
    width: parent.width + 24
    height: parent.height + 24
    radius: width * 0.5
    color: "transparent"
    border.color: Colors.applyOpacity(Colors.mPrimary, "4D")
    border.width: 1
    z: -1
    visible: !root.unlocking

    SequentialAnimation on scale {
      loops: Animation.Infinite
      NumberAnimation {
        to: 1.1
        duration: 1500
        easing.type: Easing.InOutQuad
      }
      NumberAnimation {
        to: 1.0
        duration: 1500
        easing.type: Easing.InOutQuad
      }
    }
  }

  // User avatar - use noctalia avatar with circular shader, fallback to initial
  Rectangle {
    anchors.centerIn: parent
    width: 100
    height: 100
    radius: width * 0.5
    color: Colors.mPrimary

    // Raw image used as texture source for the shader
    Image {
      id: avatarImage
      anchors.fill: parent
      source: Settings.noctaliaAvatarImage
      fillMode: Image.PreserveAspectCrop
      smooth: true
      visible: false

      onStatusChanged: {
        if (status === Image.Error && Settings.noctaliaAvatarImage) {
          console.log("[WARN] Failed to load avatar image:", Settings.noctaliaAvatarImage)
        } else if (status === Image.Ready) {
          console.log("[INFO] Successfully loaded avatar image:", Settings.noctaliaAvatarImage)
        }
      }
    }

    // Circular mask shader effect
    ShaderEffect {
      anchors.fill: parent
      visible: avatarImage.status === Image.Ready
      property var source: avatarImage
      property real imageOpacity: 1.0
      fragmentShader: Qt.resolvedUrl("../../Shaders/qsb/circled_image.frag.qsb")
    }

    // Fallback to initial letter if no avatar image
    Text {
      anchors.centerIn: parent
      text: root.currentUser.charAt(0).toUpperCase()
      font.pointSize: 36
      font.bold: true
      color: Colors.mOnSurface
      visible: avatarImage.status !== Image.Ready
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: parent.scale = 1.05
    onExited: parent.scale = 1.0
    onClicked: root.userClicked()

    Behavior on scale {
      NumberAnimation {
        duration: 200
        easing.type: Easing.OutBack
      }
    }
  }
}
