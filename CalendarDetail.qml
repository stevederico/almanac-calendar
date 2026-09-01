import QtQuick
import qs.Commons

// In-window details card for one calendar row.
Item {
  id: root
  property var host: null
  property var calendar: null

  readonly property color fg: host ? host.contentForeground : Color.foreground
  readonly property string fontFamily: host ? host.contentFontFamily : Style.font.family
  readonly property bool isLocal: calendar && !calendar.url
  readonly property bool isShown: calendar && calendar.enabled !== false
  readonly property int eventCount: calendar && calendar.eventCount ? calendar.eventCount : 0

  visible: calendar !== null
  z: 40

  function close() {
    saveName()
    dismiss()
  }

  function dismiss() {
    if (host) host.detailCalendar = null
  }

  function saveName() {
    if (!host || !calendar || !nameField) return
    var name = String(nameField.text || "").replace(/^\s+|\s+$/g, "")
    if (!name || name === calendar.name) return
    host.runCal(["rename", calendar.id, name])
  }

  onCalendarChanged: fillName()
  onVisibleChanged: if (visible) fillName()

  function fillName() {
    if (nameField && calendar)
      nameField.text = calendar.name || calendar.id || ""
  }

  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.46)

    MouseArea {
      anchors.fill: parent
      onClicked: root.close()
    }
  }

  Rectangle {
    id: card
    anchors.centerIn: parent
    width: Math.min(Style.space(420), parent.width - Style.space(72))
    implicitHeight: cardCol.implicitHeight + Style.space(40)
    height: implicitHeight
    color: Color.background
    border.width: Style.spacing.hairline
    border.color: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.18)

    MouseArea {
      anchors.fill: parent
    }

    Column {
      id: cardCol
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.leftMargin: Style.space(24)
      anchors.rightMargin: Style.space(24)
      anchors.topMargin: Style.space(20)
      spacing: Style.space(14)

      Text {
        text: root.calendar ? (root.calendar.name || root.calendar.id) : ""
        color: root.fg
        font.family: root.fontFamily
        font.pixelSize: Style.font.heading
        font.bold: true
      }

      Column {
        width: parent.width
        spacing: Style.space(6)

        Text {
          text: "NAME"
          color: Qt.darker(root.fg, 1.5)
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          font.letterSpacing: 1.4
        }

        Rectangle {
          width: parent.width
          height: Style.space(36)
          color: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.08)

          TextInput {
            id: nameField
            anchors.fill: parent
            anchors.leftMargin: Style.space(10)
            anchors.rightMargin: Style.space(10)
            verticalAlignment: TextInput.AlignVCenter
            color: root.fg
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            selectByMouse: true
            clip: true
            onAccepted: root.saveName()
          }
        }
      }

      Column {
        width: parent.width
        spacing: Style.space(8)

        Text {
          text: "COLOR"
          color: Qt.darker(root.fg, 1.5)
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          font.letterSpacing: 1.4
        }

        Row {
          spacing: Style.space(8)

          Repeater {
            model: [
              "#5b9fd4", "#e07a5f", "#81b29a", "#f2cc8f", "#9b8ec4",
              "#e9c46a", "#c4a574", "#d67b7b", "#6bb3b3", "#c47ba0"
            ]

            Rectangle {
              required property var modelData
              width: Style.space(18)
              height: Style.space(18)
              color: modelData
              border.width: root.calendar && root.calendar.color === modelData ? 2 : 0
              border.color: root.fg

              MouseArea {
                anchors.fill: parent
                hoverEnabled: false
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (root.host && root.calendar)
                    root.host.runCal(["color", root.calendar.id, modelData])
                }
              }
            }
          }
        }
      }

      Column {
        width: parent.width
        spacing: Style.space(8)

        Text {
          width: parent.width
          text: root.isLocal ? "On this machine. Not a feed." : "ICS subscribe"
          color: Qt.darker(root.fg, 1.45)
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }

        Text {
          width: parent.width
          text: root.isShown ? "Shown in the grid" : "Hidden"
          color: Qt.darker(root.fg, 1.45)
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }

        Text {
          width: parent.width
          text: root.eventCount === 1 ? "1 event in the store" : (root.eventCount + " events in the store")
          color: Qt.darker(root.fg, 1.45)
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }

        Text {
          visible: !root.isLocal
          width: parent.width
          text: root.calendar ? String(root.calendar.url || "") : ""
          wrapMode: Text.WrapAnywhere
          color: Qt.darker(root.fg, 1.35)
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
        }
      }

      Row {
        spacing: Style.space(16)

        Text {
          text: root.isShown ? "Hide" : "Show"
          color: hideMouse.containsMouse
            ? Style.hoverStateColor(root.fg, Color.accent)
            : root.fg
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          font.bold: true
          topPadding: Style.space(4)
          bottomPadding: Style.space(4)

          MouseArea {
            id: hideMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (root.host && root.calendar)
                root.host.runCal(["toggle", root.calendar.id])
            }
          }
        }

        Text {
          visible: !root.isLocal
          text: "Unsubscribe"
          color: unsubMouse.containsMouse
            ? Style.hoverStateColor(root.fg, Color.accent)
            : Qt.darker(root.fg, 1.35)
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          topPadding: Style.space(4)
          bottomPadding: Style.space(4)

          MouseArea {
            id: unsubMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (!root.host || !root.calendar || !root.calendar.id) return
              var id = root.calendar.id
              root.dismiss()
              root.host.runCal(["unsubscribe", id])
            }
          }
        }

        Text {
          text: "Done"
          color: doneMouse.containsMouse
            ? Style.hoverStateColor(root.fg, Color.accent)
            : Qt.darker(root.fg, 1.45)
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          topPadding: Style.space(4)
          bottomPadding: Style.space(4)

          MouseArea {
            id: doneMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.close()
          }
        }
      }
    }
  }
}
