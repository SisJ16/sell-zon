import { useState } from "react";
import type { FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { createApiClient } from "../lib/api";
import {
  defaultApiBaseUrl,
  getApiBaseUrl,
  setApiBaseUrl,
  setSession,
} from "../lib/storage";
import type { AuthPayload } from "../types";

export default function LoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [baseUrl, setBaseUrlState] = useState(getApiBaseUrl());
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleLogin = async (e: FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      setApiBaseUrl(baseUrl);
      const api = createApiClient();
      const response = await api.post("/api/auth/login", {
        email: email.trim().toLowerCase(),
        password,
      });

      const data = response.data.data as AuthPayload;

      if (data.user.role !== "admin") {
        setError("Only admin can login to this panel.");
        setLoading(false);
        return;
      }

      setSession(data);
      navigate("/", { replace: true });
    } catch (err: any) {
      setError(err?.response?.data?.message || "Login failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="page center">
      <form className="card form" onSubmit={handleLogin}>
        <h1>SellZon Admin Login</h1>

        <label>API Base URL</label>
        <input
          value={baseUrl}
          onChange={(e) => setBaseUrlState(e.target.value)}
          placeholder={defaultApiBaseUrl}
        />

        <label>Email</label>
        <input value={email} onChange={(e) => setEmail(e.target.value)} type="email" required />

        <label>Password</label>
        <input
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          type="password"
          required
        />

        {error && <p className="error">{error}</p>}
        <button type="submit" disabled={loading}>
          {loading ? "Signing in..." : "Login"}
        </button>
      </form>
    </div>
  );
}
