// {
//   "memberId": 0,
//   "name": "string",
//   "studentId": "string",
//   "email": "string",
//   "department": "string",
//   "nickname": "string",
//   "campus": "string",
//   "studentType": "string",
//   "teamName": "string"
// }
class UserModel {
  UserModel({
    required this.memberId,
    required this.name,
    required this.studentId,
    required this.email,
    required this.department,
    required this.nickname,
    required this.campus,
    required this.studentType,
    required this.teamName,
    required this.authorization,
    required this.refreshToken
  });

  UserModel.fromJson(Map<String, dynamic> json)
    : memberId = json['memberId'],
      name = json['name'],
      studentId = json['studentId'],
      email = json['email'],
      department = json['department'],
      nickname = json['nickname'],
      campus = json['campus'],
      studentType = json['studentType'],
      teamName = json['teamName'],
      authorization = json['authorization'],
      refreshToken = json['Refresh-Token'];

  UserModel.reissueToken(UserModel oldUser, String newAuthorization)
    : memberId = oldUser.memberId,
      name = oldUser.name,
      studentId = oldUser.studentId,
      email = oldUser.email,
      department = oldUser.department,
      nickname = oldUser.nickname,
      campus = oldUser.campus,
      studentType = oldUser.studentType,
      teamName = oldUser.teamName,
      authorization = newAuthorization,
      refreshToken = oldUser.refreshToken;

  Map<String, dynamic> toJson() => {
    'memberId': memberId,
    'name': name,
    'studentId': studentId,
    'email': email,
    'department': department,
    'nickname': nickname,
    'campus': campus,
    'studentType': studentType,
    'teamName': teamName,
    'authorization': authorization,
    'Refresh-Token': refreshToken,
  };

  final int memberId;
  final String name;
  final String studentId;
  final String email;
  final String department;
  final String nickname;
  final String campus;
  final String studentType;
  final String teamName;
  final String authorization;
  final String refreshToken;
}
