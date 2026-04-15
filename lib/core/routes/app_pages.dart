import "package:get/get.dart";
import "../constants/app_routes.dart";
import "../../features/auth/middlewares/auth_guard_middleware.dart";
import "../../features/auth/middlewares/guest_guard_middleware.dart";
import "../../features/auth/presentation/pages/login_page.dart";
import "../../features/auth/presentation/pages/register_page.dart";
import "../../features/admin/presentation/pages/admin_panel_page.dart";
import "../../features/home/bindings/home_binding.dart";
import "../../features/home/views/home_page.dart";
import "../../features/settings/presentation/pages/api_config_page.dart";

class AppPages {
  static List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      middlewares: [GuestGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      middlewares: [GuestGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomePage(),
      binding: HomeBinding(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: AppRoutes.apiConfig,
      page: () => const ApiConfigPage(),
    ),
    GetPage(
      name: AppRoutes.adminPanel,
      page: () => AdminPanelPage(),
      middlewares: [AuthGuardMiddleware()],
    ),
  ];
}
