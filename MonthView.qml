import QtQuick
import qs.Commons
import "Model.js" as Model

Item {
  id: root
  property var host: null

  readonly property var weeks: host ? Model.monthGrid(host.viewYear, host.viewMonth, host.weekStart, host.todayKey) : []
  readonly property int cellSpacing: host ? host.cellSpacing : 6
  readonly property int weekColumnWidth: host ? host.weekColumnWidth : 36
  readonly property int gutterWidth: host ? host.gutterWidth : 20
  readonly property int headerHeight: host ? host.headerHeight : 32
  readonly property int gridGutter: weekColumnWidth + gutterWidth + cellSpacing
  readonly property int cellWidth: Math.max(Style.space(44), Math.floor((width - gridGutter - cellSpacing * 6) / 7))
  readonly property int cellHeight: Math.max(Style.space(40), Math.floor((height - headerHeight - cellSpacing * 6) / 6))
  readonly property int dayFontSize: Math.max(Style.font.caption, Math.round(cellHeight * 0.16))
  readonly property int chipHeight: Style.space(16)
  readonly property int chipMax: {
    var reserved = Style.space(24)
    return Math.max(1, Math.min(3, Math.floor((cellHeight - reserved) / (chipHeight + Style.space(2)))))
  }

  Column {
    anchors.fill: parent
    spacing: root.cellSpacing

    Row {
      spacing: root.cellSpacing

      Text {
        width: root.weekColumnWidth
        height: root.headerHeight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "W"
        color: Qt.darker(root.host.contentForeground, 1.9)
        font.family: root.host.contentFontFamily
        font.pixelSize: Style.font.caption
        font.letterSpacing: 1
        font.bold: true
      }

      Item {
        width: root.gutterWidth
        height: root.headerHeight
      }

      Repeater {
        model: root.host.weekdays

        Text {
          required property var modelData
          width: root.cellWidth
          height: root.headerHeight
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          text: root.host.weekdayLabel(modelData)
          color: Qt.darker(root.host.contentForeground, 1.5)
          font.family: root.host.contentFontFamily
          font.pixelSize: Style.font.caption
          font.letterSpacing: 1
          font.bold: true
        }
      }
    }

    Repeater {
      model: root.weeks

      Row {
        required property var modelData
        spacing: root.cellSpacing

        Text {
          width: root.weekColumnWidth
          height: root.cellHeight
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          text: modelData.week
          color: Qt.darker(root.host.contentForeground, 1.9)
          font.family: root.host.contentFontFamily
          font.pixelSize: Style.font.caption
        }

        Item {
          width: root.gutterWidth
          height: root.cellHeight
        }

        Repeater {
          model: modelData.days

          Rectangle {
            id: cell
            required property var modelData
            readonly property var events: root.host.dayEvents(modelData.key)
            readonly property int shown: Math.min(events.length, root.chipMax)
            readonly property int extra: events.length - shown

            width: root.cellWidth
            height: root.cellHeight
            radius: 0
            color: modelData.key === root.host.selectedKey
              ? Style.hoverFillFor(root.host.contentForeground, Color.accent)
              : "transparent"
            border.width: modelData.today ? Style.spacing.hairline : 0
            border.color: Style.normalBorderFor(root.host.contentForeground, Color.accent)

            Text {
              id: dayNum
              anchors.top: parent.top
              anchors.left: parent.left
              anchors.topMargin: Style.space(4)
              anchors.leftMargin: Style.space(6)
              text: modelData.day
              color: root.host.cellForeground(modelData)
              font.family: root.host.contentFontFamily
              font.pixelSize: root.dayFontSize
              font.bold: modelData.today || modelData.key === root.host.selectedKey
            }

            Column {
              visible: cell.shown > 0
              anchors.top: dayNum.bottom
              anchors.topMargin: Style.space(2)
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: Style.space(4)
              anchors.rightMargin: Style.space(4)
              spacing: Style.space(2)

              Repeater {
                model: cell.shown

                Item {
                  required property int index
                  readonly property var event: cell.events[index]
                  readonly property color evColor: root.host.eventColor(event)
                  width: parent.width
                  height: root.chipHeight

                  Rectangle {
                    anchors.fill: parent
                    color: evColor
                    opacity: cell.modelData.key === root.host.selectedKey ? 0.30 : 0.20
                  }

                  Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: Style.space(3)
                    color: evColor
                  }

                  Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Style.space(6)
                    anchors.rightMargin: Style.space(4)
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.host.chipLabel(event)
                    elide: Text.ElideRight
                    color: root.host.contentForeground
                    opacity: cell.modelData.inMonth ? 1 : 0.45
                    font.family: root.host.contentFontFamily
                    font.pixelSize: Math.max(10, Style.font.caption - 1)
                  }
                }
              }

              Text {
                visible: cell.extra > 0
                text: "+" + cell.extra + " more"
                color: Qt.darker(root.host.contentForeground, 1.55)
                font.family: root.host.contentFontFamily
                font.pixelSize: Math.max(10, Style.font.caption - 1)
              }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: false
              cursorShape: Qt.PointingHandCursor
              onClicked: root.host.selectDay(cell.modelData)
            }
          }
        }
      }
    }
  }

  Rectangle {
    x: root.weekColumnWidth + root.cellSpacing + Math.round((root.gutterWidth - width) / 2)
    y: root.headerHeight + root.cellSpacing
    width: Style.spacing.hairline
    height: Math.max(0, root.height - root.headerHeight - root.cellSpacing)
    color: root.host.contentForeground
    opacity: 0.1
  }
}
