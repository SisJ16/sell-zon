class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "role": role,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json["id"] as String? ?? "",
      name: json["name"] as String? ?? "",
      email: json["email"] as String? ?? "",
      role: json["role"] as String? ?? "customer",
    );
  }
}
