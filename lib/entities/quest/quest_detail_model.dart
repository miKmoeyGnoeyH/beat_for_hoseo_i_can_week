part of 'quest_model.dart';

class QuestDetailModel {
  QuestDetailModel({
    required this.questDetailCommonAppDto,
    required this.qrMissionAppDto,
    required this.walkMissionAppDto,
  });

  QuestDetailModel.fromJson(Map<String, dynamic> json)
    : questDetailCommonAppDto = QuestDetailCommonAppDto.fromJson(json['questDetailCommonAppDto']),
      qrMissionAppDto = json['qrMissionAppDto'] != null
          ? QRMissionAppDto.fromJson(json['qrMissionAppDto'])
          : null,
      walkMissionAppDto = json['walkMissionAppDto'] != null
          ? WalkMissionAppDto.fromJson(json['walkMissionAppDto'])
          : null;

  final QuestDetailCommonAppDto questDetailCommonAppDto;
  final QRMissionAppDto? qrMissionAppDto;
  final WalkMissionAppDto? walkMissionAppDto;
}

class QuestDetailCommonAppDto {
  QuestDetailCommonAppDto({
    required this.questId,
    required this.name,
    required this.descriptionLong,
    required this.totalPoint,
    required this.questType,
    required this.startDate,
    required this.endDate,
    required this.completed,
    required this.completedAt,
    required this.fileList,
  });

  QuestDetailCommonAppDto.fromJson(Map<String, dynamic> json)
    : questId = json['questId'],
      name = json['name'],
      descriptionLong = json['descriptionLong'],
      totalPoint = json['totalPoint'],
      questType = QuestType.fromString(json['questType']),
      startDate = json['startDate'],
      endDate = json['endDate'],
      completed = json['completed'],
      completedAt = json['completedAt'],
      fileList = (json['fileList'] as List)
          .map((e) => QuestFileAppDto.fromJson(e))
          .toList();

  final int questId;
  final String name;
  final String descriptionLong;
  final int totalPoint;
  final QuestType questType;
  final String startDate;
  final String endDate;
  final bool completed;
  final String? completedAt;
  final List<QuestFileAppDto> fileList;
}

class QuestFileAppDto {
  QuestFileAppDto({
    required this.fileId,
    required this.fileName,
    required this.publicUrl,
  });

  QuestFileAppDto.fromJson(Map<String, dynamic> json)
    : fileId = json['fileId'],
      fileName = json['fileName'],
      publicUrl = json['publicUrl'];

  final int fileId;
  final String fileName;
  final String publicUrl;
}

class QRMissionAppDto {
  QRMissionAppDto({
    required this.questUsageType,
    required this.progressType,
    required this.hasReward,
    required this.conditionRequirement,
    required this.conditionRewardPoint,
    required this.qrMissionItemAppDtoList,
  });

  QRMissionAppDto.fromJson(Map<String, dynamic> json)
    : questUsageType = json['questUsageType'],
      progressType = json['progressType'],
      hasReward = json['hasReward'],
      conditionRequirement = json['conditionRequirement'],
      conditionRewardPoint = json['conditionRewardPoint'],
      qrMissionItemAppDtoList = (json['qrMissionItemAppDtoList'] as List)
          .map((e) => QRMissionItemAppDto.fromJson(e))
          .toList();

  final String questUsageType;
  final String progressType;
  final bool hasReward;
  final int conditionRequirement;
  final int conditionRewardPoint;
  final List<QRMissionItemAppDto> qrMissionItemAppDtoList;
}

class QRMissionItemAppDto {
  QRMissionItemAppDto({
    required this.qrMissionId,
    required this.name,
    required this.location,
    required this.rewardPoint,
    required this.completed,
    required this.completedAt,
  });

  QRMissionItemAppDto.fromJson(Map<String, dynamic> json)
    : qrMissionId = json['qrMissionId'],
      name = json['name'],
      location = json['location'],
      rewardPoint = json['rewardPoint'],
      completed = json['completed'],
      completedAt = json['completedAt'];

  final int qrMissionId;
  final String name;
  final String location;
  final int rewardPoint;
  final bool completed;
  final String? completedAt;
}

class WalkMissionAppDto {
  WalkMissionAppDto({
    required this.questUsageType,
    required this.progressType,
    required this.period,
    required this.conditionRequirement,
    required this.conditionRewardPoint,
    required this.completed,
    required this.completedAt,
  });

  WalkMissionAppDto.fromJson(Map<String, dynamic> json)
    : questUsageType = json['questUsageType'],
      progressType = json['progressType'],
      period = json['period'],
      conditionRequirement = json['conditionRequirement'],
      conditionRewardPoint = json['conditionRewardPoint'],
      completed = json['completed'],
      completedAt = json['completedAt'];

  final String questUsageType;
  final String progressType;
  final String period;
  final int conditionRequirement;
  final int conditionRewardPoint;
  final bool completed;
  final String? completedAt;
}
