const authService = require("./auth.service");

const register = async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        message: "name, email and password are required",
      });
    }

    const result = await authService.register({ name, email, password, role });

    res.status(201).json({
      message: "Registration successful",
      data: result,
    });
  } catch (error) {
    res.status(error.statusCode || 500).json({
      message: error.message || "Server error",
    });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: "email and password are required",
      });
    }

    const result = await authService.login({ email, password });

    res.status(200).json({
      message: "Login successful",
      data: result,
    });
  } catch (error) {
    res.status(error.statusCode || 500).json({
      message: error.message || "Server error",
    });
  }
};

const refresh = async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        message: "refreshToken is required",
      });
    }

    const result = await authService.refresh({ refreshToken });

    res.status(200).json({
      message: "Token refreshed successfully",
      data: result,
    });
  } catch (error) {
    res.status(error.statusCode || 500).json({
      message: error.message || "Server error",
    });
  }
};

const logout = async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        message: "refreshToken is required",
      });
    }

    await authService.logout({ refreshToken });

    res.status(200).json({
      message: "Logout successful",
    });
  } catch (error) {
    res.status(error.statusCode || 500).json({
      message: error.message || "Server error",
    });
  }
};

module.exports = {
  register,
  login,
  refresh,
  logout,
};
