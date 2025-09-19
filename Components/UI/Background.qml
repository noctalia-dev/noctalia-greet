import QtQuick
import QtQuick.Effects
import qs.Commons

Rectangle {
  id: root

  // Properties to be set by parent
  property string wallpaperPath: ""
  property string noctaliaWallpaper: ""

  anchors.fill: parent
  color: Colors.mSurface

  // Wallpaper - prioritize noctalia config, fallback to environment variable
  Image {
    anchors.fill: parent
    source: root.noctaliaWallpaper || root.wallpaperPath
    fillMode: Image.PreserveAspectCrop
    visible: (root.noctaliaWallpaper || root.wallpaperPath) !== ""

    onStatusChanged: {
      if (status === Image.Error) {
        console.log("[ERROR] Failed to load wallpaper:", source)
      } else if (status === Image.Ready) {
        console.log("[INFO] Successfully loaded wallpaper:", source)
      }
    }
  }

  // Gradient overlay similar to your lockscreen
  Rectangle {
    anchors.fill: parent
    gradient: Gradient {
      GradientStop {
        color: Qt.rgba(0, 0, 0, 0.6)
        position: 0.0
      }
      GradientStop {
        color: Qt.rgba(0, 0, 0, 0.3)
        position: 0.3
      }
      GradientStop {
        color: Qt.rgba(0, 0, 0, 0.4)
        position: 0.7
      }
      GradientStop {
        color: Qt.rgba(0, 0, 0, 0.7)
        position: 1.0
      }
    }
  }

  // Animated particles like your lockscreen
  Repeater {
    model: 20
    Rectangle {
      width: Math.random() * 4 + 2
      height: width
      radius: width * 0.5
      color: Colors.applyOpacity(Colors.mPrimary, "4D")
      x: Math.random() * parent.width
      y: Math.random() * parent.height

      SequentialAnimation on opacity {
        loops: Animation.Infinite
        NumberAnimation {
          to: 0.8
          duration: 2000 + Math.random() * 3000
        }
        NumberAnimation {
          to: 0.1
          duration: 2000 + Math.random() * 3000
        }
      }
    }
  }
}
