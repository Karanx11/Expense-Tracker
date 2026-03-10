const Expense = require("../models/Expense")

// Monthly expenses
exports.monthlyExpenses = async (req, res) => {

  try {

    const data = await Expense.aggregate([
      {
        $match: { user: req.user.id }
      },
      {
        $group: {
          _id: { $month: "$date" },
          total: { $sum: "$amount" }
        }
      },
      {
        $sort: { "_id": 1 }
      }
    ])

    res.json(data)

  } catch (error) {
    res.status(500).json({ error: error.message })
  }

}


// Category Spending
exports.categoryExpenses = async (req, res) => {

  try {

    const data = await Expense.aggregate([
      {
        $match: { user: req.user.id }
      },
      {
        $group: {
          _id: "$category",
          total: { $sum: "$amount" }
        }
      }
    ])

    res.json(data)

  } catch (error) {
    res.status(500).json({ error: error.message })
  }

}


// Weekly Spending
exports.weeklyExpenses = async (req, res) => {

  try {

    const data = await Expense.aggregate([
      {
        $match: { user: req.user.id }
      },
      {
        $group: {
          _id: { $dayOfWeek: "$date" },
          total: { $sum: "$amount" }
        }
      }
    ])

    res.json(data)

  } catch (error) {
    res.status(500).json({ error: error.message })
  }

}