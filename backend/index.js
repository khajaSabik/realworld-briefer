require("dotenv").config();
console.log("🔧 Starting backend application...");

const PORT = process.env.PORT || 3001;
const express = require("express");
const cors = require("cors");
const { sequelize } = require("./models");
const errorHandler = require("./middleware/errorHandler");

const usersRoutes = require("./routes/users");
const userRoutes = require("./routes/user");
const articlesRoutes = require("./routes/articles");
const profilesRoutes = require("./routes/profiles");
const tagsRoutes = require("./routes/tags");

const app = express();
app.use(cors());
app.use(express.json());

// IMPROVED: Better database connection with debug info
(async () => {
  try {
    console.log("🔌 Attempting database connection...");
    console.log("Database config:", {
      host: process.env.DB_HOST || 'not set',
      port: process.env.DB_PORT || 'not set', 
      database: process.env.DB_DATABASE || 'not set',
      user: process.env.DB_USER || 'not set',
      node_env: process.env.NODE_ENV || 'not set'
    });

    // SIMPLIFIED: Always just authenticate, never sync
    await sequelize.authenticate();
    console.log("✅ Database connected successfully");
    
    // Start server immediately after successful connection
    console.log("🚀 Starting Express server...");
    app.listen(PORT, () => {
      console.log(`🎉 Server running on http://localhost:${PORT}`);
      console.log(`📚 API endpoints available:`);
      console.log(`   - Health: http://localhost:${PORT}/api/health`);
      console.log(`   - Articles: http://localhost:${PORT}/api/articles`);
      console.log(`   - Tags: http://localhost:${PORT}/api/tags`);
    });
    
  } catch (error) {
    console.error("❌ Database connection failed:", error.message);
    console.error("💡 Check if database is running and environment variables are set correctly");
    process.exit(1);
  }
})();

// Routes setup
if (process.env.NODE_ENV === "production") {
  app.use(express.static("../frontend/build"));
  console.log("🏗️ Serving frontend build files");
} else {
  app.get("/", (req, res) => res.json({ status: "API is running on /api" }));
  console.log("🔬 Development mode - API only");
}

app.use("/api/users", usersRoutes);
app.use("/api/user", userRoutes);
app.use("/api/articles", articlesRoutes);
app.use("/api/profiles", profilesRoutes);
app.use("/api/tags", tagsRoutes);

app.get("/api/health", (req, res) => {
  res.json({ 
    status: "healthy", 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// FIXED: Proper 404 handler with correct syntax
app.get("*", (req, res) => {
  res.status(404).json({ errors: { body: ["Not found"] } });
});

app.use(errorHandler);

console.log("✅ All routes configured");