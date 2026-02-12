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

enum BingoLineType {
  horizontal("HORIZONTAL"),
  vertical("VERTICAL"),
  diagonal("DIAGONAL");

  const BingoLineType(this.value);

  final String value;
}

/// 모델 변경사항 있으면 gpt한테 부탁
/// 졸라귀찮음
class QuestModel {
  QuestModel({
    required this.questCommonSummaryDto,
    required this.questSummaryAppView,
    required this.localData,
  });

  QuestModel.dummy()
      : questCommonSummaryDto = QuestCommonSummaryDto.dummy(),
        questSummaryAppView =
        QuestSummaryAppView(lineSummaryList: [], itemSummaryList: []),
        localData = LocalData.empty(countPerAxis: 5);

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    final common = QuestCommonSummaryDto.fromJson(json["questCommonSummaryDto"]);
    final view = QuestSummaryAppView.fromJson(json["questSummaryAppView"]);

    // ✅ 보드 구성
    final items = view.itemSummaryList;
    final length = items.length;

    // itemSummaryList가 비어있을 수도 있으니 방어
    final axis = length == 0 ? 0 : sqrt(length).toInt();
    final boardSize = axis * axis;

    final board = List<ItemSummaryModel>.generate(
      boardSize,
          (_) => ItemSummaryModel.empty(),
    );

    for (final item in items) {
      final r = item.rowIndex ?? 0;
      final c = item.columnIndex ?? 0;
      final idx = r * axis + c;

      if (idx >= 0 && idx < board.length) {
        board[idx] = item;
      }
    }

    final completedItemCount = items.where((e) => e.completed == true).length;

    // ✅ completedLineCount / completedLines는 서버 lineSummaryList 기반으로 초기화
    final completedLineCount =
        view.lineSummaryList.where((e) => e.completed == true).length;

    // 서버가 "어떤 줄이 완료됐는지" (가로/세로/대각, 인덱스)까지 안 주면
    // 여기선 일단 빈 배열로 두고, UI에서 계산해서 채우는 형태로 가는 게 안전함.
    // (원하면 board 기반으로 계산하는 함수도 만들어줄게)
    final completedLines = <CompletedLineInfo>[];

    final local = LocalData(
      countPerAxis: axis,
      board: board,
      completedItemCount: completedItemCount,
      completedLineCount: completedLineCount,
      completedLines: completedLines,
    );

    return QuestModel(
      questCommonSummaryDto: common,
      questSummaryAppView: view,
      localData: local,
    );
  }

  /// ✅ 서버 데이터만 저장 (권장: 로컬 UI 상태는 저장 안 함)
  String toServerJsonString() => jsonEncode({
    'questCommonSummaryDto':
    jsonDecode(questCommonSummaryDto.toJsonString()),
    'questSummaryAppView': {
      'lineSummaryList': questSummaryAppView.lineSummaryList
          .map((e) => e.toJson())
          .toList(),
      'itemSummaryList': questSummaryAppView.itemSummaryList
          .map((e) => jsonDecode(e.toJsonString()))
          .toList(),
    },
  });

  /// ✅ 필요하면 로컬(UI)도 같이 저장
  String toJsonString() => jsonEncode({
    'questCommonSummaryDto':
    jsonDecode(questCommonSummaryDto.toJsonString()),
    'questSummaryAppView': {
      'lineSummaryList': questSummaryAppView.lineSummaryList
          .map((e) => e.toJson())
          .toList(),
      'itemSummaryList': questSummaryAppView.itemSummaryList
          .map((e) => jsonDecode(e.toJsonString()))
          .toList(),
    },
    'localData': localData.toJson(),
  });

  final QuestCommonSummaryDto questCommonSummaryDto;
  final QuestSummaryAppView questSummaryAppView;
  final LocalData localData;
}

/// UI를 위한 변수들은 이 객체에 담아서 보관
/// 실제 서버 데이터와 로컬 데이터를 구분하기 위함
class LocalData {
  LocalData({
    required this.countPerAxis,
    required this.board,
    required this.completedItemCount,
    required this.completedLineCount,
    required this.completedLines,
  });

