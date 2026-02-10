import 'dart:convert';

import 'package:beat/shared/enums/index.dart';

class QuestModel {
  QuestModel({
    required this.eventId,
    required this.eventName,
    required this.descriptionShort,
    required this.point,
    required this.eventType,
    required this.startDate,
    required this.endDate,
    required this.hasSuccess,
    required this.period,
    this.requiredWalkCount = -1,
    this.requiredCount = -1,
    this.successCount = -1,
    this.totalCount = -1,
  });

  QuestModel.dummy()
      : eventId = -1,
        eventName = 'Dummy Event',
        descriptionShort = 'This is a dummy event for skeletonizer.',
        point = 0,
        eventType = EventType.unknown,
        startDate = '2024-01-01',
        endDate = '2024-12-31',
        hasSuccess = false,
        period = Period.unknown,
        requiredWalkCount = 0,
        requiredCount = 0,
        successCount = 0,
        totalCount = 0;

  QuestModel.fromJson(Map<String, dynamic> json)
    : eventId = json['eventId'],
      eventName = json['eventName'],
      descriptionShort = json['descriptionShort'],
      point = json['neuro'],
      eventType = EventType.stringToEventType(json['eventType']),
      startDate = json['startDate'],
      endDate = json['endDate'],
      hasSuccess = json['hasSuccess'],
      period = Period.stringToPeriod(json['period']),
      requiredWalkCount = json['requiredWalkCount'],
      requiredCount = json['requiredCount'],
      successCount = json['successCount'],
      totalCount = json['totalCount'];

  String toJsonString() => jsonEncode({
    'eventId': eventId,
    'eventName': eventName,
    'descriptionShort': descriptionShort,
    'neuro': point,
    'eventType': eventType.name,
    'startDate': startDate,
    'endDate': endDate,
    'hasSuccess': hasSuccess,
    'period': period.name,
    'requiredWalkCount': requiredWalkCount,
    'requiredCount': requiredCount,
    'successCount': successCount,
    'totalCount': totalCount,
  });

  final int eventId;
  final String eventName;
  final String descriptionShort;
  final int point;
  final EventType eventType;
  final String startDate;
  final String endDate;
  final bool hasSuccess;
  final Period period;
  final int? requiredWalkCount;
  final int? requiredCount;
  final int? successCount;
  final int? totalCount;
}
