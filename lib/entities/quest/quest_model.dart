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
    : questCommonSummaryDto = QuestCommonSummaryDto.empty(),
      questSummaryAppView = QuestSummaryAppView(
        lineSummaryList: [],
        itemSummaryList: [],
      ),
      localData = LocalData.empty(countPerAxis: 5);

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    final common = QuestCommonSummaryDto.fromJson(
      json["questCommonSummaryDto"],
    );
    final view = QuestSummaryAppView.fromJson(json["questSummaryAppView"]);

    /// 빙고 각 칸의 정보 리스트를 읽어옴
    final items = view.itemSummaryList;
    final length = items.length;

    /// 빙고 각 칸 정보 리스트의 길이로부터 빙고판 크기를 계산
    final axis = length == 0 ? 0 : sqrt(length).toInt();
    final boardSize = axis * axis;

    /// 빙고판 크기만큼 리스트를 생성, 빈 아이템으로 초기화
    final board = List<ItemSummaryModel>.generate(
      boardSize,
      (_) => ItemSummaryModel.empty(),
    );

    /// 실제 응답에 포함된 빙고 각 칸 아이템 정보를 순회하며
    /// 보드의 적절한 위치에 아이템을 배치
    for (final item in items) {
      final r = item.rowIndex ?? 0;
      final c = item.columnIndex ?? 0;
      final idx = r * axis + c;

      if (idx >= 0 && idx < board.length) {
        board[idx] = item;
      }
    }

    /// 완료한(보상 수령한) 빙고 칸 개수를 계산
    final completedItemCount = items.where((e) => e.completed == true).length;

    /// 빙고판을 전체 순회하며 완료한 줄 정보를 계산
    final completedLines = <CompletedLineInfo>[];

    /// 행 검사
    for (int i = 0; i < axis; i++) {
      if (List.generate(
        axis,
        (j) => board[i * axis + j],
      ).every((item) => item.completed == true)) {
        completedLines.add(
          CompletedLineInfo(axisIndex: i, lineType: BingoLineType.horizontal),
        );
      }
    }

    /// 열 검사
    for (int i = 0; i < axis; i++) {
      if (List.generate(
        axis,
            (j) => board[i + axis * j],
      ).every((item) => item.completed == true)) {
        completedLines.add(
          CompletedLineInfo(axisIndex: i, lineType: BingoLineType.vertical),
        );
      }
    }

    /// 대각선 검사
    /// 좌상-우하 대각선
    for (int i = 0; i < axis; i++) {
      if (board[i * axis + i].completed != true) {
        break;
      }
      if (i == axis - 1) {
        completedLines.add(
          CompletedLineInfo(axisIndex: 0, lineType: BingoLineType.diagonal),
        );
      }
    }

    /// 우상-좌하 대각선
    for (int i = axis - 1; i >= 0; i--) {
      if (board[i * axis + i].completed != true) {
        break;
      }
      if (i == axis - 1) {
        completedLines.add(
          CompletedLineInfo(axisIndex: axis - 1, lineType: BingoLineType.diagonal),
        );
      }
    }

    final int completedLineCount = completedLines.length;

    final local = LocalData(
      countPerAxis: axis,
      board: board,
      completedItemCount: completedItemCount,
      completedLines: completedLines,
      completedLineCount: completedLineCount,
    );

    return QuestModel(
      questCommonSummaryDto: common,
      questSummaryAppView: view,
      localData: local,
    );
  }

  /// ✅ 서버 데이터만 저장 (권장: 로컬 UI 상태는 저장 안 함)
  String toServerJsonString() => jsonEncode({
    'questCommonSummaryDto': jsonDecode(questCommonSummaryDto.toJsonString()),
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
    'questCommonSummaryDto': jsonDecode(questCommonSummaryDto.toJsonString()),
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
    required this.completedLines,
    required this.completedLineCount,
  });

  factory LocalData.empty({required int countPerAxis}) => LocalData(
    countPerAxis: countPerAxis,
    board: List.generate(
      countPerAxis * countPerAxis,
      (_) => ItemSummaryModel.empty(),
    ),
    completedItemCount: 0,
    completedLines: <CompletedLineInfo>[],
    completedLineCount: 0,
  );

  Map<String, dynamic> toJson() => {
    'countPerAxis': countPerAxis,
    'board': board.map((e) => jsonDecode(e.toJsonString())).toList(),
    'completedItemCount': completedItemCount,
    'completedLines': completedLines
        .map((e) => {'axisIndex': e.axisIndex, 'lineType': e.lineType.value})
        .toList(),
    'completedLineCount': completedLineCount,
  };

  /// 한 변의 개수(예: 5)
  final int countPerAxis;

  /// UI에서 바로 쓰는 보드(1차원)
  /// 퀘스트 완료 시 UI 반응성 위해 API 요청과 함께 이 값을 변경
  /// 2026.02.21: 퀘스트 완료 시/QR 스캔 성공 시 퀘스트 목록을 다시 요청함
  List<ItemSummaryModel> board;

  /// 완료된 아이템 수
  /// 퀘스트 완료 시 UI 반응성 위해 API 요청과 함께 이 값을 변경
  /// 2026.02.21: 퀘스트 완료 시/QR 스캔 성공 시 퀘스트 목록을 다시 요청함
  int completedItemCount;

  List<CompletedLineInfo> completedLines;

  /// 완료된 줄 수
  /// 퀘스트 완료 시 UI 반응성 위해 API 요청과 함께 이 값을 변경
  /// 2026.02.21: 퀘스트 완료 시/QR 스캔 성공 시 퀘스트 목록을 다시 요청함
  int completedLineCount;
}

/// 완료된 빙고 줄 객체
/// - 행 : axisIndex = 0~n, lineType = HORIZONTAL
/// - 열 : axisIndex = 0~n, lineType = VERTICAL
/// - 대각선 : axisIndex = 0(좌상-우하), n(우상-좌하), lineType = DIAGONAL
class CompletedLineInfo {
  const CompletedLineInfo({required this.axisIndex, required this.lineType});

  Map<String, dynamic> toJson() => {
    'lineIndex': axisIndex,
    'lineType': lineType.value,
  };

  final int axisIndex;
  final BingoLineType lineType;
}

/// 빙고 퀘스트 전체 이름, 정보
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

  QuestCommonSummaryDto.empty()
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

/// 빙고 완성 보상 정보, 빙고 각 칸의 정보
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

/// 빙고 줄 완성 보상 정보
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

/// 빙고 칸 하나의 정보
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

/// 해당 빙고 칸의 더욱 상세한 정보
/// 퀘스트 ID, 퀘스트 타입 등
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
