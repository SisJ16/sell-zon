const User = require("./user.model");

const getAllUsers = () => User.find();

const getUserById = (id) => User.findById(id);

const createUser = (payload) => User.create(payload);

const updateUserById = (id, payload) =>
  User.findByIdAndUpdate(id, payload, {
    new: true,
    runValidators: true,
  });

const deleteUserById = (id) => User.findByIdAndDelete(id);

const findUserByEmail = (email, includePassword = false) => {
  const query = User.findOne({ email });

  if (includePassword) {
    query.select("+password");
  }

  return query;
};

module.exports = {
  getAllUsers,
  getUserById,
  createUser,
  updateUserById,
  deleteUserById,
  findUserByEmail,
};
