const Expense = require("../models/Expense");

exports.addExpense = async (req, res) => {

  try {

    const { amount, category, paymentType, note, date } = req.body;

    const expense = new Expense({
      userId: req.user.id,
      amount,
      category,
      paymentType,
      note,
      date
    });

    await expense.save();
     const io = req.app.get("io");

    io.emit("expenseAdded", expense);

    res.json({ message: "Expense added", expense });

  } catch (error) {

    res.status(500).json({ error: error.message });

  }

};

exports.getExpenses = async (req, res) => {

  try {

    const expenses = await Expense.find({
      userId: req.user.id
    }).sort({ date: -1 });

    res.json(expenses);

  } catch (error) {

    res.status(500).json({ error: error.message });

  }

};

exports.deleteExpense = async (req, res) => {

  try {

    await Expense.findByIdAndDelete(req.params.id);

    res.json({ message: "Expense deleted" });

  } catch (error) {

    res.status(500).json({ error: error.message });

  }

};