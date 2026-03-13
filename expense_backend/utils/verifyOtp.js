exports.verifyOtp = async (req, res) => {

  try {

    const { email, otp } = req.body;

    const user = await User.findOne({ email });

    if (!user || user.otp != otp) {
      return res.status(400).json({ message: "Invalid OTP" });
    }

    user.otp = null;

    await user.save();

    res.json({
      message: "OTP verified successfully"
    });

  } catch (error) {

    res.status(500).json({ error: error.message });

  }

};