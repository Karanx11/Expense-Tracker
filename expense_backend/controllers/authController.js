const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const sendEmail = require("../utils/sendEmail");


// SIGNUP
exports.signup = async (req, res) => {
  try {

    const { name, email, phone, password } = req.body;

    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(400).json({ message: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    // generate OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    console.log("Signup email:", email);
    console.log("Generated OTP:", otp);

    const user = new User({
      name,
      email,
      phone,
      password: hashedPassword,
      otp
    });

    await user.save();

    // send email
    await sendEmail(email, otp);

    res.json({ message: "OTP sent to email" });

  } catch (error) {
    console.log("Signup Error:", error);
    res.status(500).json({ error: error.message });
  }
};


// LOGIN
exports.login = async (req, res) => {
  try {

    const { email, password } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(400).json({ message: "User not found" });
    }

    const match = await bcrypt.compare(password, user.password);

    if (!match) {
      return res.status(400).json({ message: "Invalid password" });
    }

    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      token,
      user: {
        name: user.name,
        email: user.email,
        phone: user.phone
      }
    });

  } catch (error) {
    console.log("Login Error:", error);
    res.status(500).json({ error: error.message });
  }
};


// SEND OTP (FOR FORGOT PASSWORD)
exports.sendOtp = async (req, res) => {
  try {

    const { email } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(400).json({ message: "User not found" });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    console.log("Forgot password OTP:", otp);

    user.otp = otp;

    await user.save();

    await sendEmail(email, otp);

    res.json({ message: "OTP sent to email" });

  } catch (error) {
    console.log("Send OTP Error:", error);
    res.status(500).json({ error: error.message });
  }
};


// VERIFY OTP
exports.verifyOtp = async (req, res) => {
  try {

    const { email, otp } = req.body;

    const user = await User.findOne({ email });

    if (!user || user.otp != otp) {
      return res.status(400).json({ message: "Invalid OTP" });
    }

    user.otp = null;

    await user.save();

    res.json({ message: "OTP verified" });

  } catch (error) {
    console.log("Verify OTP Error:", error);
    res.status(500).json({ error: error.message });
  }
};


// RESET PASSWORD
exports.forgotPassword = async (req, res) => {
  try {

    const { email, password } = req.body;

    const hashedPassword = await bcrypt.hash(password, 10);

    await User.updateOne(
      { email },
      { password: hashedPassword }
    );

    res.json({ message: "Password updated" });

  } catch (error) {
    console.log("Reset Password Error:", error);
    res.status(500).json({ error: error.message });
  }
};