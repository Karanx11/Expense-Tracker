const mongoose = require("mongoose");
const Expense = require("../models/Expense");
const Wallet = require("../models/Wallet");
const MonthlyLimit = require("../models/MonthlyLimit");

exports.getDashboard = async (req, res) => {
  try {
    const userId = req.user;
    const userObjectId = new mongoose.Types.ObjectId(userId);

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    /// 💸 Total Expenses
    const totalExpensesData = await Expense.aggregate([
      {
        $match: {
          user: userObjectId,
          date: {
            $gte: startOfMonth,
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

    const totalExpenses = totalExpensesData[0]?.total || 0;

    /// 💰 Wallet
    const wallet = await Wallet.findOne({ user: userObjectId });
    const balance = wallet?.balance || 0;

    /// 🧾 Recent Transactions
    const recentTransactions = await Expense.find({ user: userObjectId })
      .sort({ date: -1 })
      .limit(5);

    /// 📊 Category Data
    const categoryData = await Expense.aggregate([
      {
        $match: {
          user: userObjectId,
          date: { $gte: startOfMonth, $lte: new Date() },
        },
      },
      {
        $group: {
          _id: "$category",
          total: { $sum: "$amount" },
        },
      },
    ]);

    /// 📈 Daily Data
    const dailyData = await Expense.aggregate([
      {
        $match: {
          user: userObjectId,
          date: { $gte: startOfMonth, $lte: new Date() },
        },
      },
      {
        $group: {
          _id: { $dayOfMonth: "$date" },
          total: { $sum: "$amount" },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    /// 💡 Monthly Limit
    const limitData = await MonthlyLimit.findOne({
      user: userObjectId,
      month: now.getMonth(),
      year: now.getFullYear(),
    });

    const limit = limitData?.limit || 0;
    const remaining = limit - totalExpenses;

    res.json({
      totalExpenses,
      balance,
      limit,
      remaining,
      recentTransactions,
      categoryData,
      dailyData,
    });

  } catch (err) {
    console.error("🔥 DASHBOARD ERROR:", err);
    res.status(500).json({ msg: "Dashboard error" });
  }
};