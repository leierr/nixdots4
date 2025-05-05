const systemtray = await Service.import('systemtray')

const systrayitem = item => Widget.Box({
  attribute: { id: item.id },
  child: Widget.EventBox({
    onPrimaryClick: (_, event) => {item.secondaryActivate(event)},
    onSecondaryClick: (_, event) => {item.openMenu(event)},
    child: Widget.Icon({
        class_name: 'topbar_submodules_systray_item',
        tooltipMarkup: item.bind('tooltip_markup'),
    }).bind('icon', item, 'icon'),
  }),
})

export default () => Widget.Box({
    class_name: 'topbar_submodules_systray',
    visible: false, // DEFAULT
    children: []
}).hook(systemtray, (self) => {
    let missing_systray_items = systemtray.items.filter(item => !self.children.find(child => child.attribute.id === item.id));
    let dismissed_systray_items = self.children.filter(child => !systemtray.items.find(item => item.id === child.attribute.id));
    
    dismissed_systray_items.forEach(child => { child.destroy() }) // Destroy removed items
    missing_systray_items.forEach(item => { self.children = [systrayitem(item), ...self.children] }) // Add missing items

    self.visible = self.children.length !== 0;
})