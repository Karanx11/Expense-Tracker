import nodemailer from "nodemailer";

const sendEmail = async ({ to, subject, html }) => {

  const transporter = nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true,

    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    },

    family: 4 // force IPv4 instead of IPv6
  });

  await transporter.sendMail({
    from: `"Expense Tracker" <${process.env.EMAIL_USER}>`,
    to,
    subject,
    html
  });
};

export default sendEmail;