const mongoose = require("mongoose");

const monthlyLimitSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: "User" },

    limit: { type: Number, required: true },

    month: { type: Number }, // 0-11
    year: { type: Number },
  },
  { timestamps: true }
);

module.exports = mongoose.model("MonthlyLimit", monthlyLimitSchema);

