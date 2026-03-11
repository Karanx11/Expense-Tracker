const dns = require("dns");
dns.setServers(["8.8.8.8", "8.8.4.4"]);

require("dotenv").config();

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http");
const { Server } = require("socket.io");

const app = express();

/// CREATE HTTP SERVER
const server = http.createServer(app);

/// SOCKET.IO SETUP
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

/// MAKE SOCKET ACCESSIBLE IN CONTROLLERS
app.set("io", io);

/// MIDDLEWARE
app.use(cors());
app.use(express.json());

/// ROUTES
const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const expenseRoutes = require("./routes/expenseRoutes");

app.use("/api/auth", authRoutes);
app.use("/api/user", userRoutes);
app.use("/api/expense", expenseRoutes);

/// SOCKET CONNECTION
io.on("connection", (socket) => {

  console.log("User connected:", socket.id);

  socket.on("disconnect", () => {
    console.log("User disconnected:", socket.id);
  });

});

/// DATABASE CONNECTION
mongoose.connect(process.env.MONGO_URI)
.then(() => {

  console.log("MongoDB Connected");

})
.catch((err) => {

  console.error("MongoDB Error:", err);

});

/// ROOT ROUTE
app.get("/", (req, res) => {
  res.send("Expense Tracker API Running");
});

/// START SERVER
const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});