const mongoose = require("mongoose");
const Expense = require("../models/Expense");
const Wallet = require("../models/Wallet");
const MonthlyLimit = require("../models/MonthlyLimit");

/// ➕ ADD EXPENSE
const addExpense = async (req, res) => {
  try {
    const { amount, category, note, date } = req.body;

    const userId = req.user;
    const userObjectId = new mongoose.Types.ObjectId(userId);

    /// 🧾 Create Expense
    const expense = await Expense.create({
      user: userObjectId,
      amount,
      category,
      note,
      date: date || new Date(),
    });

    /// 💰 Wallet Update
    let wallet = await Wallet.findOne({ user: userObjectId });

    if (!wallet) {
      wallet = await Wallet.create({
        user: userObjectId,
        balance: 0,
      });
    }

    wallet.balance -= amount;
    await wallet.save();

    /// 📅 Monthly Limit Check
    const now = new Date();

    const limitData = await MonthlyLimit.findOne({
      user: userObjectId,
      month: now.getMonth(),
      year: now.getFullYear(),
    });

    let totalSpent = 0;
    let remaining = 0;
    let alert = null;

    if (limitData) {
      /// 🔥 Calculate Total Expenses THIS MONTH
      const expenses = await Expense.aggregate([
        {
          $match: {
            user: userObjectId,
            date: {
              $gte: new Date(now.getFullYear(), now.getMonth(), 1),
              $lte: new Date(),
            },
          },
        },
        {
          $group: {
            _id: null,
            total: { $sum: "$amount" },
          },
        },
      ]);

      totalSpent = expenses[0]?.total || 0;
      remaining = limitData.limit - totalSpent;

      const percentUsed = totalSpent / limitData.limit;

      /// 🚨 Smart Alerts
      if (percentUsed >= 1) {
        alert = "🚨 Budget exceeded!";
      } else if (percentUsed >= 0.8) {
        alert = "⚠️ 80% budget used";
      } else if (percentUsed >= 0.5) {
        alert = "📊 50% budget used";
      }
    }

    /// ✅ RESPONSE
    res.json({
      expense,
      totalSpent,
      remaining,
      alert,
    });

  } catch (err) {
    console.error("ADD EXPENSE ERROR:", err);
    res.status(500).json({ msg: "Error adding expense" });
  }
};


/// 📥 GET ALL EXPENSES
const getExpenses = async (req, res) => {
  try {
    const userId = req.user;
    const userObjectId = new mongoose.Types.ObjectId(userId);

    const expenses = await Expense.find({ user: userObjectId })
      .sort({ date: -1 });

    res.json(expenses);

  } catch (err) {
    console.error("GET EXPENSES ERROR:", err);
    res.status(500).json({ msg: "Error fetching expenses" });
  }
};


/// ❌ DELETE EXPENSE (FIXED)
const deleteExpense = async (req, res) => {
  try {
    const { id } = req.params;

    const expense = await Expense.findById(id);

    if (!expense) {
      return res.status(404).json({ msg: "Expense not found" });
    }

    const userObjectId = expense.user;

    /// 🗑️ DELETE EXPENSE
    await Expense.findByIdAndDelete(id);

    /// 💰 RESTORE WALLET BALANCE
    const wallet = await Wallet.findOne({ user: userObjectId });

    if (wallet) {
      wallet.balance += expense.amount; // 🔥 add back money
      await wallet.save();
    }

    /// 📅 RECALCULATE MONTHLY DATA
    const now = new Date();

    const limitData = await MonthlyLimit.findOne({
      user: userObjectId,
      month: now.getMonth(),
      year: now.getFullYear(),
    });

    let totalSpent = 0;
    let remaining = 0;

    if (limitData) {
      const expenses = await Expense.aggregate([
        {
          $match: {
            user: userObjectId,
            date: {
              $gte: new Date(now.getFullYear(), now.getMonth(), 1),
              $lte: new Date(),
            },
          },
        },
        {
          $group: {
            _id: null,
            total: { $sum: "$amount" },
          },
        },
      ]);

      totalSpent = expenses[0]?.total || 0;
      remaining = limitData.limit - totalSpent;
    }

    res.json({
      msg: "Expense deleted successfully",
      totalSpent,
      remaining,
    });

  } catch (err) {
    console.error("DELETE ERROR:", err);
    res.status(500).json({ msg: "Error deleting expense" });
  }
};


/// 🔥 EXPORT (VERY IMPORTANT)
module.exports = {
  addExpense,
  getExpenses,
  deleteExpense,
};