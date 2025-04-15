import * as slint from "slint-ui";
import fs from "fs";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import path from "path";
import sound from "sound-play";
import { parseFile } from "music-metadata";

dotenv.config({ path: "../.env" });

let currentAudio = null;

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

    mainWindow.logout = (string) => {
        if (fs.existsSync("../auth_token.txt")) {
            fs.unlinkSync("../auth_token.txt");
            console.log("Logged out — token removed. 🔓");
        }
        string = "Logged out! 🔓";
        showToast(string, "green");
        mainWindow.globalActivePage = 1;
    };

    mainWindow.getUserInfo = async () => {
        const token = loadToken();
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.JWT_SECRET);
        } catch (err) {
            if (err.message === "jwt expired") {
                console.error("Token expired! 🔒");
                mainWindow.logout("Token expired! 🔒");
                return;
            }
            console.error("Invalid token:", err.message + " ❌");
        }

        mainWindow.globalUsername = decoded.username;
        return decoded;
    };

    mainWindow.createPlaylist = async (title, description) => {
        const token = loadToken();
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.JWT_SECRET);
        } catch (err) {
            if (err.message === "jwt expired") {
                console.error("Token expired! 🔒");
                mainWindow.logout("Token expired! 🔒");
                return;
            }
            console.error("Invalid token:", err.message + " ❌");
        }

        const payload = {
            title: title,
            userId: decoded.id,
            coverArt: "string",
            description: description,
        };

        try {
            const res = await fetch("http://localhost:3333/createPlaylist", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(payload),
            });

            const data = await res.json();

            if (!res.ok) {
                console.error(`Creation failed: ${data} ❌`);

                return showToast(data, "red");
            }

            return showToast("Success! ✅", "green");
        } catch (error) {
            console.error(`Connection error: ${error.message} ❌`);
        }
    };

    mainWindow.scan_files = async () => {
        const userDir = process.env.HOME || process.env.USERPROFILE;
        const musicDir = path.join(userDir, "Music");
        const mp3Files = [];

        const walk = (dir) => {
            try {
                const files = fs.readdirSync(dir);
                for (const file of files) {
                    const fullPath = path.join(dir, file);
                    const stat = fs.statSync(fullPath);
                    if (stat.isDirectory()) {
                        walk(fullPath);
                    } else if (file.toLowerCase().endsWith(".mp3")) {
                        mp3Files.push(fullPath);
                        //mp3Files.push(path.basename(fullPath));
                    }
                }
            } catch (e) {
                console.warn(`Skipping ${dir}:`, e.message);
            }
        };

        walk(musicDir);
        const rows = [];
        for (let i = 0; i < mp3Files.length; i++) {
            try {
                const metadata = await parseFile(mp3Files[i]);
                rows.push([{ text: metadata.common.title || "Unknown Title" }, { text: metadata.common.artist || "Unknown Artist" }]);
            } catch (err) {
                console.error("Error reading metadata:", err);
                rows.push([{ text: "Unknown Artist" }, { text: "Unknown Title" }]);
            }
        }
        showToast(`Found ${mp3Files.length} songs`, "green");

        mainWindow.rows = rows;

        mainWindow.globalMp3List = mp3Files;
    };

    mainWindow.play_song = async (songPath) => {
        console.log("Playing...");

        currentAudio = await sound.play(songPath, 0.1);
    };

    mainWindow.stop_song = async () => {
        console.log(await currentAudio);

        if (currentAudio && currentAudio.kill) {
            currentAudio.kill();
            console.log("Stopped");
        }
    };

    await mainWindow.run();
};

main();
