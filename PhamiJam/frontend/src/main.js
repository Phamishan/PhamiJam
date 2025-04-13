import * as slint from "slint-ui";

const main = async () => {
    const { MainWindow } = await slint.loadFile("ui/main.slint");
    const mainWindow = MainWindow();

    mainWindow.register = async (username, password, email) => {
        console.log("Register button clicked!");
        const payload = {
            username: username,
            password: password,
            email: email,
        };
        try {
            const response = await fetch("http://localhost:3333/register", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(payload),
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            const data = await response.json();
            console.log(data);
            mainWindow.status = `✅ Registered as ${data.name || ui.name}`;
        } catch (err) {
            mainWindow.status = `❌ Error: ${err.message}`;
        }
        console.log("Payload:", payload);
    };

    await mainWindow.run();
};

main();
