enum StudentType {
  mentor("멘토"),
  mentee("멘티"),
  unknown("알수없음");

  const StudentType(this.value);

  static StudentType fromString(String value) {
    return StudentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => unknown,
    );
  }

  final String value;
}

class ProfileModel {
  ProfileModel({
    required this.memberId,
    required this.name,
    required this.studentId,
    required this.email,
    required this.department,
    required this.nickname,
    required this.campus,
    required this.studentType,
    required this.teamName,
    required this.teamId,
  });

  ProfileModel.fromJson(Map<String, dynamic> json)
    : memberId = json['memberId'] as int,
      name = json['name'] as String,
      studentId = json['studentId'] as String,
      email = json['email'] as String,
      department = json['department'] as String,
      nickname = json['nickname'] as String,
      campus = json['campus'] as String,
      studentType = StudentType.fromString(json['studentType'] as String),
      teamName = json['teamName'] as String,
      teamId = json['teamId'] as int;

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
    'teamId': teamId,
  };

  final int memberId;
  final String name;
  final String studentId;
  final String email;
  final String department;
  final String nickname;
  final String campus;
  final StudentType studentType;
  final String teamName;
  final int teamId;
}
