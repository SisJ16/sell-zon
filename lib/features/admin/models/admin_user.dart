class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json["id"] as String? ?? "",
      name: json["name"] as String? ?? "",
      email: json["email"] as String? ?? "",
      role: json["role"] as String? ?? "customer",
      createdAt: DateTime.tryParse(json["createdAt"] as String? ?? ""),
    );
  }
}
