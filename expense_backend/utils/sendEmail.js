const nodemailer = require("nodemailer");

const sendEmail = async ({ to, subject, html }) => {
  try {

    const transporter = nodemailer.createTransport({
      host: "smtp-relay.brevo.com",
      port: 587,
      secure: false,
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });

    await transporter.sendMail({
      from: `"Expense Tracker" <${process.env.SMTP_USER}>`,
      to,
      subject,
      html,
    });

    console.log("Email sent successfully");

  } catch (error) {
    console.log("Email error:", error);
  }
};

module.exports = sendEmail;