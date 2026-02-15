import 'dart:math';

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

class TeamBingoStatusModel {
  TeamBingoStatusModel({
    required this.name,
    required this.studentId,
    required this.bingoQuestItemSummaryDtoList,
    required this.localData,
  });

  factory TeamBingoStatusModel.fromJson(Map<String, dynamic> json) {
    final items = (json['bingoQuestItemSummaryDtoList'] as List<dynamic>? ?? [])
        .map(
          (e) => BingoQuestItemSummaryDto.fromJson(e as Map<String, dynamic>),
        )
        .toList();

    final totalCount = items.length;
    final completedCount = items.where((e) => e.completed).length;

    final axis = totalCount == 0 ? 0 : sqrt(totalCount).toInt();

    final board = axis == 0
        ? <BingoQuestItemSummaryDto>[]
        : List<BingoQuestItemSummaryDto>.generate(
            axis * axis,
            (_) => BingoQuestItemSummaryDto.empty(),
          );

    for (final item in items) {
      final index = item.rowIndex * axis + item.columnIndex;
      if (axis != 0 && index >= 0 && index < board.length) {
        board[index] = item;
      }
    }

    return TeamBingoStatusModel(
      name: json['name'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      bingoQuestItemSummaryDtoList: items,
      localData: LocalData(
        board: board,
        totalItemCount: totalCount,
        completedItemCount: completedCount,
        countPerAxis: axis,
      ),
    );
  }

  TeamBingoStatusModel.empty()
    : name = 'Dummy',
      studentId = '00000000',
      bingoQuestItemSummaryDtoList = List.generate(25, (_) => BingoQuestItemSummaryDto.empty()),
      localData = LocalData.empty();

  Map<String, dynamic> toJson() => {
    'name': name,
    'studentId': studentId,
    'bingoQuestItemSummaryDtoList': bingoQuestItemSummaryDtoList
        .map((e) => e.toJson())
        .toList(),
  };

  final String name;
  final String studentId;
  final List<BingoQuestItemSummaryDto> bingoQuestItemSummaryDtoList;
  final LocalData localData;
}

class LocalData {
  LocalData({
    required this.board,
    required this.totalItemCount,
    required this.completedItemCount,
    required this.countPerAxis,
  });

  LocalData.empty()
    : board = List.generate(25, (_) => BingoQuestItemSummaryDto.empty()),
      totalItemCount = 25,
      completedItemCount = 0,
      countPerAxis = 5;

  final List<BingoQuestItemSummaryDto> board;
  final int totalItemCount;
  final int completedItemCount;
  final int countPerAxis;
}

class BingoQuestItemSummaryDto {
  BingoQuestItemSummaryDto({
    required this.bingoQuestItemId,
    required this.columnIndex,
    required this.rowIndex,
    required this.completed,
    required this.questInfoView,
  });

  factory BingoQuestItemSummaryDto.fromJson(Map<String, dynamic> json) {
    return BingoQuestItemSummaryDto(
      bingoQuestItemId: json['bingoQuestItemId'] as int? ?? 0,
      columnIndex: json['columnIndex'] as int? ?? 0,
      rowIndex: json['rowIndex'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      questInfoView: QuestInfoView.fromJson(json['questInfoView']),
    );
  }

  BingoQuestItemSummaryDto.empty()
    : bingoQuestItemId = 0,
      columnIndex = 0,
      rowIndex = 0,
      completed = false,
      questInfoView = QuestInfoView.empty();

  Map<String, dynamic> toJson() => {
    'bingoQuestItemId': bingoQuestItemId,
    'columnIndex': columnIndex,
    'rowIndex': rowIndex,
    'completed': completed,
    'questInfoView': questInfoView,
  };

  final int bingoQuestItemId;
  final int columnIndex;
  final int rowIndex;
  final bool completed;
  final QuestInfoView questInfoView;
}

class QuestInfoView {
  QuestInfoView({
    required this.questId,
    required this.questName,
    required this.questType,
    required this.rewardPoint,
    required this.requiredCount,
    required this.completeCount,
  });

  QuestInfoView.fromJson(Map<String, dynamic> json)
    : questId = json['questId'] as int? ?? 0,
      questName = json['questName'] as String? ?? '',
      questType = QuestType.fromString(json['questType']),
      rewardPoint = json['rewardPoint'] as int? ?? 0,
      requiredCount = json['requiredCount'] as int? ?? 0,
      completeCount = json['completeCount'] as int? ?? 0;

  QuestInfoView.empty()
    : questId = 0,
      questName = '',
      questType = QuestType.unknown,
      rewardPoint = 0,
      requiredCount = 0,
      completeCount = 0;

  final int questId;
  final String questName;
  final QuestType questType;
  final int rewardPoint;
  final int requiredCount;
  final int completeCount;
}
