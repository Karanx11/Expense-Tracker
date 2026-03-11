const mongoose = require("mongoose");

const expenseSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  },
  amount: Number,
  category: String,
  paymentType: String,
  note: String,
  date: Date,
});

module.exports = mongoose.model("Expense", expenseSchema);