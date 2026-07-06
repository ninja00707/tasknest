class UserModel {
  final int id;
  final String name;
  final String email;
  final int roleId;
  final int departmentId;
  final int companyId;
  final bool isActive;
  final String designation;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    required this.departmentId,
    required this.companyId,
    required this.isActive,
    this.designation = '',
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
      designation: json['designation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role_id': roleId,
      'department_id': departmentId,
      'company_id': companyId,
      'is_active': isActive,
      'designation': designation,
    };
  }
}
