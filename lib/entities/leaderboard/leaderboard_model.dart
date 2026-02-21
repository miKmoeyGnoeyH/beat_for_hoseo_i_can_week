class TeamRankingInfoDto {
  TeamRankingInfoDto({required this.teamId, required this.teamName, required this.num});

  TeamRankingInfoDto.fromJson(Map<String, dynamic> json)
    : teamId = json['teamId'] as int,
      teamName = json['teamName'] as String,
      num = json['num'] as int;

  TeamRankingInfoDto.empty()
    : teamId = 0,
      teamName = '',
      num = 0;

  final int teamId;
  final String teamName;
  final int num;
}

class MemberRankingInfoDto {
  MemberRankingInfoDto({required this.memberId, required this.nickname, required this.num});

  MemberRankingInfoDto.fromJson(Map<String, dynamic> json)
    : memberId = json['memberId'] as int,
      nickname = json['nickname'] as String,
      num = json['num'] as int;

  MemberRankingInfoDto.empty()
    : memberId = 0,
      nickname = '',
      num = 0;

  final int memberId;
  final String nickname;
  final int num;
}

class BingoRankingInfoDto {
  BingoRankingInfoDto({required this.teamId, required this.teamName, required this.num});

  BingoRankingInfoDto.fromJson(Map<String, dynamic> json)
      : teamId = json['teamId'] as int,
        teamName = json['teamName'] as String,
        num = DateTime.parse(json['num']);

  BingoRankingInfoDto.empty()
      : teamId = 0,
        teamName = '',
        num = DateTime.now();

  final int teamId;
  final String teamName;
  final DateTime num;
}