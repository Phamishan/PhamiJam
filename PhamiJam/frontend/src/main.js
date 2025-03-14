import * as slint from "slint-ui";

let ui = slint.loadFile("ui/main.slint");
let mainWindow = new ui.MainWindow();

await mainWindow.run();
