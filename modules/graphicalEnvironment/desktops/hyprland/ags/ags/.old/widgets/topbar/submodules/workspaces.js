const hyprland = await Service.import('hyprland')

const dispatch = ws => hyprland.messageAsync(`dispatch workspace ${ws}`);

const create_workspace_button = ws => {
    return Widget.Button({
        attribute: ws,
        onClicked: () => dispatch(`${ws.id}`),
        child: Widget.Label({
            label: `${ws.id}`,
            hpack: 'center',
            vpack: 'center',
        })
    })
}

export default (mon) => Widget.Box({
    class_name: 'topbar_submodules_workspaces',
    child: Widget.EventBox({
        cursor: "pointer",
        onScrollUp: () => dispatch('m-1'),
        onScrollDown: () => dispatch('m+1'),
        child: Widget.Box({
            class_name: 'topbar_submodules_workspaces_box',
            attribute: mon,
            spacing: 0,
            children: hyprland.workspaces.filter( ws => ws.monitorID === mon.id).map(ws => create_workspace_button(ws)).sort((a, b) => a.attribute.name - b.attribute.name),
        }).hook(hyprland, (self) => {
            let workspaces_on_same_screen = hyprland.workspaces.filter( ws => ws.monitorID === self.attribute.id)
            let obsolete_workspaces = self.children.filter(child => !workspaces_on_same_screen.map(ws => ws.name).includes(child.attribute.name))
            let missing_workspaces = workspaces_on_same_screen.filter(ws => !self.children.map(child => child.attribute.name).includes(ws.name))
    
            // delete obsolete workspace indicators 
            obsolete_workspaces.forEach(child => {
                child.destroy()
                self.children = self.children.sort((a, b) => a.attribute.name - b.attribute.name)
            })
    
            // create new workspaces
            missing_workspaces.forEach(ws => {
                let widget = create_workspace_button(ws)
                self.children = [widget, ...self.children].sort((a, b) => a.attribute.name - b.attribute.name)
            })
    
            let active_workspace_name = hyprland.active.workspace.name
            self.children.forEach((child, index) => {
                // Update the label with the index, starting at 1
                child.child.label = (index + 1).toString();
            
                // toggle classes
                child.toggleClassName("active", child.attribute.name === active_workspace_name);
                child.toggleClassName("occupied", (workspaces_on_same_screen.find(workspace => workspace.name === child.attribute.name).windows || 0) > 0);
            });
        })
    })
})
