import type { AuthUser } from "../types";

export const STORAGE_KEYS = {
  accessToken: "admin_access_token",
  refreshToken: "admin_refresh_token",
  user: "admin_user",
  apiBaseUrl: "admin_api_base_url",
} as const;

export const defaultApiBaseUrl =
  import.meta.env.VITE_API_BASE_URL?.toString() || "http://localhost:5002";

export const getApiBaseUrl = () =>
  (localStorage.getItem(STORAGE_KEYS.apiBaseUrl) || defaultApiBaseUrl).replace(/\/+$/, "");

export const setApiBaseUrl = (value: string) => {
  const normalized = value.trim().replace(/\/+$/, "").replace(/\/api$/, "");
  localStorage.setItem(STORAGE_KEYS.apiBaseUrl, normalized);
};

export const getAccessToken = () => localStorage.getItem(STORAGE_KEYS.accessToken);
export const getRefreshToken = () => localStorage.getItem(STORAGE_KEYS.refreshToken);

export const setSession = (payload: {
  accessToken: string;
  refreshToken: string;
  user: AuthUser;
}) => {
  localStorage.setItem(STORAGE_KEYS.accessToken, payload.accessToken);
  localStorage.setItem(STORAGE_KEYS.refreshToken, payload.refreshToken);
  localStorage.setItem(STORAGE_KEYS.user, JSON.stringify(payload.user));
};

export const clearSession = () => {
  localStorage.removeItem(STORAGE_KEYS.accessToken);
  localStorage.removeItem(STORAGE_KEYS.refreshToken);
  localStorage.removeItem(STORAGE_KEYS.user);
};

export const getSessionUser = (): AuthUser | null => {
  const raw = localStorage.getItem(STORAGE_KEYS.user);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as AuthUser;
  } catch {
    return null;
  }
};
