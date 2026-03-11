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

      text: `Your OTP is: ${otp}`

    };

    const info = await transporter.sendMail(mailOptions);

    console.log("Email sent:", info.response);

  } catch (error) {

    console.log("Email error:", error);

  }

};

module.exports = sendEmail;