  factory LocalData.empty({required int countPerAxis}) => LocalData(
    countPerAxis: countPerAxis,
    board: List.generate(
      countPerAxis * countPerAxis,
          (_) => ItemSummaryModel.empty(),
    ),
    completedItemCount: 0,
    completedLineCount: 0,
    completedLines: <CompletedLineInfo>[],
  );

  Map<String, dynamic> toJson() => {
    'countPerAxis': countPerAxis,
    'board': board.map((e) => jsonDecode(e.toJsonString())).toList(),
    'completedItemCount': completedItemCount,
    'completedLineCount': completedLineCount,
    'completedLines': completedLines
        .map((e) => {
      'axisIndex': e.axisIndex,
      'lineType': e.lineType.value,
    })
        .toList(),
  };

  /// 한 변의 개수(예: 5)
  final int countPerAxis;

  /// UI에서 바로 쓰는 보드(1차원)
  /// 퀘스트 완료 시 UI 반응성 위해 API 요청과 함께 이 값을 변경
  List<ItemSummaryModel> board;

  /// 완료된 아이템 수
  /// 퀘스트 완료 시 UI 반응성 위해 API 요청과 함께 이 값을 변경
  int completedItemCount;

  /// 완료된 줄 수
  /// 퀘스트 완료 시 UI 반응성 위해 API 요청과 함께 이 값을 변경
  int completedLineCount;

  List<CompletedLineInfo> completedLines;
}

/// 완료된 빙고 줄 객체
/// - 행 : axisIndex = 0~n, lineType = HORIZONTAL
/// - 열 : axisIndex = 0~n, lineType = VERTICAL
/// - 대각선 : axisIndex = 0(좌상-우하), n(우상-좌하), lineType = DIAGONAL
class CompletedLineInfo {
  const CompletedLineInfo({
    required this.axisIndex,
    required this.lineType,
  });

  final int axisIndex;
  final BingoLineType lineType;
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

class QuestSummaryAppView {
  QuestSummaryAppView({
    required this.lineSummaryList,
    required this.itemSummaryList,
  });

  QuestSummaryAppView.fromJson(Map<String, dynamic> json)
      : lineSummaryList = (json['lineSummaryList'] as List)
      .map((e) => LineSummaryModel.fromJson(e))
      .toList(),
        itemSummaryList = (json['itemSummaryList'] as List)
            .map((e) => ItemSummaryModel.fromJson(e))
            .toList();

  final List<LineSummaryModel> lineSummaryList;
  final List<ItemSummaryModel> itemSummaryList;
}

class LineSummaryModel {
  LineSummaryModel({
    required this.bingoLinePolicyId,
    required this.requiredLineCount,
    required this.rewardPoint,
    required this.completed,
  });

  LineSummaryModel.fromJson(Map<String, dynamic> json)
      : bingoLinePolicyId = json['bingoLinePolicyId'],
        requiredLineCount = json['requiredLineCount'],
        rewardPoint = json['rewardPoint'],
        completed = json['completed'];

  LineSummaryModel.empty()
      : bingoLinePolicyId = 1,
        requiredLineCount = 10,
        rewardPoint = 0,
        completed = false;

  Map<String, dynamic> toJson() => {
    'bingoLinePolicyId': bingoLinePolicyId,
    'requiredLineCount': requiredLineCount,
    'rewardPoint': rewardPoint,
    'completed': completed,
  };

  final int bingoLinePolicyId;
  final int requiredLineCount;
  final int rewardPoint;
  final bool completed;
}

class ItemSummaryModel {
  ItemSummaryModel({
    required this.bingoQuestItemId,
    required this.rowIndex,
    required this.columnIndex,
    required this.completed,
    required this.questInfoView,
  });

  ItemSummaryModel.fromJson(Map<String, dynamic> json)
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

  ItemSummaryModel.empty()
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
        required = 1,
        completeCount = 0;

  String toJsonString() => jsonEncode({
    'questId': questId,
    'questName': questName,
    'questType': questType.value,
    'rewardPoint': rewardPoint,
    'requiredCount': required,
    'completeCount': completeCount,
  });

  final int? questId;
  final String? questName;
  final QuestType questType; // ✅ fromJson에서 unknown으로 치환되니까 non-null로 두는 게 안전
  final int? rewardPoint;
  final int required;
  final int? completeCount;
}