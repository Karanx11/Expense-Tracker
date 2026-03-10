const Expense = require("../models/Expense")

// Add Expense
exports.addExpense = async (req, res) => {

  try {

    const { title, amount, category, note, date } = req.body

    const userId = req.user.id

    const wallet = await Wallet.findOne({ user: userId })

    const limit = wallet?.monthlyLimit || 0

    const expenses = await Expense.find({ user: userId })

    const totalSpent = expenses.reduce((sum, exp) => sum + exp.amount, 0)

    const newTotal = totalSpent + amount

    let warning = null

    if (limit > 0) {

      const percent = newTotal / limit

      if (percent >= 1) {
        warning = "LIMIT_EXCEEDED"
      }

      else if (percent >= 0.95) {
        warning = "CRITICAL_LIMIT"
      }

      else if (percent >= 0.8) {
        warning = "WARNING_LIMIT"
      }

    }

    const expense = await Expense.create({
      user: userId,
      title,
      amount,
      category,
      note,
      date
    })

    res.json({
      expense,
      warning
    })

  } catch (error) {

    res.status(500).json({ error: error.message })

  }

}

// Get All Expenses
exports.getExpenses = async (req, res) => {

  try {

    const expenses = await Expense.find({ user: req.user.id }).sort({ date: -1 })

    res.json(expenses)

  } catch (error) {

    res.status(500).json({ error: error.message })

  }

}


// Update Expense
exports.updateExpense = async (req, res) => {

  try {

    const expense = await Expense.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    )

    res.json(expense)

  } catch (error) {

    res.status(500).json({ error: error.message })

  }

}


// Delete Expense
exports.deleteExpense = async (req, res) => {

  try {

    await Expense.findByIdAndDelete(req.params.id)

    res.json({ message: "Expense deleted" })

  } catch (error) {

    res.status(500).json({ error: error.message })

  }

}