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
        return res.status(400).json("Please fill out all required fields.");
    }

    if (!email.includes("@")) {
        return res.status(400).json("Invalid email address.");
    }

    const userInDb = await prisma.user.findFirst({ where: { email: email } });

    if (userInDb) {
        return res.status(400).json("User already exists.");
    }

    bcrypt.hash(password, 10, async (err, hash) => {
        if (err) {
            return res.status(500).json("Error hashing password.");
        }

        const user = await prisma.user.create({
            data: {
                username: username,
                password: hash,
                email: email,
                avatar: "string",
            },
        });
        return res.status(200).json(user);
    });
});

app.post("/login", async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json("Please fill out all required fields.");
    }

    const existingUser = await prisma.user.findFirst({
        where: {
            email: email,
        },
    });

    if (!existingUser) {
        return res.status(400).json("User not found.");
    }

    bcrypt.compare(password, existingUser.password, function (err, result) {
        if (err) {
            return res.status(500).json("Error comparing password.");
        }
        if (!result) {
            return res.status(400).json("Invalid credentials.");
        }

        const token = jwt.sign({ id: existingUser.id, username: existingUser.username }, process.env.JWT_SECRET, {
            expiresIn: "1h",
        });

        return res.status(200).json(token);
    });
});

/*
app.post("/getUserInfo", async (req, res) => {
    const { id } = req.body;

    const userInDb = await prisma.user.findFirst({ where: { id: id } });

    if (!userInDb) {
        return res.status(400).json("User not found.");
    }

    return res.status(200).json(userInDb);
});
*/

app.post("/createPlaylist", async (req, res) => {
    const { title, userId, coverArt, description } = req.body;

    if (!title || !coverArt || !description) {
        return res.status(400).json("Please fill out all required fields.");
    }

    const playlist = await prisma.playlist.create({
        data: {
            title: title,
            userId: userId,
            coverArt: coverArt,
            description: description,
        },
    });
    return res.status(200).json(playlist);
});

app.listen(port, () => console.log(`Server ready @ http://localhost:${port}`));
