import 'dart:convert';
import 'dart:math';

part 'quest_detail_model.dart';

enum QuestType {
  bingo("BINGO"),
  qr("QR"),
  walk("WALK"),
  dummy("DUMMY"),
  unknown("UNKNOWN");

  const QuestType(this.value);

  static QuestType fromString(String? value) {
    return QuestType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => unknown,
    );
  }

  final String value;
}

class QuestModel {
  QuestModel({
    required this.questCommonSummaryDto,
    required this.completedCount,
    required this.questSummaryAppView,
  });

  QuestModel.dummy()
    : questCommonSummaryDto = QuestCommonSummaryDto.dummy(),
      completedCount = 0,
      questSummaryAppView = [];

  QuestModel.fromJson(Map<String, dynamic> json)
    : questCommonSummaryDto = QuestCommonSummaryDto.fromJson(
        json["questCommonSummaryDto"],
      ),
      completedCount = json["questSummaryAppView"]["itemSummaryList"]
          .where((item) => item["completed"] == true)
          .length,
      questSummaryAppView = List<QuestSummaryModel?>.filled(
        json["questSummaryAppView"]["itemSummaryList"].length,
        null,
        growable: false,
      ) {
    final int length = json["questSummaryAppView"]["itemSummaryList"].length;
    final int countPerAxis = sqrt(length).toInt();
    for (var item in json["questSummaryAppView"]["itemSummaryList"]) {
      questSummaryAppView[item["rowIndex"] * countPerAxis +
          item["columnIndex"]] = QuestSummaryModel.fromJson(
        item,
      );
    }
    for (var item in questSummaryAppView) {
      if (item == null) {
        throw Exception("questSummaryAppView contains null item");
      }
    }
  }

  String toJsonString() => jsonEncode({
    'questCommonSummaryDto': jsonDecode(questCommonSummaryDto.toJsonString()),
    'completedCount': completedCount,
    'questSummaryAppView': questSummaryAppView
        .map((item) => jsonDecode(item!.toJsonString()))
        .toList(),
  });

  final QuestCommonSummaryDto questCommonSummaryDto;
  final int completedCount;
  final List<QuestSummaryModel?> questSummaryAppView;
}

class QuestCommonSummaryDto {
  QuestCommonSummaryDto({
    required this.questId,
    required this.name,
    required this.descriptionShort,
    required this.totalPoint,
    required this.questType,
    required this.startDate,
    required this.endDate,
  });

  QuestCommonSummaryDto.fromJson(Map<String, dynamic> json)
    : questId = json['questId'],
      name = json['name'],
      descriptionShort = json['descriptionShort'],
      totalPoint = json['totalPoint'],
      questType = QuestType.fromString(json['questType']),
      startDate = DateTime.parse(json['startDate']),
      endDate = DateTime.parse(json['endDate']);

  String toJsonString() => jsonEncode({
    'questId': questId,
    'name': name,
    'descriptionShort': descriptionShort,
    'totalPoint': totalPoint,
    'questType': questType.value,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
  });

  QuestCommonSummaryDto.dummy()
    : questId = 0,
      name = 'Dummy Quest',
      descriptionShort = 'This is a dummy quest for testing purposes.',
      totalPoint = 0,
      questType = QuestType.dummy,
      startDate = DateTime.now(),
      endDate = DateTime.now().add(const Duration(days: 7));

  final int questId;
  final String name;
  final String descriptionShort;
  final int totalPoint;
  final QuestType questType;
  final DateTime startDate;
  final DateTime endDate;
}

class QuestSummaryModel {
  QuestSummaryModel({
    required this.bingoQuestItemId,
    required this.rowIndex,
    required this.columnIndex,
    required this.completed,
    required this.questInfoView,
  });

  QuestSummaryModel.fromJson(Map<String, dynamic> json)
    : bingoQuestItemId = json['bingoQuestItemId'],
      rowIndex = json['rowIndex'],
      columnIndex = json['columnIndex'],
      completed = json['completed'],
      questInfoView = json["questInfoView"] == null
          ? null
          : QuestInfoView.fromJson(json["questInfoView"]);

  String toJsonString() => jsonEncode({
    'bingoQuestItemId': bingoQuestItemId,
    'rowIndex': rowIndex,
    'columnIndex': columnIndex,
    'completed': completed,
  });

  QuestSummaryModel.empty()
    : bingoQuestItemId = 0,
      rowIndex = 0,
      columnIndex = 0,
      completed = false,
      questInfoView = QuestInfoView.empty();

  final int? bingoQuestItemId;
  final int? rowIndex;
  final int? columnIndex;
  final bool? completed;
  final QuestInfoView? questInfoView;
}

class QuestInfoView {
  QuestInfoView({
    required this.questId,
    required this.questName,
    required this.questType,
    required this.rewardPoint,
    required this.required,
    required this.completeCount,
  });

  QuestInfoView.fromJson(Map<String, dynamic> json)
    : questId = json['questId'],
      questName = json['questName'],
      questType = QuestType.fromString(json['questType']),
      rewardPoint = json['rewardPoint'],
      required = json['requiredCount'] ?? json['requiredStep'],
      completeCount = json['completeCount'];

  QuestInfoView.empty()
    : questId = 0,
      questName = 'Unknown Quest',
      questType = QuestType.unknown,
      rewardPoint = 0,
      required = 0,
      completeCount = 0;

  String toJsonString() => jsonEncode({
    'questId': questId,
    'questName': questName,
    'questType': questType?.value,
    'rewardPoint': rewardPoint,
    'requiredCount': required,
    'completeCount': completeCount,
  });

  final int? questId;
  final String? questName;
  final QuestType? questType;
  final int? rewardPoint;
  final int required;
  final int? completeCount;
}
