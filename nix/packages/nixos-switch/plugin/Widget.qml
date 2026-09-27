import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "coelebs.nixos-switch"

  property bool rebuilding: false

  function refresh() {
    if (!stateProc.running) stateProc.running = true
  }

  visible: rebuilding
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Timer {
    interval: 500
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Process {
    id: stateProc
    command: ["sh", "-c", "state=\"${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/nixos-switch.pid\"; if [ -r \"$state\" ]; then read -r pid < \"$state\"; case $pid in *[!0-9]*|'') exit 1;; esac; kill -0 \"$pid\" 2>/dev/null; else exit 1; fi"]
    onExited: function(exitCode) {
      root.rebuilding = exitCode === 0
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf021"
    slotSize: Style.bar.statusSlot
    fontSize: Style.font.caption
    tooltipText: "Rebuilding NixOS..."
    interactive: true
    pressable: false

    RotationAnimation on textRotation {
      running: root.rebuilding
      loops: Animation.Infinite
      from: 0
      to: 360
      duration: 900
    }
  }
}
