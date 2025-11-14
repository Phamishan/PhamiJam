const { PrismaClient } = require("@prisma/client");
const { spawnSync } = require("child_process");
const jwt = require("jsonwebtoken");
const express = require("express");
const dotenv = require("dotenv");
const bcrypt = require("bcrypt");
dotenv.config({ path: "../.env" });

const prisma = new PrismaClient();
const app = express();
app.use(express.json());

const checkYt = spawnSync("yt-dlp", ["--version"], { encoding: "utf8" });
if (checkYt.status !== 0) {
    console.error("yt-dlp not found or failed to run. stdout:", checkYt.stdout, "stderr:", checkYt.stderr);
} else {
    console.log("yt-dlp found:", checkYt.stdout.trim());
}

const port = process.env.PORT || 3333;

app.get("/yt-audio", (req, res) => {
    const q = req.query.query;
    if (!q) return res.status(400).json({ error: "missing query" });

    try {
        const searchTarget = `ytsearch1:${q}`;
        const info = spawnSync("yt-dlp", ["-j", "--no-warnings", "--no-playlist", searchTarget], { encoding: "utf8" });
        if (info.status !== 0) {
            return res.status(500).json({ error: "yt-dlp failed", stderr: info.stderr });
        }
        const meta = JSON.parse(info.stdout.split("\n").filter(Boolean)[0]);

        const urlProc = spawnSync("yt-dlp", ["--no-warnings", "--no-playlist", "--get-url", "-f", "bestaudio", meta.webpage_url], { encoding: "utf8" });
        if (urlProc.status !== 0) {
            return res.status(500).json({ error: "yt-dlp get-url failed", stderr: urlProc.stderr });
        }
        const directUrl = urlProc.stdout.trim().split("\n").pop();

        res.json({
            url: directUrl,
            title: meta.title,
            author: meta.uploader,
            duration_ms: Math.round((meta.duration || 0) * 1000),
            webpage_url: meta.webpage_url,
        });
    } catch (err) {
        res.status(500).json({ error: String(err) });
    }
});

app.post("/register", async (req, res) => {
    const { username, password, email } = req.body;

    if (!username || !password || !email) {
        return res.status(400).json({
            ok: false,
            message: "Please fill out all fields.",
        });
    }

    if (!email.includes("@")) {
        return res.status(400).json({
            ok: false,
            message: "Invalid email address.",
        });
    }

    const userInDb = await prisma.user.findFirst({ where: { email: email } });

    if (userInDb) {
        return res.status(400).json({
            ok: false,
            message: "User already exists.",
        });
    }

    bcrypt.hash(password, 10, async (err, hash) => {
        if (err) {
            return res.status(500).json({
                ok: false,
                message: "Error hashing password.",
            });
        }

        try {
            const user = await prisma.user.create({
                data: {
                    username: username,
                    password: hash,
                    email: email,
                    avatar: "string",
                },
            });
            return res.status(200).json({
                ok: true,
                message: "User created successfully.",
                user: user,
            });
        } catch (error) {
            return res.status(500).json({
                ok: false,
                message: "Error creating user.",
            });
        }
    });
});

app.post("/login", async (req, res) => {
    const { username, password } = req.body;
    console.log(req.body);
    if (!username || !password) {
        return res.status(400).json({
            ok: false,
            message: "Please fill out all fields.",
        });
    }

    const existingUser = await prisma.user.findFirst({
        where: {
            username: username,
        },
    });

    if (!existingUser) {
        return res.status(400).json({
            ok: false,
            message: "User not found.",
        });
    }

    bcrypt.compare(password, existingUser.password, function (err, result) {
        if (err) {
            return res.status(500).json({
                ok: false,
                message: "Error comparing password.",
            });
        }
        if (!result) {
            return res.status(400).json({
                ok: false,
                message: "Invalid credentials.",
            });
        }

        const token = jwt.sign({ id: existingUser.id, username: existingUser.username }, process.env.JWT_SECRET, {
            expiresIn: "1h",
        });

        return res.status(200).json({
            ok: true,
            message: "Login successful.",
            token: token,
        });
    });
});

app.get("/getUserInfo", async (req, res) => {
    const authHeader = req.headers["authorization"];
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ ok: false, message: "No token provided." });
    }
    const token = authHeader.split(" ")[1];
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const userInDb = await prisma.user.findFirst({ where: { id: decoded.id } });
        if (!userInDb) {
            return res.status(404).json({ ok: false, message: "User not found." });
        }
        const { password, ...userSafe } = userInDb;
        return res.status(200).json({ ok: true, user: userSafe });
    } catch (err) {
        return res.status(401).json({ ok: false, message: "Invalid or expired token." });
    }
});

app.post("/createPlaylist", async (req, res) => {
    // Require Authorization header with Bearer token
    const authHeader = req.headers["authorization"];
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ ok: false, message: "No token provided." });
    }
    const token = authHeader.split(" ")[1];
    let decoded;
    try {
        decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
        return res.status(401).json({ ok: false, message: "Invalid or expired token." });
    }

    const { title, coverArt, description } = req.body;
    if (!title || !coverArt || !description) {
        return res.status(400).json({
            ok: false,
            message: "Please fill out all required fields.",
        });
    }

    try {
        const playlist = await prisma.playlist.create({
            data: {
                title: title,
                userId: decoded.id,
                coverArt: coverArt,
                description: description,
            },
        });
        return res.status(200).json({
            ok: true,
            message: "Playlist created successfully.",
            playlist: playlist,
        });
    } catch (error) {
        return res.status(500).json({
            ok: false,
            message: "Error creating playlist.",
        });
    }
});

app.get("/getPlaylists", async (req, res) => {
    const authHeader = req.headers["authorization"];
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ ok: false, message: "No token provided." });
    }
    const token = authHeader.split(" ")[1];
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const playlists = await prisma.playlist.findMany({
            where: { userId: decoded.id },
            orderBy: { id: "asc" },
        });
        return res.status(200).json({ ok: true, playlists });
    } catch (err) {
        return res.status(401).json({ ok: false, message: "Invalid or expired token." });
    }
});

app.delete("/deletePlaylist/:id", async (req, res) => {
    const authHeader = req.headers["authorization"];
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ ok: false, message: "No token provided." });
    }
    const token = authHeader.split(" ")[1];
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const playlistId = Number(req.params.id);
        if (Number.isNaN(playlistId)) {
            return res.status(400).json({ ok: false, message: "Invalid id" });
        }

        const playlist = await prisma.playlist.findUnique({
            where: { id: playlistId },
        });

        if (!playlist || playlist.userId !== decoded.id) {
            return res.status(404).json({ ok: false, message: "Playlist not found or not owned." });
        }

        await prisma.playlist.delete({
            where: { id: playlistId },
        });

        return res.status(200).json({ ok: true, message: "Deleted" });
    } catch (err) {
        console.error("deletePlaylist error:", err);
        return res.status(401).json({ ok: false, message: "Invalid or expired token." });
    }
});

app.listen(port, () => console.log(`Server ready @ http://localhost:${port}`));
