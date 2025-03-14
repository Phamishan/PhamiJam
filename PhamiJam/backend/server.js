const { PrismaClient } = require("@prisma/client");
const express = require("express");
const dotenv = require("dotenv");
dotenv.config();

const prisma = new PrismaClient();
const app = express();
app.use(express.json());

const port = process.env.PORT || 3333;

app.post("/register", async (req, res) => {
    const { username, password, email } = req.body;

    if (!username || !password || !email) {
        return res.status(400).json("Please fill out all required fields.");
    }

    const userInDb = await prisma.user.findFirst({ where: { email: email } });

    if (userInDb) {
        return res.status(400).json("User already exists.");
    }

    const user = await prisma.user.create({
        data: {
            username: username,
            password: password,
            email: email,
        },
    });
    return res.status(200).json(user);
});

app.post("/login", async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json("Please fill out all required fields.");
    }

    const checkUsername = await prisma.user.findFirst({ where: { username: username } });
    const checkPassword = await prisma.user.findFirst({ where: { password: password } });

    if (checkUsername && checkPassword) {
        return res.status(200).json("Logged in.");
    } else {
        return res.status(400).json("Invalid credentials.");
    }
});

app.listen(port, () => console.log(`Server ready @ http://localhost:${port}`));
