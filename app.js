const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const cors = require("cors");
const morgan = require("morgan");
const path = require("path");
const apiRoutes = require("./src/routes");

dotenv.config();

const app = express();

const DEFAULT_PORT = 5002;
const MONGO_URI = process.env.MONGO_URI || "mongodb://127.0.0.1:27017/ecommerce_backend";

const getPreferredPort = () => {
  const envPort = parseInt(process.env.PORT, 10);
  if (!Number.isNaN(envPort) && envPort !== 0 && envPort !== 5000) {
    return envPort;
  }
  return DEFAULT_PORT;
};

console.log('Starting backend with PORT=' + getPreferredPort());

app.use(cors());
app.use(express.json());
app.use(morgan("dev"));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.get("/", (req, res) => {
  res.send("Backend running...");
});

app.use("/api", apiRoutes);

const port = getPreferredPort();
const server = app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

server.on("error", (err) => {
  if (err.code === "EADDRINUSE") {
    console.error(`Port ${port} is already in use. Stop existing server and try again.`);
  } else {
    console.error(err);
  }

  process.exit(1);
});

mongoose
  .connect(MONGO_URI)
  .then(() => {
    console.log("MongoDB connected");
  })
  .catch((err) => {
    console.log("DB error:", err.message);
  });
