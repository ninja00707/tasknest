class AuthResponseModel {
  final String token;
  final String name;
  final String email;
  final String companyId;
  final String departmentId;
  final String role;

  AuthResponseModel({
    required this.token,
    required this.name,
    required this.email,
    required this.companyId,
    required this.departmentId,
    required this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return AuthResponseModel(
      token: json['token'] ?? '',
      name: user['name'] ?? 'User',
      email: user['email'] ?? '',
      companyId: user['companyId'] ?? '',
      departmentId: user['departmentId'] ?? '',
      role: user['role'] ?? '',
    );
  }
}
