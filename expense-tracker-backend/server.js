const dns = require("dns");
dns.setServers(["8.8.8.8", "8.8.4.4"]);

const express = require("express");
const cors = require("cors");
require("dotenv").config();

const connectDB = require("./config/db");

const authRoutes = require("./routes/authRoutes")

const expenseRoutes = require("./routes/expenseRoutes")

const walletRoutes = require("./routes/walletRoutes")

const dashboardRoutes = require("./routes/dashboardRoutes")

const analyticsRoutes = require("./routes/analyticsRoutes")

const app = express();

// connect database
connectDB();

// middleware
app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes)
app.use("/api/expenses", expenseRoutes)
app.use("/api/wallet", walletRoutes)
app.use("/api/dashboard", dashboardRoutes)
app.use("/api/analytics", analyticsRoutes)
// routes
app.get("/", (req, res) => {
  res.send("Expense Tracker API Running");
});

// future routes
// app.use("/api/auth", require("./routes/authRoutes"))
// app.use("/api/expenses", require("./routes/expenseRoutes"))
// app.use("/api/wallet", require("./routes/walletRoutes"))

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});