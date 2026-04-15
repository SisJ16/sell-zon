import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(
      () {
        final user = authController.currentUser.value;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (user != null)
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  child: const Text("Login to view profile"),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.apiConfig),
                icon: const Icon(Icons.settings_ethernet),
                label: const Text("API Config"),
              ),
              if (user?.role == "admin") ...[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.adminPanel),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text("Admin Panel"),
                ),
              ],
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: user == null ? () => Get.toNamed(AppRoutes.login) : authController.logout,
                icon: const Icon(Icons.logout),
                label: Text(user == null ? "Go to Login" : "Logout"),
              ),
            ],
          ),
        );
      },
    );
  }
}
