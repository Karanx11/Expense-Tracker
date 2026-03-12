const express = require("express");
const router = express.Router();

const {
  addExpense,
  getExpenses,
  deleteExpense,
} = require("../controllers/expenseController");

const authMiddleware = require("../middleware/authMiddleware");

router.post("/add", authMiddleware, addExpense);
router.get("/list", authMiddleware, getExpenses);
router.delete("/:id", authMiddleware, deleteExpense);

module.exports = router;