{ lib
, stdenvNoCC
, makeWrapper
, writeShellScript
, writeText
, bash
, coreutils
, jq
, omarchyShell
}:

let
  reply = writeShellScript "pinentry-omarchy-reply" ''
    set -eu
    umask 077
    printf '%s' "$PINENTRY_REPLY" > "$PINENTRY_RESPONSE_FILE"
  '';
  launcher = writeShellScript "pinentry-omarchy" ''
    set -u

    title="Unlock Bitwarden"
    description=""
    prompt="Enter password"
    reply_program="$(dirname "$0")/pinentry-omarchy-reply"

    decode() {
      local value=''${1-}
      printf '%b' "''${value//%/\\x}"
    }

    encode() {
      local value=$1
      value=''${value//%/%25}
      value=''${value//$'\r'/%0D}
      value=''${value//$'\n'/%0A}
      printf '%s' "$value"
    }

    reply() {
      local reply_dir reply_file password status summon_result payload
      reply_dir=$(mktemp -d "''${XDG_RUNTIME_DIR:-/tmp}/pinentry-omarchy.XXXXXX") || return 1
      reply_file="$reply_dir/reply"
      payload=$(jq -cn \
        --arg replyFile "$reply_file" \
        --arg replyProgram "$reply_program" \
        --arg title "$title" \
        --arg description "$description" \
        --arg prompt "$prompt" \
        '{replyFile: $replyFile, replyProgram: $replyProgram, title: $title, description: $description, prompt: $prompt}') || {
          rm -rf "$reply_dir"
          return 1
        }

      summon_result=$(omarchy-shell shell summon vin.pinentry "$payload" 2>/dev/null)
      status=$?
      while [[ $status -eq 0 && $summon_result == "ok" && ! -f $reply_file ]]; do
        sleep 0.05
      done

      if [[ $status -eq 0 && -f $reply_file ]]; then
        password=$(<"$reply_file")
        rm -rf "$reply_dir"
        printf 'D %s\nOK\n' "$(encode "$password")"
        return 0
      fi

      rm -rf "$reply_dir"
      printf 'ERR 83886179 Operation cancelled\n'
    }

    printf 'OK Pleased to meet you\n'
    while IFS= read -r line; do
      command=''${line%% *}
      argument=""
      [[ $line == *" "* ]] && argument=''${line#* }

      case "$command" in
        OPTION|SETKEYINFO|SETOK|SETCANCEL|SETNOTOK|SETREPEAT|SETREPEATERROR|SETQUALITYBAR|SETQUALITYBAR_TT|SETGENPIN|SETGENPIN_TT|SETTIMEOUT|SETERROR)
          printf 'OK\n'
          ;;
        SETTITLE)
          title=$(decode "$argument")
          printf 'OK\n'
          ;;
        SETDESC)
          description=$(decode "$argument")
          printf 'OK\n'
          ;;
        SETPROMPT)
          prompt=$(decode "$argument")
          printf 'OK\n'
          ;;
        GETINFO)
          case "$argument" in
            flavor) printf 'D omarchy\nOK\n' ;;
            version) printf 'D 1.0\nOK\n' ;;
            *) printf 'ERR 67109139 Unknown information\n' ;;
          esac
          ;;
        GETPIN)
          reply
          ;;
        BYE)
          printf 'OK closing connection\n'
          exit 0
          ;;
        *)
          printf 'ERR 67109139 Unknown command\n'
          ;;
      esac
    done
  '';
  manifest = writeText "manifest.json" ''
    {"schemaVersion":1,"id":"vin.pinentry","name":"Pinentry","version":"1.0.0","author":"Vin","description":"Omarchy-styled Pinentry dialog","kinds":["panel"],"keepLoaded":true,"entryPoints":{"panel":"Panel.qml"}}
  '';
  panel = writeText "Panel.qml" ''
    import QtQuick
    import Quickshell
    import Quickshell.Io
    import Quickshell.Wayland
    import qs.Commons
    import qs.Ui

    Item {
      id: root
      property var shell: null
      property string omarchyPath: ""
      property bool opened: false
      property string title: "Unlock Bitwarden"
      property string description: ""
      property string prompt: "Enter password"
      property string responseFile: ""
      property string responseProgram: ""
      property color accent: Color.polkit.accent
      property color background: Color.polkit.background
      property color foreground: Color.polkit.text
      property color border: Color.polkit.border
      property color scrim: Color.polkit.scrim
      readonly property int fieldHeight: Math.max(Style.space(42), Style.spacing.controlHeight)
      readonly property int contentMargin: Style.spacing.panelPadding
      readonly property int cardWidth: Math.min(Style.space(312), Math.max(Style.space(260), panel.width - Style.gapsOut * 2))
      readonly property var borderSpec: Border.surfaceSpec("polkit", "border", border, Math.max(1, Style.space(2)), "border-alpha")

      function open(payload) {
        var data
        try { data = JSON.parse(payload) } catch (error) { return }
        if (!data.replyFile || !data.replyProgram) return
        responseFile = String(data.replyFile)
        responseProgram = String(data.replyProgram)
        title = String(data.title || "Unlock Bitwarden")
        description = String(data.description || "")
        prompt = String(data.prompt || "Enter password")
        passwordInput.text = ""
        opened = true
        Qt.callLater(function() { passwordInput.forceActiveFocus() })
      }

      function close() {
        opened = false
        passwordInput.text = ""
      }

      function submit() {
        responseWriter.environment = ({ "PINENTRY_REPLY": passwordInput.text, "PINENTRY_RESPONSE_FILE": responseFile })
        responseWriter.command = [responseProgram]
        responseWriter.running = true
      }

      PanelWindow {
        id: panel
        visible: root.opened
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        WlrLayershell.namespace: "vin-pinentry"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        exclusionMode: ExclusionMode.Ignore

        Rectangle { anchors.fill: parent; color: root.scrim }
        MouseArea { anchors.fill: parent; onClicked: passwordInput.forceActiveFocus() }

        BorderSurface {
          id: card
          width: root.cardWidth
          height: root.fieldHeight + root.contentMargin * 2
          anchors.centerIn: parent
          radius: Style.cornerRadius
          color: root.background
          borderSpec: root.borderSpec
          padding: root.contentMargin
          MouseArea { anchors.fill: parent; onClicked: passwordInput.forceActiveFocus() }

          Row {
            anchors.fill: parent
            anchors.topMargin: card.contentTopInset
            anchors.rightMargin: card.contentRightInset
            anchors.bottomMargin: card.contentBottomInset
            anchors.leftMargin: card.contentLeftInset
            spacing: Style.space(14)

            Text {
              text: "\uf023"
              color: root.accent
              font.family: Style.font.menuFamily
              font.pixelSize: Style.font.iconLarge
              width: Style.space(26)
              height: root.fieldHeight
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
            }

            Item {
              width: parent.width - Style.space(40)
              height: root.fieldHeight
              TextInput {
                id: passwordInput
                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                activeFocusOnPress: true
                clip: true
                selectionColor: Util.alpha(root.accent, 0.45)
                selectedTextColor: root.foreground
                font.family: Style.font.menuFamily
                font.pixelSize: Style.font.iconLarge
                echoMode: TextInput.Password
                passwordCharacter: "*"
                color: root.foreground
                onAccepted: root.submit()
                Keys.onEscapePressed: root.close()
              }
              Text {
                anchors.fill: parent
                text: root.prompt
                color: root.foreground
                opacity: 0.36
                font.family: Style.font.menuFamily
                font.pixelSize: Style.font.iconLarge
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                visible: passwordInput.text.length === 0
              }
            }
          }
        }

        Rectangle {
          width: Math.min(label.implicitWidth + Style.space(24), panel.width - Style.gapsOut * 2)
          height: Style.space(28)
          anchors.horizontalCenter: card.horizontalCenter
          anchors.bottom: card.top
          anchors.bottomMargin: Style.space(10)
          radius: Style.cornerRadius
          color: root.background
          Text {
            id: label
            anchors.fill: parent
            anchors.leftMargin: Style.space(12)
            anchors.rightMargin: Style.space(12)
            text: root.description || root.title
            color: root.foreground
            font.family: Style.font.menuFamily
            font.pixelSize: Style.font.bodySmall
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideMiddle
          }
        }
      }

      Process {
        id: responseWriter
        onExited: root.close()
      }
    }
  '';
in
stdenvNoCC.mkDerivation {
  pname = "pinentry-omarchy";
  version = "1.0.0";
  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 ${launcher} "$out/bin/.pinentry-omarchy-unwrapped"
    install -Dm755 ${reply} "$out/bin/pinentry-omarchy-reply"
    makeWrapper "$out/bin/.pinentry-omarchy-unwrapped" "$out/bin/pinentry-omarchy" \
      --prefix PATH : ${lib.escapeShellArg (lib.makeBinPath [ bash coreutils jq omarchyShell ])}
    install -Dm644 ${manifest} "$out/share/omarchy/plugins/vin.pinentry/manifest.json"
    install -Dm644 ${panel} "$out/share/omarchy/plugins/vin.pinentry/Panel.qml"
  '';
}
