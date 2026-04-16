const Banner = require("./banner.model");

const getPublicBanners = () =>
  Banner.find({ isActive: true }).sort({ sortOrder: 1, createdAt: -1 });

const getAllBannersForAdmin = () => Banner.find().sort({ sortOrder: 1, createdAt: -1 });

const createBanner = (payload) => Banner.create(payload);

const updateBannerById = (id, payload) =>
  Banner.findByIdAndUpdate(id, payload, {
    new: true,
    runValidators: true,
  });

const deleteBannerById = (id) => Banner.findByIdAndDelete(id);

module.exports = {
  getPublicBanners,
  getAllBannersForAdmin,
  createBanner,
  updateBannerById,
  deleteBannerById,
};
