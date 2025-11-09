import express from "express";
import session from "express-session";
import bodyParser from "body-parser";
import path from "path";

const app = express();
const __dirname = path.resolve();

app.use(bodyParser.urlencoded({ extended: true }));
app.use(session({
    secret: 'secretkey',
    resave: false,
    saveUninitialized: true
}));

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

// Fake VPS data
let vpsList = [
    { id: 1, name: "vps1", status: "stopped", ram: "2GB" },
    { id: 2, name: "vps2", status: "stopped", ram: "1GB" },
];

// Middleware login
function auth(req, res, next) {
    if(req.session.user) next();
    else res.redirect('/login');
}

// Login
app.get('/login', (req, res) => res.render('login'));
app.post('/login', (req, res) => {
    const { username, password } = req.body;
    if(username === "trockbop" && password === "trockbop") {
        req.session.user = username;
        res.redirect('/dashboard');
    } else {
        res.send("Sai username/password");
    }
});

// Dashboard
app.get('/dashboard', auth, (req, res) => {
    res.render('dashboard', { vpsList });
});

// VPS detail
app.get('/vps/:id', auth, (req, res) => {
    const vps = vpsList.find(v => v.id == req.params.id);
    res.render('vps', { vps });
});

// VPS actions
app.post('/vps/:id/:action', auth, (req, res) => {
    const vps = vpsList.find(v => v.id == req.params.id);
    if(req.params.action === 'start') vps.status = "running";
    if(req.params.action === 'stop') vps.status = "stopped";
    res.redirect(`/vps/${vps.id}`);
});

app.post('/vps/:id/console', auth, (req, res) => {
    const vps = vpsList.find(v => v.id == req.params.id);
    const cmd = req.body.cmd;
    vps.log = vps.log || [];
    vps.log.push(cmd); // chỉ lưu lệnh, không chạy thực
    res.redirect(`/vps/${vps.id}`);
});

app.listen(process.env.PORT || 3000, () => console.log("Server running"));
