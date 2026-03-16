const express = require("express");
const router = express.Router();

const Expense = require("../models/Expense");
const verifyFirebaseToken = require("../middleware/firebaseAuth");

/// ADD EXPENSE
router.post("/add", verifyFirebaseToken, async (req, res) => {

  try {

    const expense = new Expense({
      userId: req.user.uid,
      amount: req.body.amount,
      category: req.body.category,
      note: req.body.note
    });

    await expense.save();

    res.status(200).json(expense);

  } catch (error) {

    console.error(error);
    res.status(500).json({ message: "Error adding expense" });

  }

});

/// GET ALL EXPENSES
router.get("/all", verifyFirebaseToken, async (req, res) => {

  try {

    const expenses = await Expense.find({
      userId: req.user.uid
    }).sort({ date: -1 });

    res.status(200).json(expenses);

  } catch (error) {

    res.status(500).json({ message: "Error fetching expenses" });

  }

});

/// DELETE EXPENSE
router.delete("/:id", verifyFirebaseToken, async (req, res) => {

  try {

    await Expense.findByIdAndDelete(req.params.id);

    res.status(200).json({ message: "Expense deleted" });

  } catch (error) {

    res.status(500).json({ message: "Error deleting expense" });

  }

});

module.exports = router;