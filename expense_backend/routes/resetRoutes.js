const express = require("express");
const router = express.Router();
const auth = require("../middleware/authMiddleware");

const mongoose = require("mongoose"); // ✅ ADD THIS
const Expense = require("../models/Expense");

router.delete("/reset", auth, async (req, res) => {
  try {
    console.log("USER:", req.user);

    const userId = new mongoose.Types.ObjectId(req.user); // ✅ FIX

    const result = await Expense.deleteMany({ user: userId });

    console.log("DELETED COUNT:", result.deletedCount);

    res.json({
      message: "All data reset successfully",
      totalExpenses: 0,
      balance: 0,
      remaining: 0,
      limit: 0,
      recentTransactions: []
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Reset failed" });
  }
});

module.exports = router;