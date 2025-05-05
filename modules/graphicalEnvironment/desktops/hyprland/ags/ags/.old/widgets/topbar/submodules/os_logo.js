import GLib from "gi://GLib";
let distro_icon = `distributor-logo-${GLib.get_os_info('ID')}`

export default () => Widget.Button({
    class_name: 'topbar_submodules_os_logo',
    hpack: 'center',
    vpack: 'center',
    child: Widget.Icon({
        icon: distro_icon,
    })
})
