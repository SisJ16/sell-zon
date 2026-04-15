import "package:get/get.dart";
import "../../auth/controllers/auth_controller.dart";
import "../models/admin_user.dart";
import "../services/admin_service.dart";

class AdminController extends GetxController {
  final AdminService _adminService;
  final AuthController _authController;

  AdminController(this._adminService, this._authController);

  final users = <AdminUser>[].obs;
  final search = "".obs;
  final isLoading = false.obs;

  bool get isAdmin => _authController.currentUser.value?.role == "admin";

  @override
  void onInit() {
    super.onInit();
    if (isAdmin) {
      fetchUsers();
    }
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      final result = await _adminService.fetchUsers(search: search.value);
      users.assignAll(result);
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRole(AdminUser user, String role) async {
    try {
      await _adminService.updateUserRole(userId: user.id, role: role);
      await fetchUsers();
      Get.snackbar("Success", "Role updated");
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceFirst("Exception: ", ""));
    }
  }

  Future<void> deleteUser(AdminUser user) async {
    try {
      await _adminService.deleteUser(user.id);
      users.removeWhere((item) => item.id == user.id);
      Get.snackbar("Success", "User deleted");
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceFirst("Exception: ", ""));
    }
  }
}
