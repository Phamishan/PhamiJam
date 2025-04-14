const { PrismaClient } = require("@prisma/client");
const jwt = require("jsonwebtoken");
const express = require("express");
const dotenv = require("dotenv");
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
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json("Please fill out all required fields.");
    }

    const checkUser = await prisma.user.findFirst({
        where: {
            AND: [{ email: email }, { password: password }],
        },
    });

    if (!checkUser) {
        return res.status(400).json("Invalid credentials.");
    }

    const getUsername = await prisma.user.findFirst({
        where: { email: email },
    });

    const token = jwt.sign({ id: checkUser.id, username: getUsername.username }, process.env.JWT_SECRET, {
        expiresIn: "1h",
    });

    return res.status(200).json(token);
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

app.listen(port, () => console.log(`Server ready @ http://localhost:${port}`));
