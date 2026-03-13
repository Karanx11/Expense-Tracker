const nodemailer = require("nodemailer");

const sendEmail = async (to, subject, text) => {
  try {

    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT,
      secure: false,
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });

    await transporter.sendMail({
      from: `"Expense Tracker" <${process.env.SMTP_USER}>`,
      to: to,
      subject: subject,
      text: text,
    });

    console.log("Email sent successfully");

  } catch (error) {
    console.log("Email error:", error);
  }
};

module.exports = sendEmail;