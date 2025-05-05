import { bind, timeout, GLib } from "astal"
import { Astal, Gdk } from "astal/gtk3"
import Notifd from "gi://AstalNotifd"
import Hyprland from "gi://AstalHyprland"
import popup_notification from "./popups"

const hyprland = Hyprland.get_default()
const notifd = Notifd.get_default()

const HyprlandToGdkMonitor = (mon: Hyprland.Monitor) => {
  let GDKdisplay = Gdk.Display.get_default() as Gdk.Display
  let GDKscreen = GDKdisplay.get_default_screen();

  for(let i = 0; i < GDKdisplay.get_n_monitors(); ++i) {
    if(mon.name === GDKscreen.get_monitor_plug_name(i)) return GDKdisplay.get_monitor(i)
  }
}

// run through and dismiss everything older than 24h on restart
for (let n of notifd.get_notifications()) {
  if (n.time < Math.floor(GLib.get_real_time() / 1000000) - (24 * 60 * 60)) {
    print(`Dismissing notification from ${n.time}`);
    n.dismiss();
  }
}

export default () => (
  <window
    gdkmonitor = { bind(hyprland, "focusedMonitor").as(mon => HyprlandToGdkMonitor(mon) || undefined) }
    exclusivity = { Astal.Exclusivity.EXCLUSIVE }
    anchor = { Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT }
  >
    <box
      vexpand
      vertical
      className = "notification_popups_list"
      setup = { (self) => {
        self.hook(notifd, "notified", ( self, id ) => {
          if (notifd.dontDisturb) return
          let notification = notifd.get_notification(id)
          if (!notification) return
          let widget = popup_notification(notification)
          Object.assign(widget, { notification_id: id })

          self.children = [widget, ...self.children]
          timeout(120000, () => self.children.find((w) => w === widget)?.destroy())
        })
        self.hook(notifd, "resolved", ( self, id ) => self.children.find((w) => w.notification_id === id)?.destroy())
      }}
    />
  </window>
)
