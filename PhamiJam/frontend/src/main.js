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

            const data = await response.json();

            if (!response.ok) {
                console.error(`❌ Registration failed: ${data}`);
                mainWindow.status = data; //needfix
            }

            console.log(data);
            console.log(`✅ Registered as ${data.username || mainWindow.username}`);

            mainWindow.errorMessage = "";

            console.log("Payload:", payload);
        } catch (error) {
            console.error(`❌ Connection error: ${error.message}`);
        }
    };

    await mainWindow.run();
};

main();
