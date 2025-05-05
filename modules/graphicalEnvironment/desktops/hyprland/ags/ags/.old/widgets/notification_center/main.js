const notifications = await Service.import("notifications")
const hyprland = await Service.import('hyprland')
import { lookUpIcon } from 'resource:///com/github/Aylur/ags/utils.js'

function NotificationIcon({ app_icon, app_entry, app_name, image }) {
  // Helper function to create the icon widget
  let createIcon = (icon) => Widget.Icon({ icon, class_name: 'notification_popups_icon', })

  // Determine which icon to use based on the available inputs
  let notification_icon = image ||
    (lookUpIcon(app_icon) && app_icon) ||
    (lookUpIcon(app_entry) && app_entry) ||
    (lookUpIcon(app_name) && app_name) ||
    (app_entry && lookUpIcon(app_entry.toLowerCase()) && app_entry.toLowerCase()) ||
    (app_name && lookUpIcon(app_name.toLowerCase()) && app_name.toLowerCase()) ||
    `${App.configDir}/assets/popup_notifications/dialog-information.svg`;

  return (createIcon(notification_icon))
}

export default Widget.Window({
  monitor: hyprland.active.monitor.bind('id'),
  name: "notification_center",
  anchor: [ "top" ],
  css: "background-color: transparent;",
  child: Widget.Box({
    class_name: "notification_center_mainbox",
    children: [
      Widget.Calendar({
        class_name: "notification_center_mainbox_calendar",
        showDayNames: false,
        showDetails: false,
        showHeading: true,
        showWeekNumbers: false,
      }),
    ],
  }),
})