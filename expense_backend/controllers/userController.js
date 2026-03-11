const User = require("../models/User");

exports.getProfile = async (req, res) => {

  try {

    const user = await User.findById(req.user.id).select("-password");

    res.json(user);

  } catch (error) {

    res.status(500).json({ error: error.message });

  }

};

exports.deleteAccount = async (req, res) => {

  try {

    await User.findByIdAndDelete(req.user.id);

    res.json({ message: "Account deleted" });

  } catch (error) {

    res.status(500).json({ error: error.message });

  }

};