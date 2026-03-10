const User = require("../models/User")
const bcrypt = require("bcryptjs")
const jwt = require("jsonwebtoken")

const sendEmail = require("../utils/sendEmail")

exports.signup = async (req, res) => {

  try {

    const { name, email, password } = req.body

    const existingUser = await User.findOne({ email })

    if (existingUser) {
      return res.status(400).json({ message: "User already exists" })
    }

    const hashedPassword = await bcrypt.hash(password, 10)

    const otp = Math.floor(100000 + Math.random() * 900000)

    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      otp,
      otpExpires: Date.now() + 10 * 60 * 1000
    })

    await sendEmail(email, otp)

    res.json({
      message: "OTP sent to email"
    })

  } catch (error) {

    res.status(500).json({ error: error.message })

  }

}

//OTP
exports.verifyOtp = async (req, res) => {

  const { email, otp } = req.body

  const user = await User.findOne({ email })

  if (!user) return res.status(404).json({ message: "User not found" })

  if (user.otp != otp) {
    return res.status(400).json({ message: "Invalid OTP" })
  }

  if (user.otpExpires < Date.now()) {
    return res.status(400).json({ message: "OTP expired" })
  }

  user.isVerified = true
  user.otp = null
  user.otpExpires = null

  await user.save()

  res.json({ message: "Email verified successfully" })

}
//Forgot Password

exports.forgotPassword = async (req, res) => {

  try {

    const { email } = req.body

    const user = await User.findOne({ email })

    if (!user) {
      return res.status(404).json({ message: "User not found" })
    }

    const otp = Math.floor(100000 + Math.random() * 900000)

    user.otp = otp
    user.otpExpires = Date.now() + 10 * 60 * 1000

    await user.save()

    await sendEmail(email, otp)

    res.json({
      message: "OTP sent to email"
    })

  } catch (error) {

    res.status(500).json({ error: error.message })

  }

}
//Reset Password
exports.resetPassword = async (req, res) => {

  try {

    const { email, otp, newPassword } = req.body

    const user = await User.findOne({ email })

    if (!user) {
      return res.status(404).json({ message: "User not found" })
    }

    if (user.otp != otp) {
      return res.status(400).json({ message: "Invalid OTP" })
    }

    if (user.otpExpires < Date.now()) {
      return res.status(400).json({ message: "OTP expired" })
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10)

    user.password = hashedPassword
    user.otp = null
    user.otpExpires = null

    await user.save()

    res.json({
      message: "Password reset successful"
    })

  } catch (error) {

    res.status(500).json({ error: error.message })

  }

}
// Login
exports.login = async (req, res) => {
  try {

    const { email, password } = req.body

    const user = await User.findOne({ email })

    if (!user) {
      return res.status(404).json({ message: "User not found" })
    }

    const isMatch = await bcrypt.compare(password, user.password)

    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials" })
    }

    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    )

    res.json({
      message: "Login successful",
      token,
      user
    })

  } catch (error) {
    res.status(500).json({ error: error.message })
  }
}