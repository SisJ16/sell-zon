const User = require("../users/user.model");

const buildUserListQuery = ({ search }) => {
  if (!search) {
    return {};
  }

  return {
    $or: [
      { name: { $regex: search, $options: "i" } },
      { email: { $regex: search, $options: "i" } },
    ],
  };
};

const getUsers = async ({ page = 1, limit = 10, search = "" }) => {
  const query = buildUserListQuery({ search: search.trim() });
  const skip = (page - 1) * limit;

  const [items, total] = await Promise.all([
    User.find(query).sort({ createdAt: -1 }).skip(skip).limit(limit),
    User.countDocuments(query),
  ]);

  return {
    items,
    pagination: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit) || 1,
    },
  };
};

const getUserById = (id) => User.findById(id);

const updateUserRole = (id, role) =>
  User.findByIdAndUpdate(
    id,
    { role },
    {
      new: true,
      runValidators: true,
    }
  );

const deleteUserById = (id) => User.findByIdAndDelete(id);

module.exports = {
  getUsers,
  getUserById,
  updateUserRole,
  deleteUserById,
};
