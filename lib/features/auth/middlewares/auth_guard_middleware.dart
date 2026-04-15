import "package:flutter/widgets.dart";
import "package:get/get.dart";
import "../../../core/constants/app_routes.dart";
import "../controllers/auth_controller.dart";

class AuthGuardMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
