import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
  id: root

  // Properties to be set by parent
  property string noctaliaConfigDir: ""
  property string noctaliaSettingsFile: ""

  // Signals
  signal wallpaperUpdated(string wallpaperPath)

  // Internal properties
  property string noctaliaWallpaper: ""
  property string currentMonitorName: ""

  // Load noctalia settings to get wallpaper
  FileView {
    id: noctaliaSettingsLoader
    path: root.noctaliaSettingsFile
    watchChanges: true

    JsonAdapter {
      id: noctaliaSettings
      property JsonObject wallpaper: JsonObject {
        property bool enabled: true
        property string directory: ""
        property bool setWallpaperOnAllMonitors: true
        property list<var> monitors: []
      }
    }

    onLoaded: {
      console.log("[INFO] Loaded noctalia settings from:", root.noctaliaSettingsFile)
      updateWallpaperFromNoctaliaConfig()
    }

    onLoadFailed: function (error) {
      console.log("[WARN] Failed to load noctalia settings:", error)
      console.log("[INFO] Using fallback wallpaper from environment variable")
    }

    Component.onCompleted: reload()
  }

  function updateWallpaperFromNoctaliaConfig() {
    if (!noctaliaSettings.wallpaper.enabled) {
      console.log("[INFO] Wallpaper disabled in noctalia config")
      return
    }

    // Get current monitor name (you may need to adapt this based on your setup)
    if (Quickshell.screens.length > 0) {
      currentMonitorName = Quickshell.screens[0].name
    }

    // Look for monitor-specific wallpaper
    const monitors = noctaliaSettings.wallpaper.monitors
    let foundWallpaper = ""

    if (monitors && monitors.length > 0) {
      for (var i = 0; i < monitors.length; i++) {
        const monitor = monitors[i]
        if (monitor && monitor.name === currentMonitorName && monitor.wallpaper) {
          foundWallpaper = monitor.wallpaper
          console.log("[INFO] Found monitor-specific wallpaper for", currentMonitorName + ":", foundWallpaper)
          break
        }
      }
    }

    // Fallback to directory + some default logic if no specific wallpaper found
    if (!foundWallpaper && noctaliaSettings.wallpaper.directory) {
      console.log("[INFO] No monitor-specific wallpaper found, using directory:", noctaliaSettings.wallpaper.directory)
      // You might want to implement directory scanning logic here
      // For now, we'll just use the directory path as a fallback
      foundWallpaper = noctaliaSettings.wallpaper.directory
    }

    if (foundWallpaper) {
      root.noctaliaWallpaper = foundWallpaper
      console.log("[INFO] Using noctalia wallpaper:", foundWallpaper)
      root.wallpaperUpdated(foundWallpaper)
    } else {
      console.log("[INFO] No wallpaper found in noctalia config, using environment fallback")
    }
  }
}
