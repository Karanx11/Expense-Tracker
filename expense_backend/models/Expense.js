const mongoose = require("mongoose");

const expenseSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: "User" },

    amount: { type: Number, required: true },

    category: {
      type: String,
      enum: ["Food", "Travel", "Shopping", "Bills", "Others"],
      default: "Others",
    },

    note: String,

    date: {
  type: Date,
  required: true,
  default: Date.now,
},
  },
  { timestamps: true }
);

module.exports = mongoose.model("Expense", expenseSchema);