import GLib from "gi://GLib"

const datetime = Variable(GLib.DateTime.new_now_local(), {
    poll: [5000, () => GLib.DateTime.new_now_local()],
})

export default () => Widget.Button({
    class_name: 'topbar_submodules_datetime',
    cursor: "pointer",
    label: datetime.bind().as(t => t.format("%e %b  ·  %H:%M")
      .replace(/\b\w/g, c => c.toUpperCase()) // Capitalize first letter of the month
      .replace(/\./g, '') // Remove the period from date
      .replace(/^\s+|\s+$/g, '')), // Remove excessive spaces.
})
