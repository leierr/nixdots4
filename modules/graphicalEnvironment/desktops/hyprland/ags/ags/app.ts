import { App, Gdk } from "astal/gtk3"
//import style from "./style/style.scss"
import csshotreload from "./cssHotLoad"; csshotreload;
import topbar from "./widgets/topbar/main"
import notification_popups from "./widgets/notifications/main"

import Hyprland from "gi://AstalHyprland"
const hyprland = Hyprland.get_default()

function getMonitorName(gdkmonitor: Gdk.Monitor) {
  const display = Gdk.Display.get_default() as Gdk.Display;
  const screen = display.get_default_screen();

  for(let i = 0; i < display.get_n_monitors(); ++i) {
    if(gdkmonitor === display.get_monitor(i))
      return screen.get_monitor_plug_name(i);
  }
}

App.start({
  //css: style,
  icons: "./icons",
  main() {
    App.get_monitors().map(gdk_monitor => {
      let hyprland_monitor = hyprland.monitors.find(m => m.name === getMonitorName(gdk_monitor)) as Hyprland.Monitor;

      topbar(gdk_monitor, hyprland_monitor)
    });

    notification_popups()
  },
})
