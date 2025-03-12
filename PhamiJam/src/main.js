import * as slint from "slint-ui";

let ui = slint.loadFile("ui/register.slint");
let register = new ui.RegisterScreen();

await register.run();
