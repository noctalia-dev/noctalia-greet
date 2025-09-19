import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
  id: root

  // Properties to be set by parent
  property string sessions: ""
  property string preferredUser: ""
  property string preferredSession: ""
  property bool instantAuth: false

  // Signals
  signal authenticateRequested

  // Expose process properties at root level for binding
  property string currentUser: users.current_user
  property string currentSession: sessions.current_session
  property string currentSessionName: sessions.current_session_name

  Component.onCompleted: {
    console.log("[ProcessManagers] Component completed, starting processes...")
    console.log("[ProcessManagers] Sessions:", sessions)
    console.log("[ProcessManagers] Preferred user:", preferredUser)
    console.log("[ProcessManagers] Preferred session:", preferredSession)
  }

  // User management process
  Process {
    id: users

    property string current_user: users_list[current_user_index] ?? ""
    property int current_user_index: 0
    property list<string> users_list: []

    function next() {
      current_user_index = (current_user_index + 1) % users_list.length
    }

    command: ["awk", `BEGIN { FS = ":"} /\\/home/ { print $1 }`, "/etc/passwd"]
    running: true

    Component.onCompleted: {
      console.log("[ProcessManagers] Users process starting...")
    }

    stderr: SplitParser {
      onRead: data => console.log("[ERR] " + data)
    }
    stdout: SplitParser {
      onRead: data => {
                console.log("[USERS] " + data)
                if (data == root.preferredUser) {
                  console.log("[INFO] Found preferred user " + root.preferredUser)
                  users.current_user_index = users.users_list.length
                }
                users.users_list.push(data)
                console.log("[ProcessManagers] Users list updated, current user:", users.current_user)
              }
    }

    onExited: if (root.instantAuth && !users.running) {
                console.log("[USERS EXIT]")
                root.authenticateRequested()
              }
  }

  // Session management process
  Process {
    id: sessions

    property int current_ses_index: 0
    property string current_session: session_execs[current_ses_index] ?? "hyprland"
    property string current_session_name: session_names[current_ses_index] ?? "Hyprland"
    property list<string> session_execs: []
    property list<string> session_names: []
    property bool restoredFromSettings: false

    function next() {
      current_ses_index = (current_ses_index + 1) % session_execs.length
    }

    function moveToFront(index) {
      if (index <= 0 || index >= session_execs.length)
        return
      const exec = session_execs[index]
      const name = session_names[index]
      session_execs.splice(index, 1)
      session_names.splice(index, 1)
      session_execs.unshift(exec)
      session_names.unshift(name)
      current_ses_index = 0
    }

    command: [Qt.resolvedUrl("../../scripts/session.sh"), root.sessions]
    running: true

    Component.onCompleted: {
      console.log("[ProcessManagers] Sessions process starting...")
    }

    stderr: SplitParser {
      onRead: data => console.log("[ERR] " + data)
    }
    stdout: SplitParser {
      onRead: data => {
                const parsedData = data.split(",")
                console.log("[SESSIONS] " + parsedData[2])
                if (parsedData[0] == root.preferredSession) {
                  console.log("[INFO] Found preferred session " + root.preferredSession)
                  sessions.current_ses_index = sessions.session_names.length
                }
                sessions.session_names.push(parsedData[1])
                sessions.session_execs.push(parsedData[2])
                console.log("[ProcessManagers] Sessions list updated, current session:", sessions.current_session)
              }
    }

    onExited: {
      // After sessions populated, prefer saved session as first entry
      if (!restoredFromSettings && Settings.lastSessionId && session_execs.length > 0) {
        const saved = Settings.lastSessionId.toLowerCase()
        let idx = -1
        for (var i = 0; i < session_execs.length; i++) {
          if (session_execs[i].toLowerCase().includes(saved) || session_names[i].toLowerCase().includes(saved)) {
            idx = i
            break
          }
        }
        if (idx >= 0) {
          moveToFront(idx)
          restoredFromSettings = true
        }
      }

      if (root.instantAuth && !users.running) {
        console.log("[SESSIONS EXIT]")
        root.authenticateRequested()
      }
    }
  }
}
