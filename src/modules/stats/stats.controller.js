const statsService = require("./stats.service");

const getOverview = async (_req, res) => {
  try {
    const data = await statsService.getOverview();
    res.status(200).json({
      message: "Stats overview fetched successfully",
      data,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getOrdersTrend = async (_req, res) => {
  try {
    const trend = await statsService.getOrdersTrend();
    res.status(200).json({
      message: "Orders trend fetched successfully",
      data: trend,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getOverview,
  getOrdersTrend,
};
