import "package:get/get.dart";
import "../../../core/network/api_client.dart";
import "../controllers/auth_controller.dart";
import "../services/auth_service.dart";

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(Get.find<AuthService>()), fenix: true);
  }
}
