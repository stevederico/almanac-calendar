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
    if (host) host.detailCalendar = null
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
    height: cardCol.implicitHeight + Style.space(40)
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

      Row {
        width: parent.width
        spacing: Style.space(12)

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: Style.space(12)
          height: Style.space(12)
          color: root.calendar && root.calendar.color
            ? root.calendar.color
            : Style.selectedStateColor(root.fg, Color.accent)
        }

        Text {
          width: parent.width - Style.space(24)
          text: root.calendar ? (root.calendar.name || root.calendar.id) : ""
          wrapMode: Text.WordWrap
          color: root.fg
          font.family: root.fontFamily
          font.pixelSize: Style.font.heading
          font.bold: true
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
              if (!root.host || !root.calendar) return
              root.host.runCal(["unsubscribe", root.calendar.id])
              root.close()
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
