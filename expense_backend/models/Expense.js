const mongoose = require("mongoose");

const expenseSchema = new mongoose.Schema({

  userId: String,

  amount: Number,

  category: String,

  note: String,

  date: {
    type: Date,
    default: Date.now
  }

});

module.exports = mongoose.model("Expense", expenseSchema);