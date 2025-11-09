const express = require("express");
const path = require("path");
const app = express();

const PASSWORD = process.env.PASSWORD || "trockbop";
const PORT = process.env.PORT || 8080;

app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, "public")));

app.post("/login", (req, res) => {
  const input = req.body.password;
  if (input === PASSWORD) {
    // Nếu nhập đúng -> chuyển sang panel Cockpit (hoặc dashboard)
    res.redirect("/cockpit");
  } else {
    res.send(`
      <h3 style="color:red;text-align:center;margin-top:40px;">
        ❌ Sai mật khẩu! <a href="/">Thử lại</a>
      </h3>
    `);
  }
});

app.get("/cockpit", (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Ubuntu Panel</title>
        <style>
          body { background:#0f172a; color:#fff; font-family:sans-serif; text-align:center; margin-top:10%; }
          h1 { color:#22c55e; }
          a { color:#60a5fa; text-decoration:none; }
        </style>
      </head>
      <body>
        <h1>✅ Welcome to Ubuntu Panel</h1>
        <p>Đăng nhập thành công!</p>
        <p><a href="/">Logout</a></p>
      </body>
    </html>
  `);
});

app.listen(PORT, () => {
  console.log(`✅ Server running on http://localhost:${PORT}`);
});
