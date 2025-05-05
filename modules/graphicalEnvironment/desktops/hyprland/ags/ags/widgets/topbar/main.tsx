import { bind, GLib, Gio, Variable } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk3"
import Hyprland from "gi://AstalHyprland"
import Tray from "gi://AstalTray"

const Distro_Logo = () => (
  <button className="topbar_os_logo" >
    <icon icon={GLib.get_os_info("LOGO") || "missing-symbolic"} />
  </button>
)

const Workspaces = ( { hyprland_monitor }: { hyprland_monitor: Hyprland.Monitor } ) => {
  const hyprland = Hyprland.get_default()

  return (
    <eventbox
      onScroll={(_, event) => {
        if (event.delta_y < 0) { hyprland.dispatch("workspace", "m-1") } // scroll up
        else if (event.delta_y > 0) { hyprland.dispatch("workspace", "m+1") } // scroll down
      }}
    >
      <box className="topbar_workspace_indicator">
        { bind( hyprland, "workspaces" ).as( wss => wss
          .filter( ws => ws.monitor === hyprland_monitor )
          .sort(( a, b ) => a.id - b.id)
          .map(( ws, index ) => {
            const Bindings = Variable.derive([bind(hyprland, "focusedWorkspace"), bind(ws, "clients")], (focused, clients) => ({
              classname: `${focused === ws ? "active " : ""}${clients.length > 0 ? "occupied" : ""}`
            }))

            return(
              <button
                className={bind(Bindings).as(c => c.classname)}
                cursor={'pointer'}
                onClicked={() => ws.focus()}
              >
                { index + 1 }
              </button>
            )
          })
        )}
      </box>
    </eventbox>
  )
}

const Time = () => {
  const time = Variable<string>("").poll(5000, () => GLib.DateTime.new_now_local().format("%e %b  ·  %H:%M")!
    .replace(/\b\w/g, c => c.toUpperCase()) // Capitalize first letter of the month
    .replace(/\./g, '') // Remove the period from date
    .replace(/^\s+|\s+$/g, '') // Remove excessive spaces.
  )
  return (
    <button className="topbar_time" cursor={'pointer'} >
      <label onDestroy={() => time.drop()} label={time()} />
    </button>
  )
}

const SysTray = () => {
  const tray = Tray.get_default()

  function createMenu(menuModel: Gio.MenuModel, actionGroup: Gio.ActionGroup): Gtk.Menu {
    const menu: Gtk.Menu = Gtk.Menu.new_from_model(menuModel);
    menu.insert_action_group("dbusmenu", actionGroup);
    return menu;
  }

  return (
    <box className="topbar_systray" visible={bind(tray, "items").as(items => items.length > 0)} >
      {bind(tray, "items").as(items => items.map(item => {
        let menu: Gtk.Menu = createMenu(item.menu_model, item.action_group);

        return (
          <eventbox
            className = "topbar_systray_item"
            onClick={(self, event) => event.button === Astal.MouseButton.SECONDARY && menu?.popup_at_widget(self.parent, Gdk.Gravity.NORTH, Gdk.Gravity.SOUTH, null)}
          >
            <icon gicon={bind(item, "gicon")} />
          </eventbox>
        )
    }))}
  </box>
  )
}

export default function (gdk_monitor: Gdk.Monitor, hyprland_monitor: Hyprland.Monitor) {
  return <window
    className = "topbar"
    gdkmonitor = { gdk_monitor }
    exclusivity = { Astal.Exclusivity.EXCLUSIVE }
    anchor = { Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT }
  >
    <centerbox>
        <box hexpand halign={Gtk.Align.START}>
          <Distro_Logo/>
          <Workspaces hyprland_monitor = { hyprland_monitor } />
        </box>
        <box>
          <Time/>
        </box>
        <box hexpand halign = { Gtk.Align.END } >
          <SysTray/>
        </box>
    </centerbox>
  </window>
}
