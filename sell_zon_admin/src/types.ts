export type UserRole = "admin" | "customer";

export interface AuthUser {
  id: string;
  name: string;
  email: string;
  role: UserRole;
}

export interface AuthPayload {
  user: AuthUser;
  accessToken: string;
  refreshToken: string;
}

export interface AdminUser {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  createdAt?: string;
}

export interface Product {
  _id: string;
  name: string;
  price: number;
  stock: number;
  category: string;
  image: string;
  description: string;
  isActive: boolean;
}

export interface Banner {
  _id: string;
  title: string;
  subtitle: string;
  image: string;
  targetType: "category" | "product" | "url";
  targetValue: string;
  isActive: boolean;
  sortOrder: number;
}
