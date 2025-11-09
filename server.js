import express from "express";
import path from "path";
import { exec } from "child_process";

const app = express();
const PASSWORD = process.env.PASSWORD || "trockbop";
const PORT = process.env.PORT || 8080;

app.use(express.urlencoded({ extended: true }));
app.use(express.static("public"));

app.post("/login", (req, res) => {
  const input = req.body.password;
  if (input === PASSWORD) {
    // Redirect sang Cockpit panel
    res.redirect(`https://${req.headers.host}/cockpit`);
  } else {
    res.send("<h3>❌ Sai mật khẩu!</h3>");
  }
});

app.listen(PORT, () => {
  console.log(`✅ Login panel chạy tại http://localhost:${PORT}`);
});
