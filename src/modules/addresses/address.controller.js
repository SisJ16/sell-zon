const addressService = require("./address.service");

const listAddresses = async (req, res) => {
  try {
    const items = await addressService.listByUserId(req.user.id);
    res.status(200).json({ message: "Addresses fetched successfully", data: items });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createAddress = async (req, res) => {
  try {
    const { label, fullAddress, note, latitude, longitude, isDefault } = req.body;
    if (!fullAddress || !String(fullAddress).trim()) {
      return res.status(400).json({ message: "fullAddress is required" });
    }

    const address = await addressService.createAddress({
      userId: req.user.id,
      label,
      fullAddress: String(fullAddress).trim(),
      note: note || "",
      latitude: latitude ?? null,
      longitude: longitude ?? null,
      isDefault: Boolean(isDefault),
    });

    res.status(201).json({ message: "Address created successfully", data: address });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const updateAddress = async (req, res) => {
  try {
    const payload = { ...req.body };
    if (payload.fullAddress !== undefined) {
      payload.fullAddress = String(payload.fullAddress).trim();
    }
    const address = await addressService.updateAddressById(req.user.id, req.params.id, payload);
    if (!address) {
      return res.status(404).json({ message: "Address not found" });
    }
    res.status(200).json({ message: "Address updated successfully", data: address });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const deleteAddress = async (req, res) => {
  try {
    const address = await addressService.deleteAddressById(req.user.id, req.params.id);
    if (!address) {
      return res.status(404).json({ message: "Address not found" });
    }
    res.status(200).json({ message: "Address deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  listAddresses,
  createAddress,
  updateAddress,
  deleteAddress,
};
