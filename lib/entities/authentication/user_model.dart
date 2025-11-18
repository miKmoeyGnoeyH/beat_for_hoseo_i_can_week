class UserModel {
  UserModel({
    required this.name,
    required this.nickname,
    required this.category,
    required this.department,
    required this.email,
    required this.sendToTime,
    required this.authorization,
  });

  UserModel.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      nickname = json['nickname'] as String,
      category = json['category'] as String,
      department = json['department'] as String,
      email = json['email'] as String,
      sendToTime = json['sendToTime'] as int,
      authorization = json['authorization'] as String;

  UserModel.empty()
    : name = '',
      nickname = '',
      category = '',
      department = '',
      email = '',
      sendToTime = 0,
      authorization = '';

  Map<String, dynamic> toJson() => {
    'name': name,
    'nickname': nickname,
    'category': category,
    'department': department,
    'email': email,
    'sendToTime': sendToTime,
    'authorization': authorization,
  };


  final String name;
  final String nickname;
  final String category;
  final String department;
  final String email;
  final int sendToTime;
  final String authorization;
}
