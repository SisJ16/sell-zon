import { useEffect, useMemo, useState } from "react";
import {
  AppBar,
  Box,
  Button,
  Card,
  CardContent,
  CssBaseline,
  Divider,
  Drawer,
  FormControlLabel,
  IconButton,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  MenuItem,
  Switch,
  TextField,
  ThemeProvider,
  Toolbar,
  Typography,
  createTheme,
} from "@mui/material";
import DashboardRoundedIcon from "@mui/icons-material/DashboardRounded";
import PeopleAltRoundedIcon from "@mui/icons-material/PeopleAltRounded";
import Inventory2RoundedIcon from "@mui/icons-material/Inventory2Rounded";
import CampaignRoundedIcon from "@mui/icons-material/CampaignRounded";
import LogoutRoundedIcon from "@mui/icons-material/LogoutRounded";
import AccountCircleRoundedIcon from "@mui/icons-material/AccountCircleRounded";
import PaidRoundedIcon from "@mui/icons-material/PaidRounded";
import ShareRoundedIcon from "@mui/icons-material/ShareRounded";
import GradeRoundedIcon from "@mui/icons-material/GradeRounded";
import DarkModeRoundedIcon from "@mui/icons-material/DarkModeRounded";
import LightModeRoundedIcon from "@mui/icons-material/LightModeRounded";
import {
  Bar,
  BarChart,
  CartesianGrid,
  Legend,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { createApiClient } from "../lib/api";
import { clearSession, getSessionUser, getRefreshToken } from "../lib/storage";
import type { AdminUser, Banner, Product, UserRole } from "../types";

interface AdminUsersResponse {
  data: {
    items: AdminUser[];
  };
}

interface AdminProductsResponse {
  data: Product[];
}

interface AdminBannersResponse {
  data: Banner[];
}

type BannerTargetType = "category" | "product" | "url";
type MenuKey = "dashboard" | "users" | "products" | "banners";

interface BannerFormState {
  title: string;
  subtitle: string;
  image: string;
  targetType: BannerTargetType;
  targetValue: string;
  isActive: boolean;
  sortOrder: string;
}

interface StatsOverviewResponse {
  data: {
    overview: {
      totalUsers: number;
      totalProducts: number;
      totalBanners: number;
      totalOrders: number;
      totalRevenueEstimate: number;
    };
    categories: Array<{
      category: string;
      totalStock: number;
      totalValue: number;
      productCount: number;
    }>;
  };
}

interface OrdersTrendResponse {
  data: Array<{
    label: string;
    orders: number;
  }>;
}

const drawerWidth = 260;
const statCardStyles = [
  { title: "Earning", valueKey: "totalRevenueEstimate", icon: <PaidRoundedIcon />, bg: "linear-gradient(135deg, #0b3a6f, #1a6bbd)", color: "#fff" },
  { title: "Users", valueKey: "totalUsers", icon: <ShareRoundedIcon />, bg: "linear-gradient(135deg, #ffffff, #f2f5ff)", color: "#111827" },
  { title: "Products", valueKey: "totalProducts", icon: <Inventory2RoundedIcon />, bg: "linear-gradient(135deg, #ffffff, #f9fbff)", color: "#111827" },
  { title: "Orders", valueKey: "totalOrders", icon: <GradeRoundedIcon />, bg: "linear-gradient(135deg, #ffffff, #f4f7ff)", color: "#111827" },
] as const;

export default function DashboardPage() {
  const currentUser = useMemo(() => getSessionUser(), []);
  const [activeMenu, setActiveMenu] = useState<MenuKey>("dashboard");
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [banners, setBanners] = useState<Banner[]>([]);
  const [statsOverview, setStatsOverview] = useState({
    totalUsers: 0,
    totalProducts: 0,
    totalBanners: 0,
    totalOrders: 0,
    totalRevenueEstimate: 0,
  });
  const [categoryStats, setCategoryStats] = useState<
    Array<{ category: string; totalStock: number; totalValue: number; productCount: number }>
  >([]);
  const [ordersTrend, setOrdersTrend] = useState<Array<{ label: string; orders: number }>>([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(false);
  const [productForm, setProductForm] = useState({
    name: "",
    price: "",
    stock: "",
    category: "AirPods",
    image: "",
    description: "",
    isActive: true,
  });
  const [uploadingImage, setUploadingImage] = useState(false);
  const [selectedFileName, setSelectedFileName] = useState("");
  const [bannerForm, setBannerForm] = useState<BannerFormState>({
    title: "",
    subtitle: "",
    image: "",
    targetType: "category",
    targetValue: "",
    isActive: true,
    sortOrder: "0",
  });
  const [uploadingBannerImage, setUploadingBannerImage] = useState(false);
  const [selectedBannerFileName, setSelectedBannerFileName] = useState("");
  const [darkMode, setDarkMode] = useState(false);
  const api = useMemo(() => createApiClient(), []);
  const categoryOptions = ["AirPods", "Headphone", "Smart Watch"];
  const theme = useMemo(
    () =>
      createTheme({
        palette: {
          mode: darkMode ? "dark" : "light",
        },
      }),
    [darkMode]
  );
  const activeProductsCount = products.filter((product) => product.isActive).length;
  const inactiveProductsCount = products.length - activeProductsCount;

  const loadUsers = async () => {
    setLoading(true);
    try {
      const query = search.trim() ? `?search=${encodeURIComponent(search.trim())}` : "";
      const response = await api.get<AdminUsersResponse>(`/api/admin/users${query}`);
      setUsers(response.data.data.items);
    } catch (error) {
      console.error(error);
      alert("Failed to load users");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void Promise.all([loadStats(), loadProducts()]);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const loadStats = async () => {
    setLoading(true);
    try {
      const [overviewRes, trendRes] = await Promise.all([
        api.get<StatsOverviewResponse>("/api/admin/stats/overview"),
        api.get<OrdersTrendResponse>("/api/admin/stats/orders-trend"),
      ]);
      setStatsOverview(overviewRes.data.data.overview);
      setCategoryStats(overviewRes.data.data.categories);
      setOrdersTrend(trendRes.data.data);
    } catch (error) {
      console.error(error);
      alert("Failed to load dashboard stats");
    } finally {
      setLoading(false);
    }
  };

  const loadProducts = async () => {
    setLoading(true);
    try {
      const response = await api.get<AdminProductsResponse>("/api/admin/products");
      setProducts(response.data.data);
    } catch (error) {
      console.error(error);
      alert("Failed to load products");
    } finally {
      setLoading(false);
    }
  };

  const loadBanners = async () => {
    setLoading(true);
    try {
      const response = await api.get<AdminBannersResponse>("/api/admin/banners");
      setBanners(response.data.data);
    } catch (error) {
      console.error(error);
      alert("Failed to load banners");
    } finally {
      setLoading(false);
    }
  };

  const updateRole = async (userId: string, role: UserRole) => {
    try {
      await api.patch(`/api/admin/users/${userId}/role`, { role });
      await loadUsers();
    } catch (error: any) {
      alert(error?.response?.data?.message || "Failed to update role");
    }
  };

  const deleteUser = async (userId: string) => {
    const ok = window.confirm("Delete this user?");
    if (!ok) return;

    try {
      await api.delete(`/api/admin/users/${userId}`);
      await loadUsers();
    } catch (error: any) {
      alert(error?.response?.data?.message || "Failed to delete user");
    }
  };

  const createProduct = async () => {
    if (
      !productForm.name.trim() ||
      !productForm.price.trim() ||
      !productForm.stock.trim() ||
      !productForm.category.trim() ||
      !productForm.image.trim() ||
      !productForm.description.trim()
    ) {
      alert("Please fill all product fields and upload/select an image.");
      return;
    }

    try {
      await api.post("/api/admin/products", {
        name: productForm.name,
        price: Number(productForm.price),
        stock: Number(productForm.stock),
        category: productForm.category,
        image: productForm.image,
        description: productForm.description,
        isActive: productForm.isActive,
      });
      setProductForm({
        name: "",
        price: "",
        stock: "",
        category: "AirPods",
        image: "",
        description: "",
        isActive: true,
      });
      setSelectedFileName("");
      await loadProducts();
    } catch (error: any) {
      alert(error?.response?.data?.message || "Failed to create product");
    }
  };

  const uploadProductImage = async (file: File) => {
    setUploadingImage(true);
    try {
      const formData = new FormData();
      formData.append("image", file);

      const response = await api.post("/api/uploads/product-image", formData);

      const imageUrl = response.data?.data?.url || "";
      setProductForm((state) => ({ ...state, image: imageUrl }));
      setSelectedFileName(file.name);
    } catch (error: any) {
      alert(error?.response?.data?.message || "Image upload failed");
    } finally {
      setUploadingImage(false);
    }
  };

  const toggleProductStatus = async (product: Product) => {
    try {
      await api.put(`/api/admin/products/${product._id}`, {
        isActive: !product.isActive,
      });
      await loadProducts();
    } catch (error: any) {
      alert(error?.response?.data?.message || "Failed to update product");
    }
  };

  const deleteProduct = async (productId: string) => {
    const ok = window.confirm("Delete this product?");
    if (!ok) return;

    try {
      await api.delete(`/api/admin/products/${productId}`);
      await loadProducts();
    } catch (error: any) {
      alert(error?.response?.data?.message || "Failed to delete product");
    }
  };

  const uploadBannerImage = async (file: File) => {
    setUploadingBannerImage(true);
    try {
      const formData = new FormData();
      formData.append("image", file);
      const response = await api.post("/api/uploads/banner-image", formData);
      const imageUrl = response.data?.data?.url || "";
      setBannerForm((state) => ({ ...state, image: imageUrl }));
      setSelectedBannerFileName(file.name);
    } catch (error: any) {
      alert(error?.response?.data?.message || "Banner image upload failed");
    } finally {
      setUploadingBannerImage(false);
    }
  };

  const createBanner = async () => {
    if (!bannerForm.title.trim() || !bannerForm.image.trim() || !bannerForm.targetValue.trim()) {
      alert("Please fill required banner fields.");
      return;
    }

    try {
      await api.post("/api/admin/banners", {
        title: bannerForm.title,
        subtitle: bannerForm.subtitle,
        image: bannerForm.image,
        targetType: bannerForm.targetType,
        targetValue: bannerForm.targetValue,
        isActive: bannerForm.isActive,
        sortOrder: Number(bannerForm.sortOrder || "0"),
      });
      setBannerForm({
        title: "",
        subtitle: "",
        image: "",
        targetType: "category",
        targetValue: "",
        isActive: true,
        sortOrder: "0",
      });
      setSelectedBannerFileName("");
      await loadBanners();
    } catch (error: any) {
      alert(error?.response?.data?.message || "Failed to create banner");
    }
  };

  const toggleBannerStatus = async (banner: Banner) => {
    try {
      await api.put(`/api/admin/banners/${banner._id}`, {
        isActive: !banner.isActive,
      });
      await loadBanners();
    } catch (error: any) {
      alert(error?.response?.data?.message || "Failed to update banner");
    }
  };

  const deleteBanner = async (bannerId: string) => {
    const ok = window.confirm("Delete this banner?");
    if (!ok) return;

    try {
      await api.delete(`/api/admin/banners/${bannerId}`);
      await loadBanners();
    } catch (error: any) {
      alert(error?.response?.data?.message || "Failed to delete banner");
    }
  };

  const logout = async () => {
    try {
      const refreshToken = getRefreshToken();
      if (refreshToken) {
        await api.post("/api/auth/logout", { refreshToken });
      }
    } catch {
      // ignore
    } finally {
      clearSession();
      window.location.href = "/login";
    }
  };

  const changeMenu = (menu: MenuKey) => {
    setActiveMenu(menu);
    if (menu === "users") {
      void loadUsers();
    } else if (menu === "products") {
      void loadProducts();
    } else if (menu === "banners") {
      void loadBanners();
    } else {
      void Promise.all([loadStats(), loadProducts()]);
    }
  };

  const renderDashboardContent = () => (
    <Box>
      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
          gap: 2,
        }}
      >
        {statCardStyles.map((item) => {
          const value =
            item.valueKey === "totalRevenueEstimate"
              ? `$${statsOverview.totalRevenueEstimate.toLocaleString()}`
              : item.valueKey === "totalUsers"
                ? statsOverview.totalUsers
                : item.valueKey === "totalProducts"
                  ? statsOverview.totalProducts
                  : statsOverview.totalOrders;
          return (
            <Box key={item.title}>
              <Card
                sx={{
                  borderRadius: 3,
                  background: item.bg,
                  boxShadow: "0 14px 26px rgba(11, 58, 111, 0.14)",
                }}
              >
                <CardContent>
                  <Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                    <Typography sx={{ color: item.color, opacity: 0.85, fontWeight: 600 }}>
                      {item.title}
                    </Typography>
                    <Box sx={{ color: "#ffb000" }}>{item.icon}</Box>
                  </Box>
                  <Typography variant="h4" sx={{ mt: 1, fontWeight: 700, color: item.color }}>
                    {value}
                  </Typography>
                </CardContent>
              </Card>
            </Box>
          );
        })}
      </Box>

      <Box
        sx={{
          mt: 2,
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
          gap: 2,
        }}
      >
        <Card sx={{ borderRadius: 3, boxShadow: "0 14px 26px rgba(12, 45, 88, 0.1)" }}>
          <CardContent>
            <Typography color="text.secondary">Products In Database</Typography>
            <Typography variant="h4" sx={{ fontWeight: 700 }}>
              {statsOverview.totalProducts}
            </Typography>
          </CardContent>
        </Card>
        <Card sx={{ borderRadius: 3, boxShadow: "0 14px 26px rgba(12, 45, 88, 0.1)" }}>
          <CardContent>
            <Typography color="text.secondary">Products Showing (Active)</Typography>
            <Typography variant="h4" sx={{ fontWeight: 700 }}>
              {activeProductsCount}
            </Typography>
          </CardContent>
        </Card>
        <Card sx={{ borderRadius: 3, boxShadow: "0 14px 26px rgba(12, 45, 88, 0.1)" }}>
          <CardContent>
            <Typography color="text.secondary">Hidden Products (Inactive)</Typography>
            <Typography variant="h4" sx={{ fontWeight: 700 }}>
              {inactiveProductsCount}
            </Typography>
          </CardContent>
        </Card>
      </Box>

      <Box
        sx={{
          mt: 2,
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))",
          gap: 2,
        }}
      >
        {categoryStats.map((item) => (
          <Box key={item.category}>
            <Card
              sx={{
                borderRadius: 3,
                boxShadow: "0 14px 26px rgba(12, 45, 88, 0.08)",
              }}
            >
              <CardContent>
                <Typography variant="h6" sx={{ fontWeight: 700 }}>
                  {item.category}
                </Typography>
                <Typography color="text.secondary">Products: {item.productCount}</Typography>
                <Typography color="text.secondary">Stock: {item.totalStock}</Typography>
                <Typography color="text.secondary">
                  Value: ${item.totalValue.toLocaleString()}
                </Typography>
              </CardContent>
            </Card>
          </Box>
        ))}
      </Box>

      <Card
        sx={{
          mt: 2,
          borderRadius: 3,
          boxShadow: "0 14px 26px rgba(12, 45, 88, 0.1)",
        }}
      >
        <CardContent>
          <Typography variant="h6" sx={{ fontWeight: 700 }} gutterBottom>
            Orders Trend (7 Days)
          </Typography>
          <Box sx={{ width: "100%", height: 300 }}>
            <ResponsiveContainer>
              <BarChart data={ordersTrend}>
                <CartesianGrid strokeDasharray="4 4" stroke="#d7deef" />
                <XAxis dataKey="label" stroke="#7282a1" />
                <YAxis allowDecimals={false} stroke="#7282a1" />
                <Tooltip />
                <Legend />
                <Bar dataKey="orders" fill="#1f4e8c" radius={[6, 6, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </Box>
          <Typography variant="body2" color="text.secondary">
            Orders trend is placeholder now. It will become real once orders module is connected.
          </Typography>
        </CardContent>
      </Card>

      <Card sx={{ mt: 2, borderRadius: 3, boxShadow: "0 14px 26px rgba(12, 45, 88, 0.1)" }}>
        <CardContent>
          <Typography variant="h6" sx={{ fontWeight: 700, mb: 2 }}>
            Product-wise Cards
          </Typography>
          <Box
            sx={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
              gap: 2,
            }}
          >
            {products.slice(0, 8).map((product) => (
              <Card
                key={product._id}
                sx={{
                  borderRadius: 2.5,
                  background: product.isActive
                    ? "linear-gradient(135deg, #f9fbff, #eef4ff)"
                    : "linear-gradient(135deg, #f6f6f6, #ececec)",
                }}
              >
                <CardContent>
                  <Typography sx={{ fontWeight: 700 }}>{product.name}</Typography>
                  <Typography variant="body2" color="text.secondary">
                    {product.category}
                  </Typography>
                  <Typography variant="body2">Stock: {product.stock}</Typography>
                  <Typography variant="body2">Price: ${product.price}</Typography>
                  <Typography
                    variant="caption"
                    sx={{
                      color: product.isActive ? "#0f766e" : "#b45309",
                      fontWeight: 700,
                    }}
                  >
                    {product.isActive ? "VISIBLE IN APP" : "HIDDEN IN APP"}
                  </Typography>
                </CardContent>
              </Card>
            ))}
          </Box>
        </CardContent>
      </Card>
    </Box>
  );

  const renderUsersContent = () => (
    <Box>
      <Card sx={{ mb: 2 }}>
        <CardContent sx={{ display: "flex", gap: 1, alignItems: "center" }}>
          <TextField
            fullWidth
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search users by name/email"
          />
          <Button variant="contained" onClick={() => void loadUsers()} disabled={loading}>
            {loading ? "Loading..." : "Search"}
          </Button>
        </CardContent>
      </Card>
      <Card>
        <CardContent sx={{ overflowX: "auto" }}>
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Role</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.id}>
                  <td>{user.name}</td>
                  <td>{user.email}</td>
                  <td>
                    <TextField
                      size="small"
                      select
                      value={user.role}
                      onChange={(e) => void updateRole(user.id, e.target.value as UserRole)}
                    >
                      <MenuItem value="customer">customer</MenuItem>
                      <MenuItem value="admin">admin</MenuItem>
                    </TextField>
                  </td>
                  <td>
                    <Button
                      color="error"
                      variant="outlined"
                      onClick={() => void deleteUser(user.id)}
                      disabled={currentUser?.id === user.id}
                    >
                      Delete
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </CardContent>
      </Card>
    </Box>
  );

  const renderProductsContent = () => (
    <Box>
      <Card sx={{ mb: 2 }}>
        <CardContent className="formGrid">
          <TextField
            placeholder="Name"
            value={productForm.name}
            onChange={(e) => setProductForm((s) => ({ ...s, name: e.target.value }))}
          />
          <TextField
            placeholder="Price"
            type="number"
            value={productForm.price}
            onChange={(e) => setProductForm((s) => ({ ...s, price: e.target.value }))}
          />
          <TextField
            placeholder="Stock"
            type="number"
            value={productForm.stock}
            onChange={(e) => setProductForm((s) => ({ ...s, stock: e.target.value }))}
          />
          <TextField
            select
            value={productForm.category}
            onChange={(e) => setProductForm((s) => ({ ...s, category: e.target.value }))}
          >
            {categoryOptions.map((category) => (
              <MenuItem key={category} value={category}>
                {category}
              </MenuItem>
            ))}
          </TextField>
          <TextField
            placeholder="Image URL (auto after upload)"
            value={productForm.image}
            onChange={(e) => setProductForm((s) => ({ ...s, image: e.target.value }))}
          />
          <TextField
            placeholder="Description"
            value={productForm.description}
            onChange={(e) => setProductForm((s) => ({ ...s, description: e.target.value }))}
          />
          <div className="uploadWrap">
            <input
              type="file"
              accept="image/*"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (!file) return;
                void uploadProductImage(file);
              }}
            />
            <span>{uploadingImage ? "Uploading..." : selectedFileName || "No file selected"}</span>
          </div>
          {productForm.image && <img className="previewImg" src={productForm.image} alt="preview" />}
          <FormControlLabel
            control={
              <Switch
                checked={productForm.isActive}
                onChange={(e) => setProductForm((s) => ({ ...s, isActive: e.target.checked }))}
              />
            }
            label="Active"
          />
          <Button variant="contained" onClick={() => void createProduct()}>
            Add Product
          </Button>
        </CardContent>
      </Card>
      <Card>
        <CardContent sx={{ overflowX: "auto" }}>
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Category</th>
                <th>Price</th>
                <th>Stock</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {products.map((product) => (
                <tr key={product._id}>
                  <td>{product.name}</td>
                  <td>{product.category}</td>
                  <td>{product.price}</td>
                  <td>{product.stock}</td>
                  <td>{product.isActive ? "Active" : "Inactive"}</td>
                  <td>
                    <Button size="small" onClick={() => void toggleProductStatus(product)}>
                      {product.isActive ? "Deactivate" : "Activate"}
                    </Button>
                    <Button size="small" color="error" onClick={() => void deleteProduct(product._id)}>
                      Delete
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </CardContent>
      </Card>
    </Box>
  );

  const renderBannersContent = () => (
    <Box>
      <Card sx={{ mb: 2 }}>
        <CardContent className="formGrid">
          <TextField
            placeholder="Title"
            value={bannerForm.title}
            onChange={(e) => setBannerForm((s) => ({ ...s, title: e.target.value }))}
          />
          <TextField
            placeholder="Subtitle (optional)"
            value={bannerForm.subtitle}
            onChange={(e) => setBannerForm((s) => ({ ...s, subtitle: e.target.value }))}
          />
          <TextField
            select
            value={bannerForm.targetType}
            onChange={(e) =>
              setBannerForm((s) => ({
                ...s,
                targetType: e.target.value as BannerTargetType,
              }))
            }
          >
            <MenuItem value="category">category</MenuItem>
            <MenuItem value="product">product</MenuItem>
            <MenuItem value="url">url</MenuItem>
          </TextField>
          <TextField
            placeholder="Target Value"
            value={bannerForm.targetValue}
            onChange={(e) => setBannerForm((s) => ({ ...s, targetValue: e.target.value }))}
          />
          <TextField
            placeholder="Sort Order"
            type="number"
            value={bannerForm.sortOrder}
            onChange={(e) => setBannerForm((s) => ({ ...s, sortOrder: e.target.value }))}
          />
          <TextField
            placeholder="Image URL (auto after upload)"
            value={bannerForm.image}
            onChange={(e) => setBannerForm((s) => ({ ...s, image: e.target.value }))}
          />
          <div className="uploadWrap">
            <input
              type="file"
              accept="image/*"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (!file) return;
                void uploadBannerImage(file);
              }}
            />
            <span>
              {uploadingBannerImage ? "Uploading..." : selectedBannerFileName || "No file selected"}
            </span>
          </div>
          {bannerForm.image && <img className="previewImg" src={bannerForm.image} alt="preview" />}
          <FormControlLabel
            control={
              <Switch
                checked={bannerForm.isActive}
                onChange={(e) => setBannerForm((s) => ({ ...s, isActive: e.target.checked }))}
              />
            }
            label="Active"
          />
          <Button variant="contained" onClick={() => void createBanner()}>
            Add Banner
          </Button>
        </CardContent>
      </Card>
      <Card>
        <CardContent sx={{ overflowX: "auto" }}>
          <table>
            <thead>
              <tr>
                <th>Title</th>
                <th>Target</th>
                <th>Order</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {banners.map((banner) => (
                <tr key={banner._id}>
                  <td>{banner.title}</td>
                  <td>
                    {banner.targetType}: {banner.targetValue}
                  </td>
                  <td>{banner.sortOrder}</td>
                  <td>{banner.isActive ? "Active" : "Inactive"}</td>
                  <td>
                    <Button size="small" onClick={() => void toggleBannerStatus(banner)}>
                      {banner.isActive ? "Deactivate" : "Activate"}
                    </Button>
                    <Button size="small" color="error" onClick={() => void deleteBanner(banner._id)}>
                      Delete
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </CardContent>
      </Card>
    </Box>
  );

  return (
    <ThemeProvider theme={theme}>
      <Box
        sx={{
          display: "flex",
          background: darkMode
            ? "linear-gradient(180deg, #101827 0%, #111827 100%)"
            : "linear-gradient(180deg, #e9eef9 0%, #dde5f4 100%)",
          minHeight: "100vh",
        }}
      >
      <CssBaseline />
      <AppBar
        position="fixed"
        elevation={0}
        sx={{
          width: `calc(100% - ${drawerWidth}px)`,
          ml: `${drawerWidth}px`,
          backgroundColor: "#f4f7ff",
          color: "#111827",
          borderBottom: "1px solid #d8e0f0",
        }}
      >
        <Toolbar>
          <Typography variant="h6" sx={{ flexGrow: 1, fontWeight: 700 }}>
            {activeMenu === "dashboard"
              ? "Dashboard Summary"
              : activeMenu === "users"
                ? "Users"
                : activeMenu === "products"
                  ? "Products"
                  : "Banners"}
          </Typography>
          <Typography sx={{ mr: 2 }}>{currentUser?.email}</Typography>
          <IconButton onClick={() => setDarkMode((prev) => !prev)} color="primary">
            {darkMode ? <LightModeRoundedIcon /> : <DarkModeRoundedIcon />}
          </IconButton>
          <IconButton onClick={logout} color="primary">
            <LogoutRoundedIcon />
          </IconButton>
        </Toolbar>
      </AppBar>

      <Drawer
        variant="permanent"
        sx={{
          width: drawerWidth,
          flexShrink: 0,
          [`& .MuiDrawer-paper`]: {
            width: drawerWidth,
            boxSizing: "border-box",
            borderRight: "none",
            background: "linear-gradient(180deg, #0a3a6a 0%, #0b2f54 100%)",
            color: "#fff",
          },
        }}
      >
        <Toolbar sx={{ py: 2 }}>
          <Box sx={{ width: "100%" }}>
            <Box sx={{ display: "flex", justifyContent: "center", mb: 1.2 }}>
              <AccountCircleRoundedIcon sx={{ fontSize: 84, color: "#fff" }} />
            </Box>
            <Typography variant="h6" sx={{ fontWeight: 800, textAlign: "center" }}>
              {currentUser?.name || "Admin User"}
            </Typography>
            <Typography variant="body2" sx={{ textAlign: "center", opacity: 0.8 }}>
              {currentUser?.email}
            </Typography>
          </Box>
        </Toolbar>
        <Divider sx={{ borderColor: "rgba(255,255,255,0.14)" }} />
        <List>
          <ListItemButton
            selected={activeMenu === "dashboard"}
            onClick={() => changeMenu("dashboard")}
            sx={{
              mx: 1,
              borderRadius: 2,
              "&.Mui-selected": { backgroundColor: "rgba(255,255,255,0.16)" },
            }}
          >
            <ListItemIcon sx={{ color: "#fff" }}>
              <DashboardRoundedIcon />
            </ListItemIcon>
            <ListItemText primary="Home" />
          </ListItemButton>
          <ListItemButton
            selected={activeMenu === "users"}
            onClick={() => changeMenu("users")}
            sx={{
              mx: 1,
              borderRadius: 2,
              "&.Mui-selected": { backgroundColor: "rgba(255,255,255,0.16)" },
            }}
          >
            <ListItemIcon sx={{ color: "#fff" }}>
              <PeopleAltRoundedIcon />
            </ListItemIcon>
            <ListItemText primary="Users" />
          </ListItemButton>
          <ListItemButton
            selected={activeMenu === "products"}
            onClick={() => changeMenu("products")}
            sx={{
              mx: 1,
              borderRadius: 2,
              "&.Mui-selected": { backgroundColor: "rgba(255,255,255,0.16)" },
            }}
          >
            <ListItemIcon sx={{ color: "#fff" }}>
              <Inventory2RoundedIcon />
            </ListItemIcon>
            <ListItemText primary="Products" />
          </ListItemButton>
          <ListItemButton
            selected={activeMenu === "banners"}
            onClick={() => changeMenu("banners")}
            sx={{
              mx: 1,
              borderRadius: 2,
              "&.Mui-selected": { backgroundColor: "rgba(255,255,255,0.16)" },
            }}
          >
            <ListItemIcon sx={{ color: "#fff" }}>
              <CampaignRoundedIcon />
            </ListItemIcon>
            <ListItemText primary="Banners" />
          </ListItemButton>
        </List>
      </Drawer>

      <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
        <Toolbar />
        <Box
          sx={{
            backgroundColor: "#f4f7ff",
            borderRadius: 4,
            p: 2,
            boxShadow: "0 24px 40px rgba(11, 58, 111, 0.12)",
          }}
        >
          {activeMenu === "dashboard"
            ? renderDashboardContent()
            : activeMenu === "users"
              ? renderUsersContent()
              : activeMenu === "products"
                ? renderProductsContent()
                : renderBannersContent()}
        </Box>
      </Box>
      </Box>
    </ThemeProvider>
  );
}
