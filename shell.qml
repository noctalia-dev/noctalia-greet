pragma ComponentBehavior

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Greetd

import qs.Commons
import qs.Components.UI
import qs.Components.Logic

ShellRoot {
  id: root

  // Config via environment variables
  readonly property string instant_auth: Quickshell.env("NOCTALIA_DM_INSTANTAUTH")
  readonly property string preferred_session: Quickshell.env("NOCTALIA_DM_PREF_SES")
  readonly property string preferred_user: Quickshell.env("NOCTALIA_DM_PREF_USR")
  // Fallback to empty string and log later to avoid assigning console.log result
  readonly property string sessions: Quickshell.env("NOCTALIA_DM_SESSIONS") || ""
  readonly property string wallpaper_path: Quickshell.env("NOCTALIA_DM_WALLPATH")

  // Noctalia config paths
  readonly property string noctaliaConfigDir: Quickshell.env("NOCTALIA_CONFIG_DIR") || (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/noctalia/"
  readonly property string noctaliaSettingsFile: noctaliaConfigDir + "settings.json"

  // Wallpaper state from noctalia config
  property string noctaliaWallpaper: ""

  function authenticate() {
    Greetd.createSession(processManagers.currentUser)
  }

  Component.onCompleted: {
    if (sessions == "") {
      console.log("[WARN] empty sessions list, defaulting to hyprland")
      processManagers.sessions.current_session = "hyprland"
      processManagers.sessions.current_session_name = "hyprland"
    }

    // Initialize session from saved settings after UI load (final check occurs after sessions load too)
    const saved = Settings.lastSessionId
    if (saved && processManagers.sessions.session_execs.length > 0) {
      for (var i = 0; i < processManagers.sessions.session_names.length; i++) {
        if (processManagers.sessions.session_execs[i].toLowerCase().includes(saved.toLowerCase()) || processManagers.sessions.session_names[i].toLowerCase().includes(saved.toLowerCase())) {
          processManagers.sessions.current_ses_index = i
          break
        }
      }
    }
  }

  // Wallpaper manager
  WallpaperManager {
    id: wallpaperManager
    noctaliaConfigDir: root.noctaliaConfigDir
    noctaliaSettingsFile: root.noctaliaSettingsFile

    onWallpaperUpdated: function (wallpaperPath) {
      root.noctaliaWallpaper = wallpaperPath
    }
  }

  // Process managers
  ProcessManagers {
    id: processManagers
    sessions: root.sessions
    preferredUser: root.preferred_user
    preferredSession: root.preferred_session
    instantAuth: root.instant_auth

    onAuthenticateRequested: root.authenticate()

    Component.onCompleted: {
      console.log("[Shell] ProcessManagers created")
    }
  }

  // Main greeter interface
  WlSessionLock {
    id: sessionLock

    property string fakeBuffer: ""
    property string passwdBuffer: ""
    readonly property bool unlocking: Greetd.state == GreetdState.Authenticating

    locked: true

    WlSessionLockSurface {
      // Background with wallpaper and gradient overlay
      Background {
        wallpaperPath: root.wallpaper_path
        noctaliaWallpaper: root.noctaliaWallpaper
      }

      Item {
        anchors.fill: parent

        ColumnLayout {
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.topMargin: 80
          spacing: 40

          // Time and Date display
          TimeDisplay {
            Layout.alignment: Qt.AlignHCenter
          }

          // Centered circular avatar area
          UserAvatar {
            currentUser: processManagers.currentUser
            unlocking: sessionLock.unlocking
            Layout.alignment: Qt.AlignHCenter

            onUserClicked: processManagers.users.next()
          }

          // Session selector below avatar
          SessionSelector {
            currentSessionName: processManagers.currentSessionName
            Layout.alignment: Qt.AlignHCenter

            onSessionClicked: {
              processManagers.sessions.next()
              // Persist selection (use identifier from exec or sanitized name)
              const ident = processManagers.currentSession.split(" ")[0]
              Settings.setLastSessionId(ident || processManagers.currentSessionName)
            }
          }
        }

        // Terminal-style input area
        TerminalInput {
          currentUser: processManagers.currentUser
          passwordBuffer: sessionLock.passwdBuffer
          unlocking: sessionLock.unlocking
          anchors.centerIn: parent
          anchors.verticalCenterOffset: 50

          onPasswordChanged: function (password) {
            sessionLock.passwdBuffer = password
          }

          onAuthenticateRequested: root.authenticate()
        }
      }

      // Hidden password input (keeps key handling consistent)
      TextInput {
        id: passwordInput
        width: 0
        height: 0
        visible: false
        focus: true
        echoMode: TextInput.Password
        text: sessionLock.passwdBuffer

        onTextChanged: {
          sessionLock.passwdBuffer = text
        }

        Component.onCompleted: {
          passwordInput.forceActiveFocus()
        }

        Keys.onPressed: kevent => {
          if (kevent.key === Qt.Key_Enter || kevent.key === Qt.Key_Return) {
            if (Greetd.state == GreetdState.Inactive) {
              root.authenticate()
            }
            kevent.accepted = true
          }
        }
      }
    }
  }

  // Greetd connections
  Connections {
    target: Greetd

    function onAuthMessage(message, error, responseRequired, echoResponse) {
      console.log("[GREETD] msg='" + message + "' err='" + error + "' resreq=" + responseRequired + " echo=" + echoResponse)

      if (responseRequired) {
        Greetd.respond(sessionLock.passwdBuffer)
        sessionLock.passwdBuffer = ""
        sessionLock.fakeBuffer = ""
        return
      }

      // Finger print support
      Greetd.respond("")
    }

    function onReadyToLaunch() {
      sessionLock.locked = false
      console.log("[GREETD EXEC] " + processManagers.currentSession)
      // Let greetd handle quitting to avoid compositor handoff glitches
      Greetd.launch(processManagers.currentSession.split(" "), [], true)
    }
  }
}
