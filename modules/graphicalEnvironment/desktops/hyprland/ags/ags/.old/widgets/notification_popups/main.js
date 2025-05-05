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

function NotificationLabels({ summary, body }) {
  if (summary || body) {
    let notification_summary = summary && Widget.Label({
      class_name: 'notification_popups_label_summary',
      truncate: "end",
      justification: "left",
      xalign: 0,
      lines: 1,
      hpack: "start",
      wrap: true,
      label: summary,
    })

    let notification_body = body && Widget.Label({
      class_name: 'notification_popups_label_body',
      truncate: "end",
      justification: "left",
      xalign: 0,
      lines: 2,
      hpack: "start",
      wrap: true,
      label: body
    })

    return Widget.Box({
      vertical: true,
      vpack: "center",
      class_name: 'notification_popups_summary_body_container',
      children: [
        notification_summary,
        notification_body,
      ]
    })
  }
}

function NotificationActions(n) {
  function create_action_button(action) {
    if (action.id && action.label)
      return Widget.Button({
        child: Widget.Label({
          truncate: "end",
          lines: 1,
          label: action.label,
        }),
        class_name: 'notification_popups_action_button',
        cursor: "pointer",
        onPrimaryClickRelease: () => n.invoke(action.id)
      })
  }

  if (n.actions && n.actions.length >= 2) {
    return Widget.Box({
      class_name: 'notification_popups_action_button_container',
      homogeneous: true,
      children: n.actions.map(action => create_action_button(action)),
    })
  }
}

function Notification(n) {
  let capitalize = (str) => str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();

  // notification itself
  return ( n.app_name && n.id && n.urgency ) && Widget.Box({
    attribute: { id: n.id },
    // Eventbox for single action or dismiss
    child: Widget.EventBox({
      onPrimaryClickRelease: (
        (n.actions.length === 1 && (() => { n.invoke(n.actions[0].id); })) ||
        (n.actions.length === 0 && (() => { n.dismiss(); })) ||
        null
      ),
      child: Widget.Box({
        vertical: true,
        class_names: [
          "notification_popups_container",
          (n.urgency === "critical" ? "notification_popup_inside_container_urgency_critical" : "")
        ],
        children: [
          // topbar
          Widget.Box({
            class_name: "notification_popups_topbar_container",
            children: [
              // title
              Widget.Label({
                class_name: "notification_popups_label_title",
                label: capitalize(n.app_name)
              }),
            ],
          }),
          // body
          Widget.Box({
            class_name: "notification_popups_body_container",
            vertical: true,
            children: [
              Widget.Box({
                children: [
                  NotificationIcon(n),
                  NotificationLabels(n),
                ],
              }),
              NotificationActions(n),
            ],
          }),
        ],
      })
    })
  })
}

export default Widget.Window({
  monitor: hyprland.active.monitor.bind('id'),
  name: "notification_popups",
  anchor: ["top", "right"],
  css: "background-color: transparent;",
  child: Widget.Box({
    vertical: true,
    hpack: "center",
    class_name: 'notification_popups_widget_container',
    children: []
  }).hook(notifications, (self) => {
    let missing_notifications = notifications.popups.filter(active => !self.children.find(child => child.attribute.id === active.id) )
    let dismissed_notifications = self.children.filter(child => !notifications.popups.find(active => active.id === child.attribute.id) );

    dismissed_notifications.forEach(child => { child.destroy() })
    missing_notifications.forEach(n => { self.children = [Notification(n), ...self.children] })

    self.toggleClassName('has-children', self.children.length != 0)
  }),
})
