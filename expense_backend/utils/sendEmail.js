const nodemailer = require("nodemailer");

const sendEmail = async (email, otp) => {

  try {

    const transporter = nodemailer.createTransport({

      service: "gmail",

      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
      }

    });

    const mailOptions = {

      from: process.env.EMAIL_USER,

      to: email,

      subject: "Expense Tracker OTP Verification",

      html: `
        <h2>Expense Tracker Verification</h2>
        <p>Your OTP is:</p>
        <h1>${otp}</h1>
        <p>This OTP is valid for 5 minutes.</p>
      `
    };

    await transporter.sendMail(mailOptions);

    console.log("OTP Email sent");

  } catch (error) {

    console.log("Email Error:", error);

  }

};

module.exports = sendEmail;