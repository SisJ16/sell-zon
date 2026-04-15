import "package:get/get.dart";
import "../../../core/constants/app_routes.dart";
import "../models/auth_user.dart";
import "../services/auth_service.dart";

class AuthController extends GetxController {
  final AuthService _authService;

  AuthController(this._authService);

  final Rxn<AuthUser> currentUser = Rxn<AuthUser>();
  final isLoading = false.obs;

  bool get isLoggedIn => currentUser.value != null;

  @override
  void onInit() {
    currentUser.value = _authService.getSessionUser();
    super.onInit();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final user = await _authService.register(name: name, email: email, password: password);
      currentUser.value = user;
      Get.offAllNamed(AppRoutes.home);
      Get.snackbar("Success", "Account created successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final user = await _authService.login(email: email, password: password);
      currentUser.value = user;
      Get.offAllNamed(AppRoutes.home);
      Get.snackbar("Success", "Login successful");
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
    Get.snackbar("Success", "Logged out");
  }
}
