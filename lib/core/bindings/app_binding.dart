import "package:get/get.dart";
import "../network/api_client.dart";
import "../services/api_config_service.dart";
import "../../features/admin/controllers/admin_controller.dart";
import "../../features/admin/services/admin_service.dart";
import "../../features/auth/bindings/auth_binding.dart";
import "../../features/auth/controllers/auth_controller.dart";
import "../../features/home/bindings/home_binding.dart";
import "../../features/address/controllers/address_controller.dart";

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiConfigService>(ApiConfigService(), permanent: true);
    Get.put<ApiClient>(ApiClient(Get.find<ApiConfigService>()), permanent: true);
    AuthBinding().dependencies();
    Get.lazyPut<AdminService>(() => AdminService(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<AdminController>(
      () => AdminController(Get.find<AdminService>(), Get.find<AuthController>()),
      fenix: true,
    );
    HomeBinding().dependencies();
    Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
  }
}
