const Expense = require("../models/Expense");

/// ADD EXPENSE
exports.addExpense = async (req, res) => {
  try {
    const { amount, category, paymentType, note, date } = req.body;

    if (!amount) {
      return res.status(400).json({ message: "Amount required" });
    }

    const expense = new Expense({
      userId: req.user.id,
      amount,
      category,
      paymentType,
      note,
      date: date || new Date(),
    });

    await expense.save();

    /// SOCKET EVENT
    const io = req.app.get("io");
    if (io) {
      io.emit("expenseAdded", expense);
    }

    res.status(201).json({
      message: "Expense added successfully",
      expense,
    });

  } catch (error) {
    console.error("Add Expense Error:", error);
    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};


/// GET EXPENSES
exports.getExpenses = async (req, res) => {
  try {

    const expenses = await Expense.find({
      userId: req.user.id,
    }).sort({ date: -1 });

    res.json(expenses);

  } catch (error) {
    console.error("Get Expenses Error:", error);

    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};


/// DELETE EXPENSE
exports.deleteExpense = async (req, res) => {
  try {

    const expense = await Expense.findOneAndDelete({
      _id: req.params.id,
      userId: req.user.id,
    });

    if (!expense) {
      return res.status(404).json({
        message: "Expense not found",
      });
    }

    res.json({
      message: "Expense deleted successfully",
    });

  } catch (error) {
    console.error("Delete Expense Error:", error);

    res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};