import express from "express";
import cors from "cors";

// Honor Firebase/App Hosting provided port or default to 8080.
const PORT = process.env.PORT ? parseInt(process.env.PORT, 10) : 8080;

const app = express();
app.use(cors());
app.use(express.json());

// Basic health endpoint.
app.get("/health", (_req, res) => {
  res.json({status: "ok", time: new Date().toISOString()});
});

// Example API route.
app.get("/api/echo", (req, res) => {
  res.json({query: req.query, message: "echo", time: Date.now()});
});

// 404 handler.
app.use((req, res) => {
  res.status(404).json({error: "Not Found", path: req.path});
});

app.listen(PORT, () => {
  console.log(`Express server listening on port ${PORT}`);
});
