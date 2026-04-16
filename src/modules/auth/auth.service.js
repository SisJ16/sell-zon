const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { randomUUID } = require("crypto");
const userService = require("../users/user.service");
const RefreshToken = require("./refresh-token.model");

const ACCESS_TOKEN_EXPIRES_IN = process.env.JWT_ACCESS_EXPIRES_IN || "15m";
const REFRESH_TOKEN_EXPIRES_IN = process.env.JWT_REFRESH_EXPIRES_IN || "30d";

const getAccessSecret = () => process.env.JWT_SECRET || "dev_secret_change_me";
const getRefreshSecret = () =>
  process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET || "dev_secret_change_me";

const sanitizeUser = (userDoc) => ({
  id: userDoc._id,
  name: userDoc.name,
  email: userDoc.email,
  role: userDoc.role,
  createdAt: userDoc.createdAt,
  updatedAt: userDoc.updatedAt,
});

const createAccessToken = (userDoc) => {
  return jwt.sign(
    {
      sub: String(userDoc._id),
      role: userDoc.role,
      email: userDoc.email,
      type: "access",
    },
    getAccessSecret(),
    { expiresIn: ACCESS_TOKEN_EXPIRES_IN }
  );
};

const createRefreshToken = (userDoc) => {
  const tokenId = randomUUID();

  const token = jwt.sign(
    {
      sub: String(userDoc._id),
      type: "refresh",
      jti: tokenId,
    },
    getRefreshSecret(),
    { expiresIn: REFRESH_TOKEN_EXPIRES_IN }
  );

  return { token, tokenId };
};

const issueTokenPair = async (userDoc) => {
  const accessToken = createAccessToken(userDoc);
  const refreshTokenData = createRefreshToken(userDoc);
  const decodedRefresh = jwt.decode(refreshTokenData.token);

  await RefreshToken.create({
    tokenId: refreshTokenData.tokenId,
    userId: userDoc._id,
    expiresAt: new Date(decodedRefresh.exp * 1000),
  });

  return {
    accessToken,
    refreshToken: refreshTokenData.token,
  };
};

const register = async ({ name, email, password, role }) => {
  const existingUser = await userService.findUserByEmail(email);

  if (existingUser) {
    const error = new Error("User already exists");
    error.statusCode = 400;
    throw error;
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  const createdUser = await userService.createUser({
    name,
    email,
    password: hashedPassword,
    role,
  });

  const tokens = await issueTokenPair(createdUser);

  return {
    user: sanitizeUser(createdUser),
    ...tokens,
  };
};

const login = async ({ email, password }) => {
  const user = await userService.findUserByEmail(email, true);

  if (!user) {
    const error = new Error("Invalid email or password");
    error.statusCode = 401;
    throw error;
  }

  const isPasswordValid = await bcrypt.compare(password, user.password);

  if (!isPasswordValid) {
    const error = new Error("Invalid email or password");
    error.statusCode = 401;
    throw error;
  }

  return {
    user: sanitizeUser(user),
    ...(await issueTokenPair(user)),
  };
};

const refresh = async ({ refreshToken }) => {
  let payload;

  try {
    payload = jwt.verify(refreshToken, getRefreshSecret());
  } catch (_error) {
    const error = new Error("Invalid or expired refresh token");
    error.statusCode = 401;
    throw error;
  }

  if (payload.type !== "refresh" || !payload.jti || !payload.sub) {
    const error = new Error("Invalid refresh token");
    error.statusCode = 401;
    throw error;
  }

  const tokenRecord = await RefreshToken.findOne({
    tokenId: payload.jti,
    userId: payload.sub,
    revoked: false,
    expiresAt: { $gt: new Date() },
  });

  if (!tokenRecord) {
    const error = new Error("Refresh token revoked or not found");
    error.statusCode = 401;
    throw error;
  }

  const user = await userService.getUserById(payload.sub);

  if (!user) {
    const error = new Error("User not found");
    error.statusCode = 404;
    throw error;
  }

  tokenRecord.revoked = true;
  await tokenRecord.save();

  return {
    user: sanitizeUser(user),
    ...(await issueTokenPair(user)),
  };
};

const logout = async ({ refreshToken }) => {
  let payload;

  try {
    payload = jwt.verify(refreshToken, getRefreshSecret(), { ignoreExpiration: true });
  } catch (_error) {
    return { success: true };
  }

  if (!payload.jti) {
    return { success: true };
  }

  await RefreshToken.findOneAndUpdate(
    { tokenId: payload.jti },
    { revoked: true },
    { new: true }
  );

  return { success: true };
};

module.exports = {
  register,
  login,
  refresh,
  logout,
};
