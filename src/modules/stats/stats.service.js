const User = require("../users/user.model");
const Product = require("../products/product.model");
const Banner = require("../banners/banner.model");

const CATEGORIES = ["AirPods", "Headphone", "Smart Watch"];

const getOverview = async () => {
  const [totalUsers, totalProducts, totalBanners] = await Promise.all([
    User.countDocuments(),
    Product.countDocuments(),
    Banner.countDocuments(),
  ]);

  const totalsByCategory = await Product.aggregate([
    {
      $group: {
        _id: "$category",
        totalStock: { $sum: "$stock" },
        totalValue: { $sum: { $multiply: ["$price", "$stock"] } },
        productCount: { $sum: 1 },
      },
    },
  ]);

  const normalizedCategoryStats = CATEGORIES.map((name) => {
    const found = totalsByCategory.find((item) => item._id === name);
    return {
      category: name,
      totalStock: found?.totalStock || 0,
      totalValue: found?.totalValue || 0,
      productCount: found?.productCount || 0,
    };
  });

  const totalRevenueEstimate = normalizedCategoryStats.reduce(
    (sum, item) => sum + item.totalValue,
    0
  );

  return {
    overview: {
      totalUsers,
      totalProducts,
      totalBanners,
      totalOrders: 0,
      totalRevenueEstimate,
    },
    categories: normalizedCategoryStats,
  };
};

const getOrdersTrend = async () => {
  // Placeholder until order module is implemented.
  // Uses last 7 days with zero values so frontend chart is ready.
  const trend = [];
  const now = new Date();
  for (let i = 6; i >= 0; i -= 1) {
    const date = new Date(now);
    date.setDate(now.getDate() - i);
    trend.push({
      label: `${date.getMonth() + 1}/${date.getDate()}`,
      orders: 0,
    });
  }
  return trend;
};

module.exports = {
  getOverview,
  getOrdersTrend,
};
