const Expense = require("../models/Expense")
const Wallet = require("../models/Wallet")

exports.getDashboard = async (req, res) => {

  try {

    const userId = req.user.id

    // get expenses
    const expenses = await Expense.find({ user: userId })

    // calculate total expenses
    const totalExpenses = expenses.reduce((sum, exp) => sum + exp.amount, 0)

    // wallet balance
    const wallet = await Wallet.findOne({ user: userId })

    const walletBalance = wallet ? wallet.balance : 0

    // current balance
    const balance = walletBalance - totalExpenses

    // recent transactions
    const recentTransactions = await Expense
      .find({ user: userId })
      .sort({ date: -1 })
      .limit(5)

    res.json({
      walletBalance,
      totalExpenses,
      balance,
      limit: walletLimit,
      recentTransactions
    })

  } catch (error) {

    res.status(500).json({ error: error.message })

  }

}