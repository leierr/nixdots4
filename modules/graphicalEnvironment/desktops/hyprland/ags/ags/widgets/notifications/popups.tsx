import { Astal, Gtk } from "astal/gtk3"
import Notifd from "gi://AstalNotifd"
import Pango from "gi://Pango?version=1.0"

const notifd = Notifd.get_default()

export default function (n: Notifd.AstalNotifdAction) {
  // find desktop icon
  let app_icon =
    !!Astal.Icon.lookup_icon(n.appIcon || "") && n.appIcon ||
    !!Astal.Icon.lookup_icon(n.desktopEntry || "") && n.desktopEntry ||
    !!Astal.Icon.lookup_icon(n.app_name || "") && n.app_name ||
    !!Astal.Icon.lookup_icon(n.app_name && n.app_name.toLowerCase() || "") && n.app_name.toLowerCase() ||
    !!Astal.Icon.lookup_icon(n.desktopEntry && n.desktopEntry.toLowerCase() || "") && n.desktopEntry.toLowerCase() ||
    !!Astal.Icon.lookup_icon("image-missing") && "image-missing" || null

  return (
    <box className="notification_popups_instance" >
      <eventbox
        onClick={(_, event) => {
          if (event.button === Astal.MouseButton.PRIMARY) {
            if (n.get_actions().length === 1) { n.invoke(n.actions[0].id) ; setTimeout(() => { if (notifd.get_notification(n.id)) n.dismiss()}, 500) }
            if (n.get_actions().length !== 1) n.dismiss()
          }
        }}
      >
        <box vertical >
          <box className="notification_popups_instance_title_box" hexpand>
            { app_icon !== null && <icon icon={app_icon} /> }
            <label label = { n.app_name.replace(/\b\w/g, (c: string) => c.toUpperCase()) }/>
          </box>
          <box vertical className="notification_popups_instance_text_box">
            <label
              xalign = {0}
              lines = {1}
              wrap
              wrapMode={Pango.WrapMode.WORD_CHAR}
              truncate
              halign={Gtk.Align.START}
              justify={Gtk.Justification.LEFT}
            >
              {n.summary}
            </label>
            <label
              xalign = {0}
              lines = {2}
              wrap
              wrapMode={Pango.WrapMode.WORD_CHAR}
              truncate
              halign={Gtk.Align.START}
              justify={Gtk.Justification.LEFT}
            >
              {n.body}
            </label>
          </box>
          {n.get_actions().length >= 2 && n.get_actions().length < 4 &&
              <box className="notification_popups_instance_actions_container" >
                {n.get_actions().map(({ label, id }: { label: string; id: number }) => (
                  <button
                    hexpand
                    cursor = { 'pointer' }
                    onClicked = { () => { n.invoke(id) ; setTimeout(() => { if (notifd.get_notification(n.id)) n.dismiss()}, 400) } }
                  >
                    <label
                      hexpand
                      label = { label }
                      halign = { Gtk.Align.CENTER }
                    />
                  </button>
                ))}
              </box>
            }
        </box>
      </eventbox>
    </box>
  )
}
