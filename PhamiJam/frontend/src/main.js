import * as slint from "slint-ui";
import fs from "fs";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
dotenv.config({ path: "../.env" });

const saveToken = (token) => {
    fs.writeFileSync("../auth_token.txt", token, "utf-8");
    console.log("Auth token saved. ✅");
};

const loadToken = () => {
    try {
        if (fs.existsSync("../auth_token.txt")) {
            const token = fs.readFileSync("../auth_token.txt", "utf-8");
            return token;
        } else {
            return "";
        }
    } catch (err) {
        console.error("Failed to load token:", err + " ❌");
        return "";
    }
};

const main = async () => {
    const { MainWindow } = await slint.loadFile("ui/main.slint");
    const mainWindow = MainWindow();

    const token = loadToken();
    if (token) {
        mainWindow.globalActivePage = 2;
    } else {
        mainWindow.globalActivePage = 0;
    }

    const showToast = (message, color = "#333", duration = 3000) => {
        mainWindow.toastMessage = message;
        mainWindow.toastColor = color;
        mainWindow.showToast = true;

        setTimeout(() => {
            mainWindow.showToast = false;
        }, duration);
    };

    mainWindow.register = async (username, password, email) => {
        const payload = {
            username: username,
            password: password,
            email: email,
        };

        try {
            const res = await fetch("http://localhost:3333/register", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(payload),
            });

            const data = await res.json();

            if (!res.ok) {
                console.error(`Registration failed: ${data} ❌`);
                return showToast(data, "red");
            }

            mainWindow.globalActivePage = 1;
            return showToast("Registered! ✅", "green");
        } catch (error) {
            console.error(`Connection error: ${error.message} ❌`);
        }
    };

    mainWindow.login = async (email, password) => {
        const payload = {
            email: email,
            password: password,
        };

        try {
            const res = await fetch("http://localhost:3333/login", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(payload),
            });

            const data = await res.json();

            if (!res.ok) {
                console.error(`Login failed: ${data} ❌`);

                return showToast(data, "red");
            }

            saveToken(data);
            mainWindow.globalActivePage = 2;
            return showToast("Success! ✅", "green");
        } catch (error) {
            console.error(`Connection error: ${error.message} ❌`);
        }
    };

    mainWindow.logout = () => {
        if (fs.existsSync("../auth_token.txt")) {
            fs.unlinkSync("../auth_token.txt");
            console.log("Logged out — token removed. 🔓");
        }

        showToast("Logged out! 🔓", "green");
        mainWindow.globalActivePage = 1;
    };

    mainWindow.getUserInfo = async () => {
        const token = loadToken();
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.JWT_SECRET);
        } catch (err) {
            console.error("Invalid token:", err.message + " ❌");
        }

        mainWindow.globalUsername = decoded.username;
        return;
    };

    await mainWindow.run();
};

main();
