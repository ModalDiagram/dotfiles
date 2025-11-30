import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Services.UPower


Scope {
	id: root

	property bool shouldShowOsd: false
  property int batteryPerc: UPower.displayDevice.percentage * 100
  property int warnLevel: 20

  Connections {
    target: UPower.displayDevice

    function onPercentageChanged(): void {
      if (!UPower.onBattery) {
        root.shouldShowOsd = false;
        return;
      }

      if (root.batteryPerc < root.warnLevel) {
        root.shouldShowOsd = true;
      }
    }
  }

	LazyLoader {
		active: root.shouldShowOsd

		PanelWindow {
      anchors.right: true
      anchors.top: true
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay

			color: "transparent"
			mask: Region {}

      Canvas {
        width: 100
        height: 100
        onPaint: {
          var ctx = getContext("2d")
          var ratio = batteryPerc / warnLevel / 5 * 100

          ctx.clearRect(0, 0, width, height)

          var stripeHeight = 5
          var i = 0
          for (var x = 100 - ratio; x < 100; x += stripeHeight, i++) {
            ctx.fillStyle = (i % 2) == 0 ? "red" : "firebrick"
            ctx.beginPath()
            ctx.moveTo(x, 0)
            ctx.lineTo(width, 100 - x)
            ctx.lineTo(width, 0)
            ctx.closePath()
            ctx.fill()
          }
        }
      }
		}
	}
}
