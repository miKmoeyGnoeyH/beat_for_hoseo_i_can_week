class PointHistoryModel {
  // "historyName": "string",
  // "historyType": "string",
  // "point": 0,
  // "checkTime": "2026-02-12T16:51:03.549Z"
  PointHistoryModel({
    required this.historyName,
    required this.historyType,
    required this.point,
    required this.checkTime,
  });

  PointHistoryModel.fromJson(Map<String, dynamic> json)
      : historyName = json['historyName'] as String,
        historyType = json['historyType'] as String,
        point = json['point'] as int,
        checkTime = DateTime.parse(json['checkTime'] as String);

  PointHistoryModel.empty()
      : historyName = '',
        historyType = '',
        point = 0,
        checkTime = DateTime.fromMillisecondsSinceEpoch(0);

  final String historyName;
  final String historyType;
  final int point;
  final DateTime checkTime;
}
