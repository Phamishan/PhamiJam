const { PrismaClient } = require("@prisma/client");
const jwt = require("jsonwebtoken");
const express = require("express");
const dotenv = require("dotenv");
const bcrypt = require("bcrypt");
dotenv.config({ path: "../.env" });

const prisma = new PrismaClient();
const app = express();
app.use(express.json());

const port = process.env.PORT || 3333;

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
    const { title, userId, coverArt, description } = req.body;

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
                userId: userId,
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

app.listen(port, () => console.log(`Server ready @ http://localhost:${port}`));
