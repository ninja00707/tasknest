class AuthResponseModel {
  final String token;
  final UserModel user;

  AuthResponseModel({required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final int roleId;
  final int departmentId;
  final int companyId;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    required this.departmentId,
    required this.companyId,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roleId: json['role_id'] ?? 0,
      departmentId: json['department_id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      isActive: json['is_active'] ?? false,
    );
  }
}
