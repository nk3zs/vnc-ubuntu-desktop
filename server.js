import express from "express";
import Docker from "dockerode";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const docker = new Docker();

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, "frontend")));

app.get("/api/containers", async (req, res) => {
  try {
    const containers = await docker.listContainers({ all: true });
    res.json(containers);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post("/api/container/:id/:action", async (req, res) => {
  const { id, action } = req.params;
  const container = docker.getContainer(id);
  try {
    if (action === "start") await container.start();
    else if (action === "stop") await container.stop();
    else if (action === "restart") await container.restart();
    else return res.status(400).json({ error: "Invalid action" });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get("*", (req, res) => {
  res.sendFile(path.join(__dirname, "frontend", "index.html"));
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log(`Server chạy trên cổng ${PORT}`));
