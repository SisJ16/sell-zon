import { Navigate, Outlet } from "react-router-dom";
import { getSessionUser } from "../lib/storage";

export default function ProtectedRoute() {
  const user = getSessionUser();

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (user.role !== "admin") {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
}
