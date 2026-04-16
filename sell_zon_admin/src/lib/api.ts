import axios from "axios";
import {
  clearSession,
  getAccessToken,
  getApiBaseUrl,
  getRefreshToken,
  setSession,
} from "./storage";
import type { AuthPayload } from "../types";

export const createApiClient = () => {
  const api = axios.create({
    baseURL: getApiBaseUrl(),
  });

  api.interceptors.request.use((config) => {
    const token = getAccessToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  });

  api.interceptors.response.use(
    (response) => response,
    async (error) => {
      const status = error?.response?.status;
      const originalRequest = error.config;

      if (status !== 401 || originalRequest?._retry) {
        return Promise.reject(error);
      }

      const refreshToken = getRefreshToken();
      if (!refreshToken) {
        clearSession();
        return Promise.reject(error);
      }

      originalRequest._retry = true;

      try {
        const refreshResponse = await axios.post(`${getApiBaseUrl()}/api/auth/refresh`, {
          refreshToken,
        });

        const data = refreshResponse.data.data as AuthPayload;
        setSession(data);
        originalRequest.headers.Authorization = `Bearer ${data.accessToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        clearSession();
        return Promise.reject(refreshError);
      }
    }
  );

  return api;
};
