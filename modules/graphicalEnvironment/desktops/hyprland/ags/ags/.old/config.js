import topbar from './widgets/topbar/main.js';
import notification_popups from './widgets/notification_popups/main.js';
//import notification_center from './widgets/notification_center/main.js';
import { monitorFile, execAsync } from 'resource:///com/github/Aylur/ags/utils.js';
const notifications = await Service.import("notifications")

const directoryToMonitor = `${App.configDir}/style/sass`;
const scssFilePath = `${App.configDir}/style/sass/main.scss`;
const cssMainFilePath = `${App.configDir}/style/index.css`;

execAsync(`sass --no-charset --no-source-map ${scssFilePath} ${cssMainFilePath}`)

monitorFile(directoryToMonitor, function() {
    execAsync(`sass --no-charset --no-source-map ${scssFilePath} ${cssMainFilePath}`)
        .catch(err => print(err));

    App.resetCss()
    App.applyCss(cssMainFilePath);
});

notifications.popupTimeout = 8000 // 12 seconds before they dissapear
notifications.forceTimeout = true
notifications.cacheActions = false
notifications.clearDelay = 100

App.config({
    windows: [
        ...topbar,
        notification_popups,
        //notification_center,
    ],
    style: `${App.configDir}/style/index.css`,
    iconTheme: 'Papirus-Dark'
})
