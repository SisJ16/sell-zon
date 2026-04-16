const Address = require("./address.model");

const listByUserId = (userId) => Address.find({ userId }).sort({ isDefault: -1, createdAt: -1 });

const createAddress = async (payload) => {
  if (payload.isDefault) {
    await Address.updateMany({ userId: payload.userId }, { $set: { isDefault: false } });
  }
  return Address.create(payload);
};

const updateAddressById = async (userId, addressId, payload) => {
  if (payload.isDefault) {
    await Address.updateMany({ userId }, { $set: { isDefault: false } });
  }
  return Address.findOneAndUpdate({ _id: addressId, userId }, payload, { new: true, runValidators: true });
};

const deleteAddressById = (userId, addressId) => Address.findOneAndDelete({ _id: addressId, userId });

module.exports = {
  listByUserId,
  createAddress,
  updateAddressById,
  deleteAddressById,
};
