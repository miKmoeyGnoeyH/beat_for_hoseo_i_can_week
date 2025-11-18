class AuthenticationModel {
  AuthenticationModel({
    required this.id,
    required this.nickname,
    required this.authorization,
  });

  AuthenticationModel.fromJson(Map<String, dynamic> json)
    : id = json['studentId'] as String,
      nickname = json['nickname'] as String,
      authorization = json['authorization'] as String;

  AuthenticationModel.empty()
    : id = '',
      nickname = '',
      authorization = '';

  final String id;
  final String nickname;
  final String authorization;
}
