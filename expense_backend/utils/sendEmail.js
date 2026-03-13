const nodemailer = require("nodemailer");

const sendEmail = async (email, otp) => {
  try {

    const transporter = nodemailer.createTransport({
      host: "smtp.gmail.com",
      port: 587,
      secure: false,
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }
    });

    const mailOptions = {
      from: `"Expense Tracker" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: "Expense Tracker OTP Verification",
      text: `Your OTP is: ${otp}`
    };

    const info = await transporter.sendMail(mailOptions);

    console.log("Email sent:", info.response);

  } catch (error) {
    console.error("Email sending error:", error);
  }
};

module.exports = sendEmail;