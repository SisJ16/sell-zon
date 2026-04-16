const bannerService = require("./banner.service");

const listBanners = async (_req, res) => {
  try {
    const banners = await bannerService.getPublicBanners();
    res.status(200).json({ message: "Banners fetched successfully", data: banners });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const listBannersForAdmin = async (_req, res) => {
  try {
    const banners = await bannerService.getAllBannersForAdmin();
    res.status(200).json({ message: "Banners fetched successfully", data: banners });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createBanner = async (req, res) => {
  try {
    const { title, subtitle, image, targetType, targetValue, isActive, sortOrder } = req.body;

    if (!title || !image || !targetType || !targetValue) {
      return res.status(400).json({ message: "Missing required banner fields" });
    }

    const banner = await bannerService.createBanner({
      title,
      subtitle,
      image,
      targetType,
      targetValue,
      isActive,
      sortOrder,
    });

    res.status(201).json({ message: "Banner created successfully", data: banner });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const updateBanner = async (req, res) => {
  try {
    const banner = await bannerService.updateBannerById(req.params.id, req.body);

    if (!banner) {
      return res.status(404).json({ message: "Banner not found" });
    }

    res.status(200).json({ message: "Banner updated successfully", data: banner });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const deleteBanner = async (req, res) => {
  try {
    const banner = await bannerService.deleteBannerById(req.params.id);
    if (!banner) {
      return res.status(404).json({ message: "Banner not found" });
    }

    res.status(200).json({ message: "Banner deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  listBanners,
  listBannersForAdmin,
  createBanner,
  updateBanner,
  deleteBanner,
};
