import workspaces from './submodules/workspaces.js'
import oslogo from './submodules/os_logo.js'
import datetime from './submodules/datetime.js'
import { cpu_monitor, ram_monitor } from './submodules/sysmetrics.js'
import systray from './submodules/systray.js'
import weather from './submodules/weather.js'

// import battery from './submodules/battery/battery.js'

const hyprland = await Service.import('hyprland')

// layout of the bar
const Left = (items) => Widget.Box({ vpack: 'center', hexpand: true, children: items });
const Center = (items) => Widget.Box({ vpack: 'center', children: items });
const Right = (items) => Widget.Box({ hpack: 'end', vpack: 'center', hexpand: true, children: items });

// list of bars per monitor in hyprland session
export default hyprland.monitors.map(mon =>
    Widget.Window({
        name: `bar-${mon.id}`, // name has to be unique
        className: 'topbar',
        monitor: mon.id,
        anchor: ['top', 'left', 'right'],
        exclusivity: 'exclusive',
        visible: true,
        child: Widget.CenterBox({
            className: 'topbar_container',
            start_widget: Left([
                oslogo(), 
                workspaces(mon),
            ]),
            center_widget: Center([
                datetime(),
            ]),
            end_widget: Right([
                cpu_monitor(),
                ram_monitor(),
                weather(),
                systray(),
            ]),
        }),
    })
)
