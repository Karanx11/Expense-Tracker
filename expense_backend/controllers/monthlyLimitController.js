const MonthlyLimit = require("../models/MonthlyLimit");

exports.setLimit = async (req, res) => {
  try {
    const { limit } = req.body;

    const now = new Date();

    const data = await MonthlyLimit.findOneAndUpdate(
      {
        user: req.user,
        month: now.getMonth(),
        year: now.getFullYear(),
      },
      { limit },
      { upsert: true, new: true }
    );

    res.json(data);
  } catch {
    res.status(500).json({ msg: "Error setting limit" });
  }
};