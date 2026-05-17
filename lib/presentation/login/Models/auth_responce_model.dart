class AuthResponseModel {
  final String token;
  final String name;
  final String email;

  AuthResponseModel({
    required this.token,
    required this.name,
    required this.email,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'],
      name: json['user']['name'],
      email: json['user']['email'],
    );
  }
}
