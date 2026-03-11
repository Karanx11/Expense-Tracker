const express = require("express");
const router = express.Router();

const {
  signup,
  login,
  sendOtp,
  verifyOtp,
  forgotPassword
} = require("../controllers/authController");

router.post("/signup", signup);
router.post("/login", login);
router.post("/send-otp", sendOtp);
router.post("/verify-otp", verifyOtp);
router.post("/forgot-password", forgotPassword);

module.exports = router;