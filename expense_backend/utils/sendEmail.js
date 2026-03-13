const { Resend } = require("resend");

const resend = new Resend(process.env.RESEND_API_KEY);

const sendEmail = async (email, otp) => {
  try {

    await resend.emails.send({
      from: "Expense Tracker <onboarding@resend.dev>",
      to: email,
      subject: "Your OTP Code",
      html: `<h2>Your OTP is ${otp}</h2>
             <p>This OTP expires in 5 minutes.</p>`,
    });

    console.log("Email sent successfully");

  } catch (error) {
    console.error("Email error:", error);
  }
};

module.exports = sendEmail;