pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io


/*
  Minimal Colors singleton that reads Commons/noctalia.json and exposes
  Material-3-like color names prefixed with m*.
*/
Singleton {
  id: root

  // Which theme to use from the JSON: "dark" or "light"
  property string theme: "dark"

  // User config directory (~/.config/noctalia/ by default)
  readonly property string noctaliaConfigDir: Quickshell.env("NOCTALIA_CONFIG_DIR")
                                              || (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env(
                                                    "HOME") + "/.config") + "/noctalia/"
  readonly property string userColorsPath: noctaliaConfigDir + "colors.json"

  // Preferred flat palette loader (Commons/colors.json)
  FileView {
    id: simplePaletteFile
    path: root.userColorsPath
    watchChanges: true
    onFileChanged: reload()
    Component.onCompleted: reload()

    JsonAdapter {
      id: simplePalette
      // Flat keys palette
      property string mPrimary
      property string mOnPrimary
      property string mSecondary
      property string mOnSecondary
      property string mTertiary
      property string mOnTertiary
      property string mError
      property string mOnError
      property string mSurface
      property string mOnSurface
      property string mSurfaceVariant
      property string mOnSurfaceVariant
      property string mOutline
      property string mShadow
    }
  }

  // File loader for the palette
  FileView {
    id: paletteFile
    path: Qt.resolvedUrl("./noctalia.json")
    watchChanges: true
    onFileChanged: reload()
    Component.onCompleted: reload()

    JsonAdapter {
      id: palette
      // Mirror top-level JSON keys without defaults
      property var dark
      property var light
    }
  }

  // Active palette: prefer flat colors.json if present and valid, else themed noctalia.json
  readonly property bool hasSimplePalette: simplePalette && simplePalette.mPrimary !== undefined
                                           && simplePalette.mPrimary !== null
  readonly property var colors: hasSimplePalette ? simplePalette : (theme === "light" ? palette.light : palette.dark)

  // Expose top-level color properties
  property color mPrimary: colors.mPrimary
  property color mOnPrimary: colors.mOnPrimary
  property color mSecondary: colors.mSecondary
  property color mOnSecondary: colors.mOnSecondary
  property color mTertiary: colors.mTertiary
  property color mOnTertiary: colors.mOnTertiary
  property color mError: colors.mError
  property color mOnError: colors.mOnError
  property color mSurface: colors.mSurface
  property color mOnSurface: colors.mOnSurface
  property color mSurfaceVariant: colors.mSurfaceVariant
  property color mOnSurfaceVariant: colors.mOnSurfaceVariant
  property color mOutline: colors.mOutline
  property color mShadow: colors.mShadow

  // Helpers
  property color transparent: "transparent"
  function applyOpacity(color, opacity) {
    if (!color)
      return "transparent"
    return color.toString().replace("#", "#" + opacity)
  }
}
