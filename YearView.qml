import QtQuick
import qs.Commons
import "Model.js" as Model

Item {
  id: root
  property var host: null

  readonly property color fg: host ? host.contentForeground : Color.foreground
  readonly property string fontFamily: host ? host.contentFontFamily : Style.font.family
  readonly property var months: host ? host.yearMonths : []
  readonly property int colGap: Style.space(20)
  readonly property int rowGap: Style.space(24)
  readonly property int colWidth: Math.max(Style.space(140), Math.floor((width - colGap * 3) / 4))
  readonly property int rowHeight: Math.max(Style.space(140), Math.floor((height - rowGap * 2) / 3))
  readonly property var monthNames: [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ]

  Grid {
    anchors.fill: parent
    columns: 4
    columnSpacing: root.colGap
    rowSpacing: root.rowGap

    Repeater {
      model: root.months

      Item {
        required property var modelData
        width: root.colWidth
        height: root.rowHeight

        Text {
          id: monthName
          text: root.monthNames[modelData.month]
          color: root.fg
          font.family: root.fontFamily
          font.pixelSize: Style.font.title
          font.bold: true

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.host.viewYear = modelData.year
              root.host.viewMonth = modelData.month
              root.host.viewMode = "month"
            }
          }
        }

        Canvas {
          id: canvas
          anchors.top: monthName.bottom
          anchors.topMargin: Style.space(8)
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          renderTarget: Canvas.FramebufferObject

          readonly property int headerH: Style.space(16)

          function dayAt(px, py) {
            var cw = width / 7
            var ch = (height - headerH) / 6
            if (py < headerH || cw <= 0 || ch <= 0) return null
            var col = Math.floor(px / cw)
            var row = Math.floor((py - headerH) / ch)
            if (row < 0 || row > 5 || col < 0 || col > 6) return null
            var day = modelData.weeks[row].days[col]
            return day.inMonth ? day : null
          }

          onWidthChanged: paintWait.restart()
          onHeightChanged: paintWait.restart()
          onVisibleChanged: if (visible) paintWait.restart()
          Timer {
            id: paintWait
            interval: 16
            onTriggered: canvas.requestPaint()
          }

          Connections {
            target: root.host
            function onSelectedKeyChanged() { canvas.requestPaint() }
            function onEventsByDateChanged() { canvas.requestPaint() }
            function onTodayKeyChanged() { canvas.requestPaint() }
          }

          onPaint: {
            var ctx = getContext("2d")
            var w = width
            var h = height
            ctx.clearRect(0, 0, w, h)
            if (w < 8 || h < 8 || !root.host) return

            var cw = w / 7
            var headerH = canvas.headerH
            var ch = (h - headerH) / 6
            var dim = Qt.darker(root.fg, 1.7).toString()
            var ink = root.fg.toString()
            var accent = Style.selectedStateColor(root.fg, Color.accent).toString()
            var selected = root.host.selectedKey
            var events = root.host.eventsByDate
            var weekdays = root.host.weekdays

            ctx.textAlign = "center"
            ctx.textBaseline = "middle"
            ctx.font = Style.font.caption + "px sans-serif"
            ctx.fillStyle = dim
            for (var i = 0; i < 7; i++)
              ctx.fillText(root.host.weekdayLabel(weekdays[i]).charAt(0), cw * i + cw / 2, headerH / 2)

            var weeks = modelData.weeks
            for (var r = 0; r < 6; r++) {
              var days = weeks[r].days
              for (var c = 0; c < 7; c++) {
                var day = days[c]
                if (!day.inMonth) continue
                var x = c * cw
                var y = headerH + r * ch
                if (day.today) {
                  ctx.strokeStyle = Style.normalBorderFor(root.fg, Color.accent).toString()
                  ctx.strokeRect(x + 0.5, y + 0.5, cw - 1, ch - 1)
                }
                ctx.fillStyle = (day.today || day.key === selected) ? ink : root.host.cellForeground(day).toString()
                ctx.fillText(String(day.day), x + cw / 2, y + ch / 2)
                var list = events[day.key]
                if (list && list.length) {
                  ctx.fillStyle = accent
                  ctx.fillRect(x + cw / 2 - 1.5, y + ch - 5, 3, 3)
                }
              }
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: function (event) {
              var day = canvas.dayAt(event.x, event.y)
              if (!day) return
              root.host.selectDay(day)
              root.host.viewMode = "day"
            }
          }
        }
      }
    }
  }
}
