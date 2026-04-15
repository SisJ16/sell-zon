import "package:flutter/material.dart";
import "package:get/get.dart";
import "../../controllers/admin_controller.dart";

class AdminPanelPage extends StatelessWidget {
  AdminPanelPage({super.key});

  final AdminController controller = Get.find<AdminController>();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!controller.isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text("Only admin can access this page"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by name/email",
                suffixIcon: IconButton(
                  onPressed: () {
                    controller.search.value = searchController.text;
                    controller.fetchUsers();
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
              onSubmitted: (_) {
                controller.search.value = searchController.text;
                controller.fetchUsers();
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.users.isEmpty) {
                    return const Center(child: Text("No users found"));
                  }

                  return ListView.separated(
                    itemCount: controller.users.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = controller.users[index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(user.email),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  DropdownButton<String>(
                                    value: user.role,
                                    items: const [
                                      DropdownMenuItem(value: "customer", child: Text("customer")),
                                      DropdownMenuItem(value: "admin", child: Text("admin")),
                                    ],
                                    onChanged: (value) {
                                      if (value == null || value == user.role) return;
                                      controller.updateRole(user, value);
                                    },
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => controller.deleteUser(user),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
